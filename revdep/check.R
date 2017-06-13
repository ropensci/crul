library("devtools")

res <- revdep_check(threads = 4, type = "mac.binary", skip = "rgbif")
revdep_check_save_summary()
revdep_check_print_problems()

#revdep_email(date = "May 22", version = "0.3.6", only_problems = FALSE, draft = TRUE)
