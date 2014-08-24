#############################################################################
#
# Course project, Getting And Cleaning Data
# by Daniel Östling 2014
#
# This program should work with only base R, no libraries needed.
#
# The goals of this program are:
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each 
#    measurement.
# 3. Use descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names.
# 5. Create a second, independent tidy data set with the average of each 
#    variable for each activity and each subject.
#


#############################################################################
# danielostling: Set the base path below in the main function.

main <- function() {
  # danielostling: Set the base path of the unpacked data archive. See 
  # README.md if you are unsure what value to set here.
  vecCharDataPath <- "UCI HAR Dataset"

  # danielostling: Read and manipulate the data sets.
  dfCombined <- readAndPrepareDataFiles(vecCharDataPath)
  dfCombined <- renameActivities(dfCombined, vecCharDataPath)
  dfCombined <- summarizeData(dfCombined)

  # danielostling: Write the resulting combined and tidy data frame to disk.
  write.table(
      dfCombined, 
      file="Getting_and_Cleaning_Data_tidy.txt", 
      row.names=FALSE)
}

#############################################################################
# danielostling: Supporting functions below this point.


# danielostling: Read data files, merge and label them, and return the merged 
# data frame. This function deals with goals 1, 2, and 4.
# Input:
# vecCharDataPath - Base path to data files.
#
# Returns:
# A data frame created from the measurements.
readAndPrepareDataFiles <- function(vecCharDataPath) {

  # danielostling: The data is split into several files, which has to be 
  # combined into a complete data frame. The parts are X and y components and
  # subject data.

  # danielostling: Read the train and test data sets, and the activity labels.
  print("Reading test data set.")
  dfXTest <- read.table(
      file.path(vecCharDataPath, "test", "X_test.txt"),
      row.names=NULL)

  print("Reading train data set.")
  dfXTrain <- read.table(
      file.path(vecCharDataPath, "train", "X_train.txt"),
      row.names=NULL)

  print("Reading test activity labels.")
  dfLabelsTest <- read.table(
      file.path(vecCharDataPath, "test", "y_test.txt"),
      row.names=NULL)

  print("Reading train activity labels.")
  dfLabelsTrain <- read.table(
      file.path(vecCharDataPath, "train", "y_train.txt"),
      row.names=NULL)

  print("Reading test subjects.")
  dfSubjectsTest <- read.table(
    file.path(vecCharDataPath, "test", "subject_test.txt"),
    row.names=NULL)

  print("Reading train subjects.")
  dfSubjectsTrain <- read.table(
    file.path(vecCharDataPath, "train", "subject_train.txt"),
    row.names=NULL)

  # danielostling: Read features description, and only keep second column.
  print("Reading column features.")
  dfFeatures <- read.table(
      file.path(vecCharDataPath, "features.txt"), 
      row.names=NULL)
  vecCharFeatures <- dfFeatures[, -c(1)]

  # danielostling: Set feature labels for the data sets.
  # This meets goal 4.
  colnames(dfXTest) <- vecCharFeatures
  colnames(dfXTrain) <- vecCharFeatures

  # danielostling: Only keep mean and standard deviation columns, and make a 
  # feature vector of kept features for later use.
  vecBoolMatches <- grepl("-(mean|std)\\(\\)", vecCharFeatures)

  # danielostling: Drop columns that are not needed.
  # This meets goal 2.
  dfXTest <- dfXTest[, vecBoolMatches]
  dfXTrain <- dfXTrain[, vecBoolMatches]

  # danielostling: Append the activity label columns to the sets. Convert 
  # labels from data frame to integer vector first, so that data sets gets 
  # properly formatted columns appended. The same for subject data.
  vecIntLabelsTest <- dfLabelsTest[[1]]
  vecIntLabelsTrain <- dfLabelsTrain[[1]]
  vecIntSubjectsTest <- dfSubjectsTest[[1]]
  vecIntSubjectsTrain <- dfSubjectsTrain[[1]]

  dfXTest$Activity <- vecIntLabelsTest
  dfXTrain$Activity <- vecIntLabelsTrain
  dfXTest$Subject <- vecIntSubjectsTest
  dfXTrain$Subject <- vecIntSubjectsTrain

  # danielostling: Finally, append/merge the two data frames into one. I'll put 
  # the training set first and the test set second. Return it to caller.
  # This meets goal 1.
  rbind(dfXTrain, dfXTest)
}


# danielostling: Goals 3: Set appropriate activity names by replacing the 
# integer representations with human-readable strings.
# Input:
# dfDataIn - Data frame to manipulate.
# vecCharDataPath - Base path to data files.
#
# Returns:
# A data frame with activities named.
renameActivities <- function(dfDataIn, vecCharDataPath) {

  # danielostling: Read the activity mapping between integer value and 
  # character vector.
  dfActivityLabels <- read.table(
    file.path(vecCharDataPath, "activity_labels.txt"),
    row.names=NULL)

  # danielostling: Set column labels and do replacement. Use an anonymous 
  # function for looking up the correct value in the mapping.
  colnames(dfActivityLabels) <- c("Index", "Activity")
  dfDataIn$Activity <- sapply(
      dfDataIn$Activity, 
      function(val) { 
        as.character(dfActivityLabels[["Activity"]][val]) 
      })

  # danielostling: Return the modified data frame.
  dfDataIn
}


# danielostling: Goal 5: Calculate average of each variable for each activity 
# and each subject.
# Input:
# dfDataIn - Source data frame.
#
# Returns:
# A data frame with average of each variable for each activity and each subject.
summarizeData <- function(dfDataIn) {

  # danielostling: Strategy is to subset the data on subject, and then again 
  # on activity. Then, each subset will get the average of each variable 
  # calculated. This data will be used to construct a data frame.

  # danielostling: First, get a vector of unique subjects and a vector of 
  # unique activities in the data set.

  vecIntSubjects <- unique(dfDataIn$Subject)
  vecCharActivities <- unique(dfDataIn$Activity)

  # danielostling: Create a data frame to hold the resulting calculations. Fake 
  # some data to get the number of columns right, clone the column names from 
  # input data frame, and then drop the faked data.
  dfResult <- data.frame(t(rep(NA, length(names(dfDataIn)))))
  names(dfResult) <- names(dfDataIn)
  dfResult <- dfResult[-1,]
  
  # danielostling: Save number of factors to calculate average for. Subtract 
  # two to get rid of Subject and Activity columns.
  intNFactors <- length(names(dfDataIn)) - 2

  # danielostling: Loop over subjects and activities. For each pair, calculate 
  # the average of each feature, and store the result in the result data frame.
  for (intSubject in vecIntSubjects) {
      for (vecCharActivity in vecCharActivities) {
          # danielostling: Get observations matching activity and subject. 
          # Calculate mean of each feature and store in result data frame.
          dfSubset <- dfDataIn[
              dfDataIn$Activity == vecCharActivity & 
              dfDataIn$Subject == intSubject,]
          
          # danielostling: Only calculate average if there is data.
          if (nrow(dfSubset) > 0) {
              # danielostling: Skip Subject and Activity factors, as Activity 
              # is a character vector and colMeans() will not work.
              dfSubset <- colMeans(dfSubset[, 1:intNFactors])
              
              # danielostling: Converrt numeric vector to data frame.
              dfSubset <- as.data.frame(t(dfSubset))

              # danielostling: Add Activity and Subject back, and store data.
              dfSubset$Activity <- vecCharActivity
              dfSubset$Subject <- intSubject
              dfResult <- rbind(dfResult, dfSubset)
          }
      }
  }

  # danielostling: Fix double dots and ending dots in feature names.
  vecFeatures <- names(dfResult)
  vecFeatures <- gsub("[-()]", ".", vecFeatures)
  vecFeatures <- gsub("\\.{2,}", ".", vecFeatures)
  vecFeatures <- gsub("\\.$", "", vecFeatures)  

  # danielostling: Replace feature names and return result.
  colnames(dfResult) <- vecFeatures
  dfResult
}

# danielostling: Call main() at the top of the source file to get a 
# top-to-bottom structure.
main()
