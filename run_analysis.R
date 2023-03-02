getwd()
setwd("F:/Coursera/Getting and Cleaning Data/Getting and 
      Cleaning Data/Week 4 Project")

# Load Packages and Get The Data
packages <- c("data.table", "reshape2", "dplyr")
sapply(packages, require, character.only = TRUE, quietly = TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/
        getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Make All The Frames
features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("n", "functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", 
                         col.names = c("code", "activity"))

# More Frames, Test and Train
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", 
                           col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/x_test.txt",
                     col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", 
                     col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", 
                            col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/x_train.txt", 
                      col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", 
                      col.names = "code")

# Merge It
x <- rbind(x_train, x_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
merge_data <- cbind(subject, y, x)

# Clean It Up
tidydata <- merge_data %>% select(subject, code, contains("mean"), contains("std"))

# Make It Meaningful
tidydata$code <- activities[tidydata$code, 2]
names(tidydata) [2] = "activity"
names(tidydata) <- gsub("Acc", "Accelerometer", names(tidydata))
names(tidydata) <- gsub("Gyro", "Gyroscope", names(tidydata))
names(tidydata) <- gsub("BodyBody", "Body", names(tidydata))
names(tidydata) <- gsub("Mag", "Magnitude", names(tidydata))
names(tidydata) <- gsub("^t", "Time", names(tidydata))
names(tidydata) <- gsub("^f", "Frequency", names(tidydata))
names(tidydata) <- gsub("tBody", "TimeBody", names(tidydata))
names(tidydata) <- gsub("-mean()", "Mean", names(tidydata), ignore.case = TRUE)
names(tidydata) <- gsub("-std()", "STD", names(tidydata), ignore.case = TRUE)
names(tidydata) <- gsub("-freq()", "Frequency", names(tidydata), ignore.case = TRUE)
names(tidydata) <- gsub("angle", "Angle", names(tidydata))
names(tidydata) <- gsub("gravity", "Gravity", names(tidydata))

# New Data Table
Tidy_Data <- tidydata %>%
        group_by(subject, activity) %>%
        summarise_all(funs(mean))
write.table(Tidy_Data, "Tidy_Data.txt", row.names = FALSE)
