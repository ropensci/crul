`%||%` <- function(x, y) if (is.null(x)) y else x

ccp <- function(x) Filter(Negate(is.null), x)
