# Load the dplyr package
library(dplyr)

# Get the set of variables
features <- read.table("features.txt")
features <- as.vector(unlist(features$V2))

# Get the set of subjects
subjecttrain <- read.table("train/subject_train.txt")
subjecttest <- read.table("test/subject_test.txt")
subjects <- rbind(subjecttrain, subjecttest)

# Get the set of the taken activities
Ytrain <- read.table("train/Y_train.txt")
Ytest <- read.table("test/Y_test.txt")
activities <- rbind(Ytrain, Ytest)

# 1. Get the training and test sets and merge to one data set
Xtrain <- read.table("train/X_train.txt")
Xtest <- read.table("test/X_test.txt")
Xdat <- rbind(Xtrain, Xtest)

# Name the columns of the dataset 
names(Xdat) <- features
# Remove duplicate columns
dataset <- Xdat[, !duplicated(features)]

# 2. Extracts only the measurements on the mean and standard deviation for each measurement
meandf <- select(dataset, contains("mean()"))
stddf <- select(dataset, contains("std()"))

# Merge the data set with activities and subjects
dataset <- cbind(meandf, stddf, subjects, activities)
names(dataset) <- c(names(meandf), names(stddf), "subject", "activity")

# 3. Uses descriptive activity names to name the activities in the data set
dataset$activity <- gsub(1, "Walking", dataset$activity)
dataset$activity <- gsub(2, "Walking Up", dataset$activity)
dataset$activity <- gsub(3, "Walking Down", dataset$activity)
dataset$activity <- gsub(4, "Sitting", dataset$activity)
dataset$activity <- gsub(5, "Standing", dataset$activity)
dataset$activity <- gsub(6, "Laying", dataset$activity)

# 4. Appropriately labels the data set with descriptive variable names
colnames <- names(dataset)
colnames <- gsub("^f(.*)-std\\()-(.*)", "Std.Deviation.Of.\\1.Frequency.In.\\2.Direction", colnames)
colnames <- gsub("^t(.*)-std\\()-(.*)", "Std.Deviation.Of.\\1.Time.In.\\2.Direction", colnames)
colnames <- gsub("^f(.*)-mean\\()-(.*)", "Mean.Of.\\1.Frequency.In.\\2.Direction", colnames)
colnames <- gsub("^t(.*)-mean\\()-(.*)", "Mean.Of.\\1.Time.In.\\2.Direction", colnames)
colnames <- gsub("^t(.*)-std\\()$", "Std.Deviation.Of.\\1.Time", colnames)
colnames <- gsub("^f(.*)-std\\()$", "Std.Deviation.Of.\\1.Frequency", colnames)
colnames <- gsub("^t(.*)-mean\\()$", "Mean.Of.\\1.Time", colnames)
colnames <- gsub("^f(.*)-mean\\()$", "Mean.Of.\\1.Frequency", colnames)
colnames <- gsub("BodyBody", "Body", colnames)
names(dataset) <- colnames

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject
tidydf <- dataset %>% 
    group_by(activity, subject) %>% 
    summarise_each(funs(mean))

# Write the data set to file in the current working folder
write.table(tidydf, file="./tidydataset.txt", row.names=FALSE)
