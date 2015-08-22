## *****************************************************************************************************
## Background: This script was developed to process, extract and normalized cytokine fluorescence data
## from raw lxb format files from multiple Luminex XMap bead assays performed on pediatric nasal washes.
## The Luminex experiments were conducted at the Emory Vaccine Center in collaboration with Vanderbilt
## University. The script is meant to be run in interactive mode. Detailed comments accompany
## the code. UNIX/LINUX shell/command line access is required.
##
## Analysis was performed under the following environment:
##
## > sessionInfo()
## R version 3.2.0 (2015-04-16)
## Platform: x86_64-apple-darwin13.4.0 (64-bit)
## Running under: OS X 10.10.3 (Yosemite)

## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

## attached base packages:
## [1] parallel  grid      stats     graphics  grDevices utils     datasets  methods   base

## other attached packages:
## [1]  formatR_1.2         Cairo_1.5-6         RColorBrewer_1.1-2  colortools_0.1.5    corrplot_0.73
## [6]  lubridate_1.3.3     lxb_1.3             assertthat_0.1      digest_0.6.8        doMC_1.3.3
## [11] iterators_1.0.7     gridExtra_0.9.1     rlecuyer_0.3-3      devtools_1.8.0      testit_0.4
## [16] dplyr_0.4.1         tidyr_0.2.0         scales_0.2.4        reshape2_1.4.1      reshape_0.8.5
## [21] stringr_1.0.0       plyr_1.8.2          data.table_1.9.4    mice_2.22           Rcpp_0.11.6
## [26] randomForest_4.6-10 Hmisc_3.16-0        ggplot2_1.0.1       Formula_1.2-1       survival_2.38-1
## [31] lattice_0.20-31     BoomSpikeSlab_0.5.2 Boom_0.2            MASS_7.3-40         glmnet_2.0-2
## [36] foreach_1.4.2       Matrix_1.2-0

## loaded via a namespace (and not attached):
## [1] splines_3.2.0       colorspace_1.2-6    chron_2.3-45        XML_3.98-1.1        foreign_0.8-63
## [6] DBI_0.3.1           munsell_0.4.2       gtable_0.1.2        codetools_0.2-11    memoise_0.2.1
## [11] latticeExtra_0.6-26 proto_0.3-10        acepack_1.3-3.3     rversions_1.0.0     stringi_0.5-5
## [16] tools_3.2.0         bitops_1.0-6        magrittr_1.5        RCurl_1.95-4.6      cluster_2.0.1
## [21] rpart_4.1-9         nnet_7.3-9          git2r_0.10.1
##
## ******************************************************************************************************
#### 1. Define work directories ####
## Clone the GitHub repository and set it as the work directory
## Command line: git clone git://github.com/openpencil/rsvbiome.git
## cd rsvbiome
setwd(".")

#### 2. Load libraries ####
source("./rsvbiome_utilities.R")

#### 3. Load annotations ####
source("./rsvbiome_annotations.R")

#### 4. Process sample assignment sheet ####
## This is a manually curated list of well locations on the luminex plate
## and names of samples within those wells.
## example format:
## location, sample, filename, dateinsheet, numplex
## 77(1,E10), samplename, somefilenamehere, 15/09/2015, 23

samples_cytokines <- read.csv("./assets/sample_assignment.csv", header = T, sep = ",", as.is = T)
## extract plate location
samples_cytokines$plateloc <- sprintf("P1_%s", gsub("\\d+\\((\\d+)\\,([A-Z]\\d+)\\)",
                                                    "\\2", samples_cytokines$location))
## format dates on the file using as.Date function
samples_cytokines$dateinsheet <- as.Date(x = samples_cytokines$dateinsheet, format = "%d/%m/%Y")
samples_cytokines$dateonfile <- as.Date(x = gsub(".*(x|\\d)\\s+(\\d+\\s+\\d+\\s+\\d+).*",
                                                 "\\2", samples_cytokines$filename), format = "%m %d %y")
samples_cytokines$dateonfile <- as.Date(ifelse(is.na(samples_cytokines$dateonfile),
                                               ifelse(grepl("4plex", samples_cytokines$filename),
                                                      as.Date(x = "5_22_13", format = "%m_%d_%y"),
                                                      ifelse(grepl("25plex", samples_cytokines$filename),
                                                             as.Date(x = "5_23_13", format = "%m_%d_%y"),
                                                             ifelse(grepl("23plex", samples_cytokines$filename),
                                                                    as.Date(x = "5_30_13", format = "%m_%d_%y"), NA))),
                                               samples_cytokines$dateonfile), origin = "1970-01-01")
## generate a plate name
samples_cytokines$plate <- sprintf("Y%02sM%02sD%02sPLEX%02s",
                                   year(samples_cytokines$dateonfile),
                                   month(samples_cytokines$dateonfile),
                                   day(samples_cytokines$dateonfile),
                                   samples_cytokines$numplex)

## generate a hash variable for several attributes
samples_cytokines$dateplexplateloc <- sprintf("Y%02sM%02sD%02sPLEX%02sLOC%s",
                                              year(samples_cytokines$dateonfile),
                                              month(samples_cytokines$dateonfile),
                                              day(samples_cytokines$dateonfile),
                                              samples_cytokines$numplex,
                                              samples_cytokines$plateloc)


#### 5. Read in all lxb files ####
listoflxbfiles <- list.files(path = "./assets/lxb", pattern = "*.lxb", full.names = T, recursive = T)
## check length with length(listoflxbfiles)
lxbfiles <- sapply(listoflxbfiles, function(fname) {
    lxbout <- readLxb(fname, text = T, filter = T)
    return(lxbout)
}, simplify = F)
## check length with length(lxbfiles)

#### 6. Build information sheet for lxb files ####
lxbfileinfo <- data.frame(nlxb = names(lxbfiles), stringsAsFactors = F)
lxbfileinfo$dirname <- gsub(".*\\/lxb\\/(.*)\\/.*", "\\1", lxbfileinfo$nlxb)
lxbfileinfo$datelxb <- as.Date(x = gsub(".*(x|\\d)_(\\d+_\\d+_\\d+)_.*", "\\2", lxbfileinfo$nlxb), format = "%m_%d_%y")
lxbfileinfo$numplex <- sprintf("%02s", gsub(".*_(.*)plex_.*", "\\1", lxbfileinfo$nlxb))
lxbfileinfo$plateloc <- gsub(".*(P1_.*).lxb$", "\\1", lxbfileinfo$nlxb)
lxbfileinfo$dateplex <- sprintf("Y%02sM%02sD%02sPLEX%02s",
                                year(lxbfileinfo$datelxb),
                                month(lxbfileinfo$datelxb),
                                day(lxbfileinfo$datelxb),
                                lxbfileinfo$numplex)

## generate a hash variable for several attributes
lxbfileinfo$dateplexplateloc <- sprintf("%sLOC%s", lxbfileinfo$dateplex, lxbfileinfo$plateloc)

#### 7. Process lxb files ####
## each file is named with the hash variable made of the date, assay and plate location
hashlabel <- lxbfileinfo$dateplexplateloc
names(hashlabel) <- names(lxbfiles)
names(lxbfiles) <- hashlabel[names(lxbfiles)]

## extract just the data portion of the lxbfiles. The text portion consists of
## information that is for review only (i.e. not crucial for the data)
lxbextract <- sapply(lxbfiles, function(lxbcontent) {
    lxbnames <- names(lxbcontent$data)
    out <- lxbcontent$data
    # if a single column vector is read in, convert it back to matrix format
    if (is.null(ncol(out))) {
        dim(out) <- c(1, length(out))
        colnames(out) <- lxbnames
    }
    return(out)
})
## put all lxb data files together
lxbdata <- ldply(lxbextract)
## switch to data.table format
lxbdf <- data.table(lxbdata)
## rename .id column with the hash variable header
setnames(x = lxbdf, ".id", "dateplexplateloc")

#### 8. Merge lxb files and sample information ####
## Cross-check samples across the lxb and the sample csv
## setdiff(samples_cytokines$dateplexplateloc, unique(lxbdf$dateplexplateloc))
## setdiff(unique(lxbfileinfo$dateplexplateloc), samples_cytokines$dateplexplateloc)
## Missing from lxb: N0022, N0131, N0275 because of zero beads
masterlxb <- merge(x = lxbdf, y = samples_cytokines, by = "dateplexplateloc", all.x = T)
# Should have 2889623 rows

## lxb file description generated by the luminex XMap bead assays One CSV per well
## with raw bead level information is generated Bead ID (RID), and fluorescence
## measured (RP1) are variables of interest

## Read in the lxb files gives the following columns
## c('RID', 'DBL', 'DD', 'RP1', 'CL1', 'CL2', 'Aux1', 'TIME') where:
## -- RID:<32 bit unsigned integer> Reporter identifier. Values ranging from [1-500]
## specifies the bead color/region. RID=0 refer to events that flowcytometer/XMap
## bead software was unable to classify.  This is the identifier of the cytokine.
## Also called 'Region ID'
## -- RP1: <32 bit unsigned integer> Reporter fluorescent intensity, quantifies
## transcript abundance of the gene interrogated by the bead. ||| This is the
## raw fluorescence value.
## -- DBL A True/False value for whether the bead falls within the Double
## Discriminator gate. Should be 1 for all good bead values.
## -- DD – A measure of side-scatter. No associated unit.
## -- RP1 – Fluorescent Intensity reported by the Reporter channel (High PMT result)
## -- CL1 – Fluorescent Intensity of the Classification 1 dye
## -- CL2 – Fluorescent Intensity of the Classification 2 dye
## -- AUX1 – An auxiliary channel, unused for any real data

#### 9. Normalize cytokine values ####
## create a data subset for each plate with a list
lxbsplit <- sapply(unique(masterlxb$plate), function(fname) {
    out <- masterlxb[plate == fname]
    return(out)
}, simplify = F)

## function for calculating trimmed mean of a vector of values
trimmedmean <- function(valvector) {
    trimpoints <- quantile(valvector, probs = c(0.025, 1 - 0.025))
    trimvector <- valvector[valvector > trimpoints[1] & valvector < trimpoints[2]]
    if (length(valvector) <= 3) {
        # No need for trimming the mean if there are only three values in the vector
        trimit <- mean(valvector)
    } else {
        trimit <- mean(trimvector)
    }
    return(trimit)
}

## function for subtracting the trimmed mean of the background value from the fluorescence
backgrounddiff <- function(datasubtable, bkdtrimmedmean) {
    # subtract background mean for the cytokine for each flourescence value
    diffvector <- datasubtable$RP1 - bkdtrimmedmean[RID == unique(datasubtable$RID), V1]
    # add the minimum value of difference + a small offset of 0.0001 to make differences positive
    logdiffvector <- log(diffvector - min(diffvector) + 0.0001)
    # calculate the trimmed mean of these differences
    trimmeddiff <- trimmedmean(logdiffvector)
    return(trimmeddiff)
}

## function for normalizing and processing all cytokine values by plate; each plate represents a single assay
normalizecytokines <- function(platename, platedatalist, sampleassignmentsheet) {
    platedata <- data.table(platedatalist[[platename]])
    # Take trimmed mean of the duplicate background wells for each cytokine
    # Background0 is the common name for the background sample
    bkdtrimmedmean <- platedata[sample == "Background0", trimmedmean(RP1), by = RID]
    # for each plate calculate number of beads that fell within the Double Discriminator gate (DBL == 1)
    beadist <- platedata[, sum(DBL), by = plateloc]
    # discard samples/wells that have total number of beads less than the 50 beads
    beadist[, beadcutoff:=50,]
    # in aspirates with lot of mucus, beads stick together into conglomerates and do not attach
    # to the magnet during washing. These wells will typically have a low number of beads.
    keepsamples <- beadist[V1 >= beadcutoff, plateloc]
    lostsamples <- beadist[V1 < beadcutoff, plateloc]
    lostsamplenames <- sampleassignmentsheet[which(sampleassignmentsheet$plateloc %in% lostsamples &
                                                     sampleassignmentsheet$plate == platename), "sample"]
    cat(length(lostsamples),"samples had bead counts below 50 \n")
    # print samplenames that were dropped due to insufficient beads
    cat(lostsamplenames,"\n")
    datatrim <- platedata[plateloc %in% keepsamples]
    # removed the trimmed mean of the background well values from the reported fluorescence
    cytokinevals <- datatrim[, backgrounddiff(.SD, bkdtrimmedmean), by = c("RID", "sample"), .SDcols = c("RID", "RP1")]
    # rename cytokine value column
    setnames(x = cytokinevals, old = "V1", new = "normcyto")
    # add a plate column
    cytokinevals$plate <- platename
    # eliminate the rows for the background and standards
    cytovals <- cytokinevals[cytokinevals$sample %in% grep("Background0|Standard",
                                                           cytokinevals$sample, value = T, invert = T)]
    # incorporate cytokine names | these come from the rsvbiome_annotations.R file
    cytonamevector <- get(paste0("cytokines", unique(platedata$numplex)))
    # add cytokine columns
    cytovals$cytokine <- cytonamevector[as.character(cytovals$RID)]
    # eliminate the RID column
    cytovals$RID <- NULL
    cat(platename, "done. \n")
    return(cytovals)
}

## apply the normalization function over all plates
cytonormalized <- sapply(names(lxbsplit), function(pname) {
    cvals <- normalizecytokines(platename = pname, platedatalist = lxbsplit, sampleassignmentsheet = samples_cytokines)
    return(cvals)
}, simplify = F)

#### Compile final normalized cytokine dataset ####
cytoply <- data.table(ldply(cytonormalized))
## Check number of plates: 15 plates
cytoply[, unique(plate), ]
## Check number of samples: 234 samples
cytoply[, unique(sample), ]
## Check number of cytokines: 53 cytokines with unique names
cytoply[, unique(cytokine), ]

## If one sample has same cytokines from different sheets, paste them together.
pasteit <- function(datasubtable) {
    out <- paste(datasubtable[[1]], collapse = "|")
    return(out)
}
cytovalues <- cytoply[, pasteit(.SD), by = c("sample", "cytokine"), .SDcols = "normcyto"]
cytovalues$V1 <- round(x = as.numeric(cytovalues$V1), 3)
cytoval <- spread(data = cytovalues, key = cytokine, value = V1, fill = NA)

## write out processed cytokines
write.csv(cytoval, "Vanderbilt_cytokine_normalizedvals_V2.csv", row.names = F)

# --------------------------------End of Script---------------------------------#
