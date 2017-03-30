# VHS course "R"Kenntnisse um Wissen aus Daten zu gewinnen 2016
# Beispiel von Hadley Wickham https://www.youtube.com/watch?v=rz3_FDVt9eg

library(gapminder)
library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(broom)
library(purrr)
library(magrittr)


# Print xy plot -----------------------------------------------------------
gapminder
gapminder <- gapminder %>% mutate(year1950 = year -1950)

ggplot(gapminder, aes(x=year, y=lifeExp)) +geom_line(aes(group = country))

# Nested data -------------------------------------------------------------

by_country <- gapminder  %>%
  group_by(continent, country) %>%
  nest()

by_country
str(by_country)
by_country$data[[1]]


# Fit models --------------------------------------------------------------

country_model <- function(df){
  lm(lifeExp  ~  year1950, data=df)  
}

models <- by_country %>%
  mutate(
    model = map(data, country_model)
  )

models
models %>% filter(continent =="Africa")

models$model[[1]]


# Put it all together -----------------------------------------------------

by_country <- gapminder  %>%
  group_by(continent, country) %>%
  nest() %>%  
  mutate(
    model = map(data, country_model)
  )


# Broom for glance tidy and augment ---------------------------------------

models <- models %>%
  mutate(
    glance  = map(model, broom::glance),
    rsq     = glance %>% map_dbl("r.squared"),
    tidy    = map(model, broom::tidy),
    augment = map(model, broom::augment)
  )
models

models %>% arrange(desc(rsq))
models %>% filter(continent=="Africa")

models %>% 
  ggplot(aes(rsq, reorder(country, rsq))) +
  geom_point(aes(colour = continent))
source("gapminderShiny.R")

  models %>% filter((rsq<0.1 & rsq>0))  %>% unnest(rsq)  %>% top_n(6,rsq) %>% unnest(data) %>% 
    ggplot(aes(year, lifeExp)) +
    geom_line(aes( alpha = 1/3))  +
    facet_wrap(~country)
  
  

# Unnest data -------------------------------------------------------------

unnest(models, data)
unnest(models, glance, .drop = TRUE) %>% View()
unnest(models, tidy)

# Plot data frame ---------------------------------------------------------

models %>%
  unnest(tidy) %>%
  select(continent, country, term, estimate, rsq) %>%
  spread(term, estimate) %>%
  ggplot(aes(`(Intercept)`,year1950))+
  geom_point(aes(colour = continent, size = rsq)) +
  geom_smooth(se=FALSE) +
  xlab("Life expectancy (1950)") +
  ylab("Yearly improvement") +
  scale_size_area()


unnest(models, augment)

models %>% unnest(augment) %>% 
  ggplot(aes(year1950, .resid)) +
  geom_line(aes(group = country), alpha = 1/3) +
  geom_smooth(se = FALSE) +
  geom_hline(yintercept = 0, colour = "white") +
  facet_wrap(~continent)

