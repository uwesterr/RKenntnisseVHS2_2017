---
title: "plotly"
author: "Uwe Sterr"
date: "July 15, 2016"
output: html_document
---

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:


```r
library(plotly)
```

```
## Loading required package: ggplot2
```

```
## 
## Attaching package: 'plotly'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     last_plot
```

```
## The following object is masked from 'package:graphics':
## 
##     layout
```

```r
plot_ly(economics, x = date, y = unemploy / pop, color = pop, mode = "markers")
```

preserveedb1dc02bfc79e1e
