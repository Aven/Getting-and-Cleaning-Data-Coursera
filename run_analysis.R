library(plyr)
library (reshape)
library(data.table)


#setup variables
setwd("C:/Users/####/Desktop/R/getting and cleaning data/UCI HAR Dataset/.")
file_list <- c("test/X_test.txt","train/X_train.txt")
activities_list <-c("test/y_test.txt","train/y_train.txt")
subjects_list <- c("test/subject_test.txt","train/subject_train.txt")

#merge test and training sets into 1 data frame
dataset <- ldply(file_list,  read.csv, header=FALSE, sep="")

#add column names to data frame
names(dataset) <- readLines(con="features.txt")

#add activity column; read test and training activity files, merge them and add them as column
dataset$activities <- ldply(activities_list,  read.csv, header=FALSE, sep="")

#change activities column to not be a list
dataset <- transform(dataset,activities=unlist(activities))

#make activities column into factors
dataset$activities <- as.factor(dataset$activities)

#assign labels to factors//appropriately label activities
dataset$activities = factor(dataset$activities,labels=readLines(con="activity_labels.txt"))


#create a subset of the main data set only containing columns with mean and std information from direct measurements
#of course, we should still include the activities column
meanstd_set <- dataset[, grep("mean[^meanFreq]|std|activities", colnames(dataset))  ]


#add subject numbers column to connect measurements to subjects
dataset$subjects <- ldply(subjects_list,  read.csv, header=FALSE, sep="")
dataset <- transform(dataset,subjects=unlist(subjects))
dataset$subjects <- as.factor(dataset$subjects)


#melt data to make rows for each subject+activity combo
df_melt <- melt(dataset, id = c("subjects", "activities"))
#melt the data so each column shows the mean of the variable for each subject+activity combo
casted<-(dcast(df_melt, subjects + activities ~ variable, mean))



write.table(casted, "tidy_data.txt",row.name=FALSE)



