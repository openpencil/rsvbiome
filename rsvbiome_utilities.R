#### Automatically install and load required packages ####
installpackages <- function(pkgs) {
    pkgs_miss <- pkgs[which(!pkgs %in% installed.packages()[, 1])]
    if (length(pkgs_miss) > 0) {
        install.packages(pkgs_miss, dependencies = T)
    } else if (length(pkgs_miss) == 0) {
        message("\n ...Packages were already installed!\n")
    }
    # load packages not already loaded:
    attached <- search()
    attached_pkgs <- attached[grepl("package", attached)]
    need_to_attach <- pkgs[which(!pkgs %in% gsub("package:", "", attached_pkgs))]
    if (length(need_to_attach) > 0) {
        for (i in 1:length(need_to_attach)) {
            # alternative to library
            require(need_to_attach[i], character.only = TRUE)
        }
    }
    if (length(need_to_attach) == 0) {
        message("\n ...Packages were already loaded!\n")
    }
}

installpackages(c("Hmisc", "mice", "data.table", "plyr", "stringr", "reshape", "reshape2",
                  "scales", "tidyr", "dplyr", "testit", "devtools", "rlecuyer",
                  "gridExtra", "doMC", "parallel", "MASS", "digest", "grid",
                  "assertthat", "lxb", "lubridate", "ggplot2", "corrplot",
                  "colortools", "RColorBrewer"))

#### Set font encoding and locales ####
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")
Sys.setlocale("LC_TIME", "en_US.UTF-8")
Sys.setlocale("LC_COLLATE", "en_US.UTF-8")
Sys.setlocale("LC_MONETARY", "en_US.UTF-8")
Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")


#### Set ggplot themes ####
lightertheme <- theme(panel.background = element_rect(fill = "#f5f5f4", colour = "grey80", size = 0.2),
                      panel.border = element_rect(colour = "grey80", linetype = "solid", fill = NA, size = 0.2),
                      panel.grid.major = element_line(colour = "grey90", size = 0.08),
                      panel.grid.minor = element_line(colour = "grey90", size = 0.08),
                      panel.margin = unit(0.3, "lines"),
                      plot.background = element_rect(fill = "transparent", colour = "transparent"),
                      plot.margin = unit(c(1, 1, 1, 1), "mm"), plot.title = element_text(size = 12),
                      text = element_text(family = "Helvetica", colour = "black", size = 12),
                      strip.background = element_rect(fill = "transparent", color = "transparent", size = 0.08),
                      strip.text.x = element_text(size = 12, colour = "black"),
                      strip.text.y = element_text(size = 12, colour = "black"),
                      axis.text.x = element_text(size = 12, colour = "black"),
                      axis.text.y = element_text(size = 12, colour = "black"),
                      legend.position = "left", legend.background = element_rect(fill = "transparent"),
                      legend.background = element_blank(),
                      legend.key = element_blank(),
                      legend.key.size = unit(0.5,"cm"))


#### Miscellaneous functions ####
tosentencecase <- function(inputstring) {
    substr(inputstring, start = 1, 1) <- toupper(substr(inputstring, start = 1, 1))
    return(inputstring)
}

# ... any number of arguments can be passed.
expand.dataframes <- function(...) {
    # Reduce applies merge to many pairs of dataframes
    out1 <- Reduce(function(...) {
        merge(..., by = NULL)
    }, list(...))
    out2 <- sapply(1:ncol(out1), function(colnum) {
        newdf <- as.character(out1[, colnum])
    })
    colnames(out2) <- colnames(out1)
    return(out2)
}

# load several libraries at onces.
loadlibraries <- function(vectoflibraries) {
    sapply(vectoflibraries, function(libname) {
        library(package = libname, character.only = T)
    })
}
