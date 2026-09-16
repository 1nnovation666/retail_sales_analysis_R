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
summary(model1)

coef(summary(model1))

model2 <- lm(profit_rate ~ Discount + Category,data = orders)
coef(summary(model2))

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
plot(model2, which = 1)


model_quadratic <- lm(
  profit_rate ~ Discount + I(Discount^2) + Category,
  data = orders)
data.frame(
  model = c("Linear", "Quadratic"),
  adjusted_r_squared = c(
    summary(model2)$adj.r.squared,
    summary(model_quadratic)$adj.r.squared))
plot(model_quadratic, which = 1)

sum(duplicated(orders))
sum(duplicated(orders$`Row ID`))

category_plot <- category_summary[
  order(category_summary$profit_margin_pct, decreasing = TRUE),]


bar_positions <- barplot(
  category_plot$profit_margin_pct,
  names.arg = category_plot$Category,
  col = c("#2563EB", "#14B8A6", "#F59E0B"),
  ylim = c(0, 22),
  main = "Profit Margin by Product Category",
  ylab = "Profit Margin (%)",
  border = NA,
  cex.names = 0.85)
text(
  x = bar_positions,
  y = category_plot$profit_margin_pct,
  labels = sprintf("%.2f%%", category_plot$profit_margin_pct),
  pos = 3)


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
getwd()
project_dir <- "/Users/zhangwenlong/Documents/retail-r-analysis"
dir.create(project_dir, recursive = TRUE, showWarnings = FALSE)
setwd(project_dir)
getwd()
l

dir.create("results", showWarnings = FALSE)

write.csv(
  overall_summary,
  "results/overall_summary.csv",
  row.names = FALSE)

write.csv(
  category_summary,
  "results/category_summary.csv",
  row.names = FALSE)

write.csv(
  discount_summary,
  "results/discount_summary.csv",
  row.names = FALSE)

list.files("results")
