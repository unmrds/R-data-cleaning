knitr::opts_chunk$set(echo = TRUE)
default_width <- 80
options(width = default_width)

########## Working with a CSV file with structural problems ###################

library(tidyverse)

# Import the source CSV file that contains a structural flaw
# ? what does that path string in the read_csf function mean?
rawDataStruct <- read_csv("../data/learning_struct.csv", 
                    progress = FALSE)

# Display the column definitions for the imported dataset
spec(rawDataStruct)

# Report the problems that were encountered when the data were imported.
problems(rawDataStruct)

# Display the imported table
rawDataStruct

########## Load the full CSV file without the structural error ################

library(tidyverse)

# Import the source CSV file that does not contain the structural problem highlighted above
rawData <- read_csv("../data/learning.csv", 
                    progress = FALSE)

# Display the column definitions for the imported dataset
spec(rawData)

# Report the problems that were encountered when the data were imported.
problems(rawData)

# Display the first few rows of the imported table
head(rawData, n=20)


########## Handling data type errors on import ################################

## Take a look at the types and content of a couple of columns
spec(rawData)
rawData %>%
  select(catalogNumber,textLatDD) %>%       # let's just look at the "catalogNumber" and "textlatDD" columns
  slice_head(n=20)                          # let's just look at the first 20 rows

## Test the creation of a numLatDD column as a numeric column and
## see what rows were converted to NA
rawData %>%
  mutate(numLatDD = as.numeric(rawData$textLatDD)) %>%      # convert all of the values to numbers if possible
  filter(is.na(numLatDD)) %>%                               # select all of the rows in the new numLat column has a NA value
  select(textLatDD, numLatDD) %>%                           # include only the "textLatDD" and "numLatDD" columns
  print() %>%                                               # print the resulting rows and columns
  group_by(textLatDD) %>%                                   # aggregate rows by the content of the "textLatDD" column
  summarize(count = n())                                    # count up the number of values in each group 


## create a numeric column based on the previously tested conversion of 
## the textLatDD column
rawData$numLatDD <- as.numeric(rawData$textLatDD)
head(rawData, n = 20)

## Specify the column data type when importing 
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
head(rawData2, n = 20)

## Convert the catalogNumberTxt column to a character column and see what 
## the result is
rawData %>%
  mutate(catalogNumberTxt = as.character(catalogNumber)) %>%
  filter(is.na(catalogNumberTxt))


########## Check and handle missing values ####################################

## Manually by printing out sum (FALSE = 0, TRUE = 1) of is.na test results
# remember that the paste() function just lets you concatenate pieces of text (or values that can be coerced into text) into a single text string
paste("decimalLatitude: number of NA values", 
      sum(is.na(rawData$decimalLatitude)), 
      sep = " ")
paste("decimalLongitude: number of NA values", 
      sum(is.na(rawData$decimalLongitude)), 
      sep = " ")
paste("weight: number of NA values", 
      sum(is.na(rawData$weight)), 
      sep = " ")
paste("length: number of NA values", 
      sum(is.na(rawData$length)), 
      sep = " ")
paste("sex: number of NA values", 
      sum(is.na(rawData$sex)), 
      sep = " ")
paste("latDMS: number of NA values", 
      sum(is.na(rawData$latDMS)), 
      sep = " ")
paste("lonDMS: number of NA values", 
      sum(is.na(rawData$lonDMS)), 
      sep = " ")
paste("textLatDD: number of NA values", 
      sum(is.na(rawData$textLatDD)), 
      sep = " ")
paste("numLatDD: number of NA values", 
      sum(is.na(rawData$numLatDD)), 
      sep = " ")


## View the combinations of NA values across multiple columns with the 
## md.pattern function from the mice package

library(mice)
options(width = 120)  # set the display width so the text doesn't wrap
par(cex=0.75)   #reduce the default font size so the numbers don't overlap

rawData %>%
  select(decimalLatitude, 
         decimalLongitude, 
         weight, 
         length, 
         sex, 
         latDMS, 
         lonDMS, 
         textLatDD, 
         numLatDD) %>%
  md.pattern(rotate.names = TRUE)

options(width = default_width)

## View the combinations of NA values across multiple columns with the 
## aggr function from the VIM package
library(VIM)

rawData %>%
  select(decimalLatitude, 
         decimalLongitude, 
         weight, 
         length, 
         sex, 
         latDMS, 
         lonDMS, 
         textLatDD, 
         numLatDD) %>%
  rename(latDD = decimalLatitude, lonDD = decimalLongitude) %>%
  aggr(numbers=TRUE)

########## Handling multi-value columns #######################################

## Take a look at the recordedBy, latDMS, and lonDMS columns
rawData %>%
  select(recordedBy, latDMS, lonDMS)

## Define and use some R regular expressions for extracting text from the 
## recordedBy column
collectorExtract <- "^collector\\(s\\):\\s(.*;|.*$)"
preparatorExtract <- "preparator\\(s\\):\\s(.*;|.*$)"

collector_string <- str_match(rawData$recordedBy, collectorExtract)
preparator_string <- str_match(rawData$recordedBy, preparatorExtract)

print(head(collector_string))
print(head(preparator_string))

rawData$collectors <- collector_string[,2]
rawData$preparators <- preparator_string[,2]

# check the first ten rows to see what the output looks like
head(rawData, n=10) %>%
  select(recordedBy, collectors, preparators)

## Define a regular expression and use it to extract pieces from a DMS string
dmsExtract <- "\\s*(-*[:digit:]+)°\\s*([:digit:]+)\\'\\s*([:digit:]+\\.*[:digit:]*)"

latSubstrings <- str_match(rawData$latDMS, dmsExtract)
print(head(latSubstrings))

rawData$latD <- as.numeric(latSubstrings[,2])
rawData$latM <- as.numeric(latSubstrings[,3])
rawData$latS <- as.numeric(latSubstrings[,4])

lonSubstrings <- str_match(rawData$lonDMS, dmsExtract)
print(head(lonSubstrings))

rawData$lonD <- as.numeric(lonSubstrings[,2])
rawData$lonM <- as.numeric(lonSubstrings[,3])
rawData$lonS <- as.numeric(lonSubstrings[,4])


head(rawData, n=10) %>% 
  select(latDMS, latD, latM, latS,
         lonDMS, lonD, lonM, lonS)

########## Check value ranges and explore data ################################

## assert GitHub repository with instructions and examples: 
##      https://github.com/ropensci/assertr
library(assertr)

## you can just run this if you want execution of your workflow to stop if 
## any of your tests fail

# rawData %>% 
#   chain_start %>%
#   assert(within_bounds(1,Inf), weight) %>% # assert checks individual values
#   assert(within_bounds(1,Inf), length) %>%
#   insist(within_n_sds(3), weight) %>% # insist checks against calculated vals
#   insist(within_n_sds(3), length) %>%
#   chain_end

## you can run this if you want to prevent the errors that are generated
## by your tests from halting execution of your workflow
tryCatch({rawData %>%
  slice_sample(n = 1000) %>%                          # limit the example to 1000 randomly selected rows
  chain_start %>%
  assert(within_bounds(1,Inf), weight) %>%            # assert checks individual values
  assert(within_bounds(1,Inf), length) %>%
  insist(within_n_sds(3), weight) %>%                 # insist checks against calculated vals
  insist(within_n_sds(3), length) %>%
  chain_end
}, warning = function(w) {
    paste("A warning was generated: ", w, sep = "")
}, error = function(e) {
    print(e)
}, finally = {
    print("this is the end of the validation check ...")
  }
)

## Visual assessment of your data 
library(ggplot2)

ggplot(rawData, aes(x=weight)) +
  geom_histogram(binwidth = 5)
ggplot(rawData, aes(x=length)) +
  geom_histogram(binwidth = 5)
  

###############################################################################
########## Bringing it all together into a single series of commands ##########

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

collector_string <- str_match(rawData$recordedBy, collectorExtract)
preparator_string <- str_match(rawData$recordedBy, preparatorExtract)

rawData$collectors <- collector_string[,2]
rawData$preparators <- preparator_string[,2]

# split up the latDMS and lonDMS columns
dmsExtract <- "\\s*(-*[:digit:]+)°\\s*([:digit:]+)\\'\\s*([:digit:]+\\.*[:digit:]*)"

latSubstrings <- str_match(rawData$latDMS, dmsExtract)

rawData$latD <- as.numeric(latSubstrings[,2])
rawData$latM <- as.numeric(latSubstrings[,3])
rawData$latS <- as.numeric(latSubstrings[,4])

lonSubstrings <- str_match(rawData$lonDMS, dmsExtract)

rawData$lonD <- as.numeric(lonSubstrings[,2])
rawData$lonM <- as.numeric(lonSubstrings[,3])
rawData$lonS <- as.numeric(lonSubstrings[,4])

glimpse(analysisData)


library(knitr)
purl("cleaning_data.Rmd", "cleaning_data_nodocs.R", documentation = 0)
