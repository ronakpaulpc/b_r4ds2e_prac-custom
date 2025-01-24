# Script file for highlighting code errors and its solution



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# C26 - Iteration ---------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# 26.2 Modifying multiple columns -----------------------------------------
# ERROR: Extra comma in code
df |> summarize(
    n = n(),
    across(a:d, median),
)























