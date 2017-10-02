library("devtools")

res <- revdep_check(threads = 4, type = "mac.binary", skip = "rgbif")
revdep_check_save_summary()
revdep_check_print_problems()

revdep_email(date = "Oct 2", version = "0.4.0", only_problems = FALSE, draft = TRUE)

