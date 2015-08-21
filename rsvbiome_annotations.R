#### Load annotations for cytokine files ####
## Assay information
plex <- sprintf("%02s", c(4, 23, 25, 30))
plex <- c(4, 23, 25, 30)
nameplex <- c("Growth Factor Human 4-Plex Panel for Luminex Platform",
              "MILLIPLEX MAP Human Cytokine/Chemokine Magnetic Bead Panel II - Premixed 23 Plex",
              "Cytokine Human Magnetic 25-Plex Panel for Luminex Platform",
              "Cytokine Human Magnetic 30-Plex Panel for Luminex Platform")
urlplex <- c("http://www.lifetechnologies.com/order/catalog/product/LHC0004?CID=exa",
             "http://www.emdmillipore.com/US/en/product/MILLIPLEX-MAP-Human-CytokineChemokine-Magnetic-Bead-Panel-II---Premixed-23-Plex---Immunology-Multiplex-Assay,MM_NF-HCP2MAG-62K-PX23#documentation",
             "https://www.lifetechnologies.com/order/catalog/product/LHC0009M", "https://www.lifetechnologies.com/order/catalog/product/LHC6003M")
names(nameplex) <- plex
names(urlplex) <- plex

## Command-line generation of these concatenated vectors
## cat beadcytokineinfo | perl -ne '@fields=split(/\s/,$_); for (my $i = 0; $i < scalar@fields; ++$i){print '\''.$fields[$i].'\''.', '};' | pbcopy

## "Growth Factor Human 4-Plex Panel for Luminex Platform"
cytokines4 <- c("VEGF", "G-CSF", "EGF", "FGF-Basic")
beadid4 <- c("5", "7", "8", "12")
names(cytokines4) <- beadid4

## "MILLIPLEX MAP Human Cytokine/Chemokine Magnetic Bead Panel II - Premixed 23 Plex",
cytokines23 <- c("Eotaxin-2", "MCP-2", "BCA-1", "MCP-4", "I-309", "IL-16", "TARC",
                 "6CKine", "Eotaxin-3", "LIF", "TPO", "SCF", "TSLP", "IL-33", "IL-20",
                 "IL-21", "IL-23", "TRAIL", "CTACK", "SDF-1a+b", "ENA-78", "MIP-1d",
                 "IL-28A")
beadid23 <- c("12", "13", "15", "18", "19", "21", "26",
              "28", "30", "34", "36", "38", "43", "45", "51",
              "52", "54", "56", "62", "64", "66", "76",
              "77")
names(cytokines23) <- beadid23

## "Cytokine Human Magnetic 25-Plex Panel for Luminex Platform",
cytokines25 <- c("IL-1B", "IL-10", "IL-13", "IL-6", "IL-12", "RANTES", "Eotaxin",
                 "IL-17", "MIP-1a", "GM-CSF", "MIP-1B", "MCP-1", "IL-15", "IL-5",
                 "IFN-y", "IFN-a", "IL-1RA", "TNF-a", "IL-2", "IL-7", "IP-10",
                 "IL-2R", "MIG", "IL-4", "IL-8")
beadid25 <- c("13", "15", "18", "19", "20", "21", "22",
              "25", "26", "27", "28", "29", "30", "34",
              "38", "43", "51", "52", "54", "55", "56",
              "61", "63", "77", "78")
names(cytokines25) <- beadid25

## "Cytokine Human Magnetic 30-Plex Panel for Luminex Platform"
cytokines30 <- c("FGF-Basic", "IL-1B", "G-CSF", "IL-10", "IL-13", "IL-6", "IL-12",
                 "RANTES", "Eotaxin", "IL-17", "MIP-1a", "GM-CSF", "MIP-1B", "MCP-1",
                 "IL-15", "EGF", "IL-5", "HGF", "VEGF", "IFN-y", "IFN-a", "IL-1RA",
                 "TNF-a", "IL-2", "IL-7", "IP-10", "IL-2R", "MIG", "IL-4", "IL-8")
beadid30 <- c("12", "13", "14", "15", "18", "19", "20", "21", "22", "25", "26", "27",
              "28", "29", "30", "33", "34", "35", "36", "38", "43", "51", "52", "54",
              "55", "56", "61", "63", "77", "78")
names(cytokines30) <- beadid30
