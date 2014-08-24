Getting And Cleaning Data project
=================================

## Overview
This is my project repo for the Johns Hopkins Coursera course "Getting And 
Cleaning Data".

The task of this project was to perform an analysis of motion tracking data 
and to store the result into a so-called tidy data set. See 
http://vita.had.co.nz/papers/tidy-data.pdf for details on what tidy data set 
means.

## How to use
The code to perform the analysis of the UCI data set is in run_analysis.R.

The data on which the analysis is done is taken from 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

To perform the analysis, unpack the data archive and note the name of the 
folder you unpacked into. Edit run_analysis.R and set the variable 
"vecCharDataPath" in the function "main()" to the path you unpacked into.

## Output of script
The output produced by run_analysis.R is a summary of the data in the 
original motion tracking data. It contains only data about mean and standard 
deviation features in the original data. The summary is done as the average 
of each mean or standard deviation feature, for each subject and each 
activity. When the run_analysis.R script is run, it will write the tidy data 
set into a file named "Getting_and_Cleaning_Data_tidy.txt", with the command:
````
      write.table(
          dfCombined,
          file="Getting_and_Cleaning_Data_tidy.txt", 
          row.names=FALSE)
````
where "dfCombined" is the resulting data set of the summary analysis.

## A note on the data
The feaures in the output is described in a separate code book file, named
"Codebook.txt". It explains how to interpret the various features in the 
resulting tidy data set. In R, you can load the data set with this command: 
````
    dfTidy <- read.table("Getting_and_Cleaning_Data_tidy.txt", header=TRUE)
````
