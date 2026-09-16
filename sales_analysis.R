# Retail sales and profitability analysis
# Keep this script and sample_-_superstore.xls in the same folder.
# RStudio: open this script and click Source to run the complete analysis.
# Terminal: Rscript sales_analysis.R
# Install once if needed: install.packages("readxl")
# Results are written into a results folder next to this script.

if (!requireNamespace("readxl", quietly = TRUE)) {
  stop('Install readxl first: install.packages("readxl")')
}

# Locate the script without relying on a personal absolute path.
source_files <- lapply(sys.frames(), function(frame) frame$ofile)
source_files <- Filter(function(x) is.character(x) && length(x) == 1L, source_files)
cli_file <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(source_files)) {
  script_file <- source_files[[length(source_files)]]
  project_dir <- dirname(normalizePath(script_file, mustWork = TRUE))
} else if (length(cli_file)) {
  project_dir <- dirname(normalizePath(sub("^--file=", "", cli_file[1]), mustWork = TRUE))
} else {
  project_dir <- getwd()
}
data_file <- file.path(project_dir, "sample_-_superstore.xls")
if (!file.exists(data_file)) {
  stop("Excel file not found. Put sample_-_superstore.xls beside the script and run using Source.")
}
orders <- as.data.frame(readxl::read_excel(data_file, sheet = "Orders"))
required <- c("Row ID", "Order ID", "Sales", "Profit", "Quantity", "Discount", "Category")
if (!all(required %in% names(orders))) stop("Required columns are missing.")
if (anyNA(orders[required])) stop("Missing values in analysis columns require review.")
if (any(!vapply(orders[c("Sales", "Profit", "Quantity", "Discount")], is.numeric, logical(1)))) {
  stop("Sales, Profit, Quantity and Discount must be numeric.")
}
if (any(!is.finite(as.matrix(orders[c("Sales", "Profit", "Quantity", "Discount")])))) {
  stop("Non-finite numeric values require review.")
}
if (any(orders$Sales <= 0)) stop("Non-positive sales require review before computing margins.")
if (any(orders$Discount < 0 | orders$Discount > 1)) stop("Discount must be between 0 and 1.")
if (anyDuplicated(orders$`Row ID`)) stop("Duplicate Row IDs require review.")
orders$Category <- relevel(factor(orders$Category), ref = "Furniture")
results_dir <- file.path(project_dir, "results")
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

save_plot <- function(filename, code) {
  grDevices::pdf(file.path(results_dir, filename), width = 8, height = 5.5)
  on.exit(grDevices::dev.off(), add = TRUE)
  force(code)
}

# Group margins use total profit / total sales.
# Regressions use equally weighted line-level margins and describe associations.
dim(orders)
names(orders)
str(orders)
colSums(is.na(orders))
summary(orders[c("Sales", "Quantity", "Discount", "Profit")])
total_sales <- sum(orders$Sales)
total_profit <- sum(orders$Profit)
profit_margin <- total_profit / total_sales
order_count <- length(unique(orders$`Order ID`))

overall_summary <- data.frame(
  total_sales = total_sales,
  total_profit = total_profit,
  profit_margin_pct = profit_margin * 100,
  order_count = order_count)
print(overall_summary)

category_summary <- aggregate(
  cbind(Sales, Profit) ~ Category,
  data = orders,
  FUN = sum)
category_summary$profit_margin_pct <-
  category_summary$Profit / category_summary$Sales * 100
category_summary <- category_summary[
  order(category_summary$Sales, decreasing = TRUE),
]
print(category_summary)

orders$profit_rate <- orders$Profit / orders$Sales
model1 <- lm(profit_rate ~ Discount, data = orders)
print(summary(model1))

print(coef(summary(model1)))

model2 <- lm(profit_rate ~ Discount + Category,data = orders)
print(coef(summary(model2)))

save_plot("discount_profit_scatter.pdf", {
plot(
  orders$Discount,
  orders$profit_rate,
  xlab = "Discount",
  ylab = "Profit / Sales",
  main = "Discount and Profit Margin",
  pch = 16,
  col = rgb(0, 0, 1, 0.12)
)

abline(model1, col = "red", lwd = 2)
})
save_plot("linear_residuals.pdf", plot(model2, which = 1))


model_quadratic <- lm(
  profit_rate ~ Discount + I(Discount^2) + Category,
  data = orders)
model_comparison <- data.frame(
  model = c("Linear", "Quadratic"),
  adjusted_r_squared = c(
    summary(model2)$adj.r.squared,
    summary(model_quadratic)$adj.r.squared))
print(model_comparison)
save_plot("quadratic_residuals.pdf", plot(model_quadratic, which = 1))

sum(duplicated(orders))
sum(duplicated(orders$`Row ID`))

category_plot <- category_summary[
  order(category_summary$profit_margin_pct, decreasing = TRUE),]


save_plot("category_profit_margin.pdf", {
bar_positions <- barplot(
  category_plot$profit_margin_pct,
  names.arg = category_plot$Category,
  col = c("#2563EB", "#14B8A6", "#F59E0B"),
  ylim = c(min(0, min(category_plot$profit_margin_pct) * 1.2),
           max(1, max(category_plot$profit_margin_pct) * 1.3)),
  main = "Profit Margin by Product Category",
  ylab = "Profit Margin (%)",
  border = NA,
  cex.names = 0.85)
text(
  x = bar_positions,
  y = category_plot$profit_margin_pct,
  labels = sprintf("%.2f%%", category_plot$profit_margin_pct),
  pos = 3)
})


discount_summary <- do.call(
  rbind,
  lapply(split(orders, orders$Discount), function(x) {
    data.frame(
      discount_pct = x$Discount[1] * 100,
      line_count = nrow(x),
      sales = sum(x$Sales),
      profit = sum(x$Profit),
      profit_margin_pct = sum(x$Profit) / sum(x$Sales) * 100,
      loss_line_pct = mean(x$Profit < 0) * 100)}))
rownames(discount_summary) <- NULL

discount_summary <- discount_summary[
  order(discount_summary$discount_pct),
]

print(round(discount_summary, 2))

# Export tables and model details for review.
write.csv(overall_summary, file.path(results_dir, "overall_summary.csv"), row.names = FALSE)
write.csv(category_summary, file.path(results_dir, "category_summary.csv"), row.names = FALSE)
write.csv(discount_summary, file.path(results_dir, "discount_summary.csv"), row.names = FALSE)
write.csv(model_comparison, file.path(results_dir, "model_comparison.csv"), row.names = FALSE)
capture.output(summary(model1), summary(model2), summary(model_quadratic),
               file = file.path(results_dir, "regression_results.txt"))
capture.output(sessionInfo(), file = file.path(results_dir, "session_info.txt"))
message("Analysis complete. Results saved to: ", results_dir)
