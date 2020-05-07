knitr::opts_chunk$set(echo = TRUE)

library(tidyverse)

# Import the source CSV file that contains a structural flaw
rawDataStruct <- read_csv("../data/learning_struct.csv", 
                    progress = FALSE)

# Display the column definitions for the imported dataset
spec(rawDataStruct)

# Report the problems that were encountered when the data were imported.
problems(rawDataStruct)

# Display the imported table
rawDataStruct

library(tidyverse)

# Import the source CSV file that does not contain the structural problem highlighted above
rawData <- read_csv("../data/learning.csv", 
                    progress = FALSE)

# Display the column definitions for the imported dataset
spec(rawData)

# Report the problems that were encountered when the data were imported.
problems(rawData)

# Display the imported table
rawData

spec(rawData)
rawData %>%
  select(catalogNumber,textLatDD)

# test the creation of a numLatDD column as a numeric column and see what rows were converted to NA
rawData %>%
  mutate(numLatDD = as.numeric(rawData$textLatDD)) %>%
  filter(is.na(numLatDD)) %>%
  select(textLatDD, numLatDD) %>%
  print() %>%
  group_by(textLatDD) %>%
  summarize(count = n()) 


# create a numeric column based on the previously tested conversion of the textLatDD column
rawData$numLatDD <- as.numeric(rawData$textLatDD)
rawData

rawData2 <- read_csv("../data/learning.csv", 
                     col_types = cols(
                        textLatDD = col_double()
                        ),
                     progress = FALSE)

# Display the column definitions for the imported dataset
spec(rawData2)

# Report the problems that were encountered when the data were imported.
problems(rawData2)

# Display the imported table
rawData2

# convert the catalogNumberTxt column to a character column and see what the result is
rawData %>%
  mutate(catalogNumberTxt = as.character(catalogNumber)) %>%
  filter(is.na(catalogNumberTxt))


paste("decimalLatitude: number of NA values", sum(is.na(rawData$decimalLatitude)), sep = " ")
paste("decimalLongitude: number of NA values", sum(is.na(rawData$decimalLongitude)), sep = " ")
paste("weight: number of NA values", sum(is.na(rawData$weight)), sep = " ")
paste("length: number of NA values", sum(is.na(rawData$length)), sep = " ")
paste("sex: number of NA values", sum(is.na(rawData$sex)), sep = " ")
paste("latDMS: number of NA values", sum(is.na(rawData$latDMS)), sep = " ")
paste("lonDMS: number of NA values", sum(is.na(rawData$lonDMS)), sep = " ")
paste("textLatDD: number of NA values", sum(is.na(rawData$textLatDD)), sep = " ")
paste("numLatDD: number of NA values", sum(is.na(rawData$numLatDD)), sep = " ")


options(width = 120)
library(mice)
library(VIM)

rawData %>%
  select(decimalLatitude, decimalLongitude, weight, length, sex, latDMS, lonDMS, textLatDD, numLatDD) %>%
  md.pattern(rotate.names = TRUE)

rawData %>%
  select(decimalLatitude, decimalLongitude, weight, length, sex, latDMS, lonDMS, textLatDD, numLatDD) %>%
  rename(latDD = decimalLatitude, lonDD = decimalLongitude) %>%
  aggr(numbers=TRUE)

rawData %>%
  select(recordedBy, latDMS, lonDMS)

collectorExtract <- "^collector\\(s\\):\\s(.*;|.*$)"
preparatorExtract <- "preparator\\(s\\):\\s(.*;|.*$)"
#str_match(rawData$recordedBy, collectorExtract)[,2]
#str_match(rawData$recordedBy, preparatorExtract)[,2]
rawData$collectors <- str_match(rawData$recordedBy, collectorExtract)[,2]
rawData$preparators <- str_match(rawData$recordedBy, preparatorExtract)[,2]

dmsExtract <- "\\s*(-*[:digit:]+)°\\s*([:digit:]+)\\'\\s*([:digit:]+)"

latSubstrings <- str_match(rawData$latDMS, dmsExtract)
rawData$latD <- as.numeric(latSubstrings[,2])
rawData$latM <- as.numeric(latSubstrings[,3])
rawData$latS <- as.numeric(latSubstrings[,4])

glimpse(latSubstrings)

lonSubstrings <- str_match(rawData$lonDMS, dmsExtract)
rawData$lonD <- as.numeric(lonSubstrings[,2])
rawData$lonM <- as.numeric(lonSubstrings[,3])
rawData$lonS <- as.numeric(lonSubstrings[,4])

glimpse(lonSubstrings)

glimpse(rawData)

#library(assertr)
#
#rawData %>%
#  chain_start %>%
#  assert(within_bounds(1,Inf), weight) %>%
#  assert(within_bounds(1,Inf), length) %>%
#  insist(within_n_sds(3), weight) %>%
#  insist(within_n_sds(3), length) %>%
#  chain_end


library(ggplot2)
ggplot(rawData, aes(x=weight)) +
  geom_histogram(binwidth = 5)
ggplot(rawData, aes(x=length)) +
  geom_histogram(binwidth = 5)
  

# import the data with explicit column definitions for the textLatDD and catalogNumber columns
analysisData <- read_csv("../data/learning.csv", 
                     col_types = cols(
                        textLatDD = col_double(), 
                        catalogNumber = col_character()
                        ),
                     progress = FALSE)

# split up the recordedBy column
collectorExtract <- "^collector\\(s\\):\\s(.*;|.*$)"
preparatorExtract <- "preparator\\(s\\):\\s(.*;|.*$)"
analysisData$collectors <- str_match(analysisData$recordedBy, collectorExtract)[,2]
analysisData$preparators <- str_match(analysisData$recordedBy, preparatorExtract)[,2]

# split up the latDMS and lonDMS columns
dmsExtract <- "\\s*(-*[:digit:]+)°\\s*([:digit:]+)\\'\\s*([:digit:]+)"

latSubstrings <- str_match(analysisData$latDMS, dmsExtract)
analysisData$latD <- as.numeric(latSubstrings[,2])
analysisData$latM <- as.numeric(latSubstrings[,3])
analysisData$latS <- as.numeric(latSubstrings[,4])

lonSubstrings <- str_match(analysisData$lonDMS, dmsExtract)
analysisData$lonD <- as.numeric(lonSubstrings[,2])
analysisData$lonM <- as.numeric(lonSubstrings[,3])
analysisData$lonS <- as.numeric(lonSubstrings[,4])

glimpse(analysisData)


#library(knitr)
#purl("cleaning_data.Rmd", "cleaning_data_nodocs.R", documentation = 0)
