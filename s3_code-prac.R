# Here we run and practice specific code chunks from the book R4DS 2E.
# This book was written by Hadley and Wickham.
# For practice the script files are created for each book section.
# This script file pertains to chapters from Section 3 - Transform.



#_====
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
# The rest of this chapter uses forcats::gss_cat. It’s a sample of data 
# from the General Social Survey. The survey has thousands of questions. 
# So in gss_cat Hadley selected a handful that will illustrate some 
# common challenges you’ll encounter when working with factors.
gss_cat
help("gss_cat")
glimpse(gss_cat)

# When factors are stored in a tibble, you can’t see their levels so easily.
# One way to view them is with count():
gss_cat |> count(marital)
gss_cat |> count(race)
gss_cat |> count(relig)

# gss_cat |> fct_count(race)        # gives error
fct_count(gss_cat$race)             # but this works


# 16.4 Modifying the factor order -----------------------------------------
# It’s often useful to change the order of factor levels in a visualization. 
# For example, imagine you want to explore the average number of hours spent 
# watching TV per day across religions:
relig_summary <- gss_cat |> 
    group_by(relig) |> 
    summarize(
        tvhours = mean(tvhours, na.rm = T),
        n = n()
    )
ggplot(data = relig_summary, aes(x = tvhours, y = relig)) +
    geom_point()
# It is hard to read this plot because there’s no overall pattern.

# We can improve it by reordering the levels of relig using fct_reorder().
ggplot(
    data = relig_summary, 
    aes(x = tvhours, y = fct_reorder(relig, tvhours))
) +
    geom_point()

# As you start making more complicated transformations, we recommend
# moving them out of aes() and into a separate mutate() step.
relig_summary |> 
    mutate(relig = fct_reorder(relig, tvhours)) |> 
    ggplot(aes(x = tvhours, y = relig)) +
    geom_point()

# What if we create a similar plot looking at how average age 
# varies across reported income level?
rincome_summary <- gss_cat |> 
    group_by(rincome) |> 
    summarize(
        age = mean(age, na.rm = T),
        n = n()
    )
rincome_summary
ggplot(
    data = rincome_summary, 
    aes(x = age, y = fct_reorder(rincome, age))
) +
    geom_point()
# Here, arbitrarily reordering the levels isn’t a good idea! That’s because 
# rincome already has a principled order that we shouldn’t mess with.

# However, it does make sense to pull “Not applicable” to the front with 
# the other special levels. You can use fct_relevel() for that.
ggplot(
    data = rincome_summary, 
    aes(x = age, y = fct_relevel(rincome, "Not applicable"))
) +
    geom_point()

# Another reordering type is useful when you are coloring the lines on a plot. 
# fct_reorder2(.f, .x, .y) reorders the factor .f by the .y values associated 
# with the largest .x values.
by_age <- gss_cat |> 
    filter(!is.na(age)) |> 
    count(age, marital) |> 
    group_by(age) |> 
    mutate(prop = n / sum(n))
by_age

ggplot(data = by_age, aes(x = age, y = prop, colour = marital)) +
    geom_line(linewidth = 1.5) +
    scale_colour_brewer(palette = "Set1") +
    labs(colour = "Marital")

ggplot(
    data = by_age,
    aes(x = age, y = prop, colour = fct_reorder2(marital, age, prop))
) +
    geom_line(linewidth = 1.5) +
    scale_color_brewer(palette = "Set1") +
    labs(colour = "Marital")

# Finally, for bar plots, you can use fct_infreq() to order levels in 
# decreasing frequency.
gss_cat |> ggplot(aes(x = marital)) + geom_bar()
gss_cat |> 
    mutate(marital = fct_infreq(marital)) |> 
    ggplot(aes(x = marital)) + geom_bar()
# Combine it with fct_rev() if you want them in increasing frequency.
gss_cat |> 
    mutate(marital = marital |> fct_infreq() |> fct_rev()) |> 
    ggplot(aes(x = marital)) + geom_bar()


# Modifying factor levels -------------------------------------------------
# More powerful than changing the level orders is changing their values. 
# This allows you to clarify labels for publication, and collapse levels 
# for high-level displays. 

# The most general and powerful tool is fct_recode(). It allows you to 
# recode, or change, the value of each level.
gss_cat |> count(partyid)
# The levels in partyid var are terse and inconsistent. 

# Let’s tweak them to be longer and clearer. Like other tidyverse fns, the 
# new values go on the left and the old values go on the right.
gss_cat |> 
    mutate(
        partyid = fct_recode(
            partyid,
            "Republican, strong"    = "Strong republican",
            "Republican, weak"      = "Not str republican",
            "Independent, near rep" = "Ind,near rep",
            "Independent, near dem" = "Ind,near dem",
            "Democrat, weak"        = "Not str democrat",
            "Democrat, strong"      = "Strong democrat"
        )
    ) |> 
    count(partyid)
# fct_recode() will leave the levels that aren’t explicitly mentioned as is
# and will warn you if you accidentally refer to a level that doesn’t exist.

# To combine groups assign multiple old levels to the same new level:
gss_cat |> 
    mutate(
        partyid = fct_recode(
            partyid,
            "Republican, strong"    = "Strong republican",
            "Republican, weak"      = "Not str republican",
            "Independent, near rep" = "Ind,near rep",
            "Independent, near dem" = "Ind,near dem",
            "Democrat, weak"        = "Not str democrat",
            "Democrat, strong"      = "Strong democrat",
            "Other"                 = "No answer",
            "Other"                 = "Don't know",
            "Other"                 = "Other party"
        )
    ) |> 
    count(partyid)

# Use fct_collapse() if you want to collapse a lot of levels.
gss_cat |> mutate(
    partyid = fct_collapse(
        partyid,
        "Other"         = c("No answer", "Don't know", "Other party"),
        "Republican"    = c("Strong republican", "Not str republican"),
        "Independent"   = c("Ind,near dem", "Ind,near rep", "Independent"),
        "Democrat"      = c("Strong democrat", "Not str democrat")
    )
) |> 
    count(partyid)

# Sometimes you just want to lump together the small groups to make a plot 
# or table simpler. That’s the job of the fct_lump_*() family of functions.
# fct_lump_lowfreq() progressively lumps the smallest groups categories 
# into “Other”, always keeping “Other” as the smallest category.
gss_cat |> count(relig)
gss_cat |> mutate(
    relig = fct_lump_lowfreq(relig)
) |> 
    count(relig)

# We can use the fct_lump_n() to specify that we want exactly n groups:
gss_cat |> mutate(
    relig = fct_lump_n(relig, n = 10)
) |> 
    count(relig)


# 16.6 Ordered factors ----------------------------------------------------
x <- ordered(c("a", "b", "c"))
x


# 16.7 Summary ------------------------------------------------------------
# NO CODE.




# TBC ####



