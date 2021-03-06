### Getting and Cleaning Data Course Project CodeBook
This codebook describe the data, variables and steps to clean up the data and produce tidy data set. 

* Data was obtained from this site: 
	http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
  Here are the data for the project:
	https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

* Steps to clean up the data and produce tidy dataset

First loads the library "dplyr" which provides functions "group_by" and "summarise_each" to be used later

	library(dplyr)

Then, get the set of variables

	features <- read.table("features.txt")
	features <- as.vector(unlist(features$V2))

Get the set of subjects

	subjecttrain <- read.table("train/subject_train.txt")
	subjecttest <- read.table("test/subject_test.txt")
	subjects <- rbind(subjecttrain, subjecttest)

Get the set of the taken activities

	Ytrain <- read.table("train/Y_train.txt")
	Ytest <- read.table("test/Y_test.txt")
	activities <- rbind(Ytrain, Ytest)

The scripts then get the training and test sets and merge to one data set called "Xdat"

	Xtrain <- read.table("train/X_train.txt")
	Xtest <- read.table("test/X_test.txt")
	Xdat <- rbind(Xtrain, Xtest)

Name the columns of the by the variables in the "features" vector

	names(Xdat) <- features

Since the data has duplicate columns, this step removes the duplicated columns

	dataset <- Xdat[, !duplicated(features)]

Extracts only the measurements on the mean and standard deviation for each measurement
by selecting all columns that have "mean()" or "std()" in their names

	meandf <- select(dataset, contains("mean()"))
	stddf <- select(dataset, contains("std()"))

Merge the data set with activities and subjects

	dataset <- cbind(meandf, stddf, subjects, activities)
	names(dataset) <- c(names(meandf), names(stddf), "subject", "activity")

Name the activities in the data set with descriptive activity names 

	dataset$activity <- gsub(1, "Walking", dataset$activity)
	dataset$activity <- gsub(2, "Walking Up", dataset$activity)
	dataset$activity <- gsub(3, "Walking Down", dataset$activity)
	dataset$activity <- gsub(4, "Sitting", dataset$activity)
	dataset$activity <- gsub(5, "Standing", dataset$activity)
	dataset$activity <- gsub(6, "Laying", dataset$activity)

Appropriately labels the data set with descriptive variable names

	colnames <- names(dataset)
	colnames <- gsub("^f(.*)-std\\()-(.*)", "Std.Deviation.Of.\\1.Frequency.In.\\2.Direction", colnames)
	colnames <- gsub("^t(.*)-std\\()-(.*)", "Std.Deviation.Of.\\1.Time.In.\\2.Direction", colnames)
	colnames <- gsub("^f(.*)-mean\\()-(.*)", "Mean.Of.\\1.Frequency.In.\\2.Direction", colnames)
	colnames <- gsub("^t(.*)-mean\\()-(.*)", "Mean.Of.\\1.Time.In.\\2.Direction", colnames)
	colnames <- gsub("^t(.*)-std\\()$", "Std.Deviation.Of.\\1.Time", colnames)
	colnames <- gsub("^f(.*)-std\\()$", "Std.Deviation.Of.\\1.Frequency", colnames)
	colnames <- gsub("^t(.*)-mean\\()$", "Mean.Of.\\1.Time", colnames)
	colnames <- gsub("^f(.*)-mean\\()$", "Mean.Of.\\1.Frequency", colnames)

Fix the names of the columns that have duplicated word "Body" 

	colnames <- gsub("BodyBody", "Body", colnames)
	names(dataset) <- colnames

From the data set in previous step, creates a second, independent tidy data set 
with the average of each variable for each activity and each subject. Here I use the "chaining" operator %>%, first group the dataset by "activity" and "subject", then compute the average value of each group

	tidydf <- dataset %>% 
	    group_by(activity, subject) %>% 
	    summarise_each(funs(mean))

The tidy data set has 180 rows which are combinations of 30 unique subjects and 6 unique activities. 
Each row contains an observation while each column contains a variable with 68 columns in total.
Finally, write the data set to file named "tidydataset.txt" in the current working folder

	write.table(tidydf, file="./tidydataset.txt", row.names=FALSE)
