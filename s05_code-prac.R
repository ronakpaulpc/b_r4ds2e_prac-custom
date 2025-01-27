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
# library(tidyverse)
# library(readxl)
# library(here)
# library(rio)
# library(vctrs)

library(easypackages)
libraries("tidyverse", "readxl", "here", "rio", "vctrs")


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
# The code to collect those data frames in a list “by hand” is basically 
# just as tedious to type as code that reads the files one-by-one. Happily 
# we can use purrr::map(). map() is similar to across(), but instead of doing 
# something to each column in a dataframe, it does something to each element 
# of a vector.

# We use map() to get a list of 12 dataframes.
files <- map(paths, read_excel)
length(files)
files[[1]]
# Now we combine that list of data frames into a single dataframe.
list_rbind(files)
# Altly, we could do both steps at once in a pipeline:
paths |> 
    map(read_excel) |> 
    list_rbind()

# If we need to pass extra arguments to read_excel we need to use it in
# the functional form.
paths |> 
    map(
        function(path) read_excel(path, n_max = 1)
    ) |> 
    list_rbind()


# ** 26.3.4 Data in the path ====
# Sometimes the name of the file is data itself. To get that column into 
# the final dataframe, we need to do two things:

# First, we name the vector of paths using set_names() and basename().
# Use this code
paths |> set_names(basename)
# ERROR: When used with map() as the path is shortened and gives error.
# paths |> basename() |> set_names()
# Those names are automatically carried along by all the map functions 
# so the list of data frames will have those same names.
files <- paths |> 
    set_names(basename) |> 
    map(read_excel)
# We can also use [[ to extract elements by name.
files[[3]]
files[["1962.xlsx"]]

# Then we use the names_to argument to list_rbind() to tell it to save the 
# names into a new column called year then use readr::parse_number() to 
# extract the number from the string.
paths |> 
    set_names(basename) |> 
    map(read_excel) |> 
    list_rbind(names_to = "year") |> 
    mutate(year = parse_number(year))

# In more complicated cases, there might be other variables stored in the 
# directory name, or maybe the file name contains multiple bits of data. 
# In that case, use set_names() (without any arguments) to record the 
# full path, and then use tidyr::separate_wider_delim() and friends to 
# turn them into useful columns.
paths |> 
    set_names() |> 
    map(read_excel) |> 
    list_rbind(names_to = "year") |> 
    separate_wider_delim(year, delim = "/", names = c(NA, "dir", "file")) |> 
    separate_wider_delim(file, delim = ".", names = c("file", "ext")) |> 
    mutate(year = parse_number(file)) |> 
    select(-c(dir, file, ext))


# ** 26.3.5 Save your work ====
# After getting a nice tidy data frame, it’s a great time to save your work:
gapminder <- paths |> 
    set_names(basename) |> 
    map(read_excel) |> 
    list_rbind(names_to = "year") |> 
    mutate(year = parse_number(year))
gapminder
write_csv(gapminder, "gapminder.csv")
# Now when you come back to this problem in the future, you can read in a 
# single csv file. 


# ** 26.3.6 Many simple iterations ====
# Here we were lucky enough to get a tidy dataset. In most cases, you will
# need to do some additional tidying. There are two ways.

# Do one round of iteration with a complex function.
paths
process_file <- function(path) {
    df <- read_csv(path)
    df |> 
        filter(!is.na(id)) |> 
        mutate(id = tolower(id)) |> 
        pivot_longer(jan:dec, names_to = "month")
}
paths |> 
    map(process_file) |> 
    list_rbind()

# Do multiple rounds of iteration with simple functions.
paths |> 
    map(read_csv) |> 
    map(\(df) df |> filter(!is.na(id))) |> 
    map(\(df) df |> mutate(id = to_lower(id))) |> 
    map(\(df) df |> pivot_longer(jan:dec, names_to = "month"))
# We recommend this approach because it stops you getting fixated on getting 
# the first file right before moving on to the rest. By considering all of 
# the data when doing tidying and cleaning, you’re more likely to think 
# holistically and end up with a higher quality result.

# Altly, we could optimize, by binding all the dataframes together earlier. 
# Then you can rely on regular dplyr behaviour:
paths |> 
    map(read_csv) |> 
    list_rbind() |> 
    filter(!is.na(id)) |> 
    mutate(id = tolower(id)) |> 
    pivot_longer(jan:dec, names_to = "month")


# ** 26.3.7 Heterogeneous data ====
# Sometimes it’s not possible to go from map() straight to list_rbind() 
# because the data frames are so heterogeneous that list_rbind() either 
# fails or yields a data frame that’s not very useful.

# It’s still useful to start by loading all of the files:
files <- paths |> 
    set_names(basename) |> 
    map(read_excel)

# Then a very useful strategy is to capture the structure of the dataframes 
# so that you can explore it using your data science skills. One way to do 
# so is with this handy df_types function6 that returns a tibble with 
# one row for each column:
df_types <- function(df) {
    tibble(
        col_names = names(df),
        col_type = map_chr(df, vctrs::vec_ptype_full),
        n_miss = map_int(df, \(x) sum(is.na(x)))
    )
}
df_types(gapminder)
# This makes it easy to verify whether the gapminder spreadsheets are 
# heterogeneous.
files |> 
    map(df_types) |> 
    list_rbind(names_to = "file_name") |> 
    select(-c(n_miss)) |> 
    pivot_wider(names_from = col_names, values_from = col_type)
# If the files have heterogeneous formats, you might need to do more 
# processing before you can successfully merge them. 


# ** 26.3.8 Handling failures ====
# TBC ####


# 26.4 Saving multiple outputs --------------------------------------------
# Here we learn how to take one or more R objects and save it into one 
# or more files. We’ll explore this challenge using three examples:
# 1. Saving multiple data frames into one database.
# 2. Saving multiple data frames into multiple .csv files.
# 3. Saving multiple plots to multiple .png files.


# 26.4.1 Writing to a database ====
# TBC ####


# 26.4.2 Writing csv files ====
# Let’s imagine that we want to take the ggplot2::diamonds data and save 
# one csv file for each clarity. Let's checkout the dataset.
diamonds |> glimpse()
diamonds |> count(clarity)

# First, we need to make those individual datasets. There’s one way we 
# particularly like: group_nest().
by_clarity <- diamonds |> 
    group_nest(clarity, keep = T)
by_clarity
# This gives us a new tibble with eight rows and two columns. clarity is our 
# grouping variable and data is a list-column containing one tibble for each 
# unique value of clarity.
by_clarity$data[[1]]

# Second, let’s create a column that gives the name of output file.
by_clarity <- by_clarity |> 
    mutate(
        path = str_glue("c26-diamonds-{clarity}.csv")
    )
by_clarity
# So if we were going to save these data frames by hand, we might write 
# something like:
write_csv(by_clarity$data[[1]], by_clarity$path[[1]])
write_csv(by_clarity$data[[2]], by_clarity$path[[2]])
write_csv(by_clarity$data[[3]], by_clarity$path[[3]])
write_csv(by_clarity$data[[4]], by_clarity$path[[4]])
write_csv(by_clarity$data[[5]], by_clarity$path[[5]])
write_csv(by_clarity$data[[6]], by_clarity$path[[6]])
write_csv(by_clarity$data[[7]], by_clarity$path[[7]])
write_csv(by_clarity$data[[8]], by_clarity$path[[8]])
# There are two arguments that are changing, not just one. That means we need 
# a new function: map2(), which varies both the first and second arguments.
map2(by_clarity$data, by_clarity$path, write_csv)


# ** 26.4.3 Saving plots ====
# We can take the same basic approach to create many plots. 
# Let’s first make a function that draws the plot we want:
carat_histogram <- function(df) {
    ggplot(df, aes(x = carat)) + 
        geom_histogram(binwidth = 0.1)
}
carat_histogram(by_clarity$data[[1]])
# Now we can use map() to create a list of many plots and their eventual 
# file paths:
by_clarity <- by_clarity |> 
    mutate(
        plot = map(data, carat_histogram),
        path = str_glue("c26-clarity-{clarity}.png")
    )
by_clarity
print(by_clarity$plot)

# Then we use map2/walk2 with each plot to save output:
map2(
    by_clarity$path, by_clarity$plot,
    \(path, plot) ggsave(path, plot, width = 6, height = 6)
)


# 26.5 Summary ------------------------------------------------------------
# NO CODE.









































