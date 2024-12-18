# Here we run and practice specific code chunks from the book R4DS 2E.
# This book was written by Hadley and Wickham.
# For practice the script files are created for each book section.
# This script file pertains to chapters from Section 3 - Transform.




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# C16 - Factors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Factors are used for categorical variables, variables that have a fixed 
# and known set of possible values. They are also useful when you want 
# to display character vectors in a non-alphabetical order.

# 16.1 Prerequisites ------------------------------------------------------
library(tidyverse)


# 16.2 Factor basics ------------------------------------------------------
x1 <- c("Dec", "Apr", "Jan", "Mar")
x2 <- c("Dec", "Apr", "Jam", "Mar")
sort(x1)
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
y1 <- factor(x1, levels = month_levels)
y1

# Any values not in the level will be silently converted to NA.
y2 <- factor(x2, levels = month_levels)
y2
# This seems risky, so you might want to use forcats::fct() instead.
y2 <- fct(x2, levels = month_levels)

# If you omit the levels, they will be taken from the data 
# in alphabetical order:
factor(x1)
# Sorting alphabetically is slightly risky because not every computer 
# will sort strings in the same way. 
# So forcats::fct() orders by first appearance:
fct(x1)

# If you ever need to access the set of valid levels directly 
# you can do so with levels():
levels(y2)

# You can also create a factor when reading your data with readr 
# with col_factor():
csv <- "
month,value
Jan,12
Feb,56
Mar,12"
csv         # check
# Import
df <- read_csv(csv, col_types = cols(month = col_factor(month_levels)))
df          # check
df$month    # check


# 16.3 General Social Survey ----------------------------------------------
# TBC ####



