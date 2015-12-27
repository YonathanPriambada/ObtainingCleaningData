#The explanation on the code can be found on the Readme.md file. Explanation on the variables used as well as data structure can be found in the Codebook.md file.

if(!file.exists('run_data.zip')){
    url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    
    download.file(url,destfile = "run_data.zip")##downloading the data file
}
unzip("run_data.zip")
install.packages('data.table')
library(data.table)
install.packages('dplyr')
library(dplyr)

#Preliminary:
features_labels <- read.table("UCI HAR Dataset/features.txt")
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

##Part 1 
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)
colnames(features) <- t(features_labels[2])
colnames(activity) <-"Activity"
colnames(subject) <-"Subject"
#Finally, the merged data set
mergedData <-cbind(features, activity, subject)
write.table(mergedData,"mergedData.txt")


##Part 2 
#Extract only those with mean and standard deviation (std)
dim(mergedData)
MeanStd <- grep(".*Mean.*|.*Std.*", names(mergedData), ignore.case=TRUE)
extractedCol<-c(MeanStd,562,563)
extractedData<-mergedData[,extractedCol]
dim(extractedData)


##Part 3 
#change the variable type from numeric to character before we change the labelling
extractedData$Activity<-as.character(extractedData$Activity)
for (x in 1:6){
    extractedData$Activity[extractedData$Activity == x] <- as.character(activity_labels[x,2])
}
extractedData$Activity <- as.factor(extractedData$Activity)


##Part 4 
names(extractedData)
#Rename the variables labels with more descriptive labels
names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("^t", "Time", names(extractedData))
names(extractedData)<-gsub("^f", "Frequency", names(extractedData))
names(extractedData)<-gsub("tBody", "TimeBody", names(extractedData))
names(extractedData)<-gsub("-mean()", "Mean", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-std()", "STD", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-freq()", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("angle", "Angle", names(extractedData))
names(extractedData)<-gsub("gravity", "Gravity", names(extractedData))


##Part 5 
extractedData$Subject <- as.factor(extractedData$Subject)
extractedData <- data.table(extractedData)
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
#The 'tidied' data is printed into a text file Tidy_Data.txt
write.table(tidyData, file = "Tidy_Data.txt", row.names = FALSE)