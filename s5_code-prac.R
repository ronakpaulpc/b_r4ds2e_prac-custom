# Here we run and practice specific code chunks from the book R4DS 2E.
# This book was written by Hadley and Wickham.
# For practice the script files are created for each book section.
# This script file pertains to chapters from Section 5 - Program.



#_====
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# C26 - Iteration ---------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Here we learn tools for iteration, repeatedly performing the same action 
# on different objects. Iteration in R generally tends to look rather 
# different from other programming languages because so much of it is 
# implicit and we get it for free.


# 26.1 Prerequisites ------------------------------------------------------
library(tidyverse)
library(readxl)
library(here)
library(rio)


# 26.2 Modifying multiple columns -----------------------------------------
df <- tibble(
    a = rnorm(10),
    b = rnorm(10),
    c = rnorm(10),
    d = rnorm(10)
)
df

# Summarizing with manual copy-paste
df |> summarize(
    n = n(),
    a = median(a),
    b = median(b),
    c = median(c),
    d = median(d)
)
# Altly, summarizing with iteration
df |> summarize(
    n = n(),
    across(.cols = a:d, median)
)


# ** 26.2.1 Selecting columns with .cols ====

# TBC ####



# 26.3 Reading multiple files ---------------------------------------------
# Here we learn how to use purrr::map() to do something to every file in a 
# directory. Let’s start with a little motivation: Let's say we wanted to 
# manually read a directory full of excel sheets.
# We could copy-paste code like this:
data2019 <- read_excel("data/y2019.xlsx")
data2020 <- read_excel("data/y2020.xlsx")
data2021 <- read_excel("data/y2021.xlsx")
data2022 <- read_excel("data/y2022.xlsx")
# And then use dplyr::bind_rows() to combine them all together:
data <- bind_rows(data2019, data2020, data2021, data2022)
data |> head() |> view()
# However, this would get tedious, specially if you had hundreds of files. 
# Hence we learn how to automate this sort of task.


# ** 26.3.1 Listing files in a directory ====
paths <- list.files("data/gapminder", pattern = "[.]xlsx$", full.names = T)
paths


# ** 26.3.2 Lists ====
# Now that we have these 12 paths, we could call read_excel() 12 times 
# to get 12 dataframes.
gapminder_1952 <- read_excel("data/gapminder/1952.xlsx")
gapminder_1957 <- read_excel("data/gapminder/1957.xlsx")
gapminder_1962 <- read_excel("data/gapminder/1962.xlsx")
gapminder_1967 <- read_excel("data/gapminder/1967.xlsx")
gapminder_1972 <- read_excel("data/gapminder/1972.xlsx")
gapminder_1977 <- read_excel("data/gapminder/1977.xlsx")
gapminder_1982 <- read_excel("data/gapminder/1982.xlsx")
gapminder_1987 <- read_excel("data/gapminder/1987.xlsx")
gapminder_1992 <- read_excel("data/gapminder/1992.xlsx")
gapminder_1997 <- read_excel("data/gapminder/1997.xlsx")
gapminder_2002 <- read_excel("data/gapminder/2002.xlsx")
gapminder_2007 <- read_excel("data/gapminder/2007.xlsx")
# It will be easier to work with if we put them into a single object.
files <- list(
    read_excel("data/gapminder/1952.xlsx"),
    read_excel("data/gapminder/1957.xlsx"),
    read_excel("data/gapminder/1962.xlsx"),
    read_excel("data/gapminder/1967.xlsx"),
    read_excel("data/gapminder/1972.xlsx"),
    read_excel("data/gapminder/1977.xlsx"),
    read_excel("data/gapminder/1982.xlsx"),
    read_excel("data/gapminder/1987.xlsx"),
    read_excel("data/gapminder/1992.xlsx"),
    read_excel("data/gapminder/1997.xlsx"),
    read_excel("data/gapminder/2002.xlsx"),
    read_excel("data/gapminder/2007.xlsx")
)
files[[3]]


# ** 26.3.3 purrr::map() and list_rbind() ====



























































