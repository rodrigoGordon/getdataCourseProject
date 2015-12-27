## Analysis for the dataset on http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
## Download the data from here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
##
library(dplyr)
#Download the data
fileUrlDataSet <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
tempZip <- tempfile()
download.file(fileUrlDataSet,tempZip, mode="wb")

unzip(tempZip)


#Read the datasets
activityDataSetTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")


activityDataSetTest <- read.table("./UCI HAR Dataset/test/X_test.txt")


#Getting the feature names
featuresDescription <- read.table("./UCI HAR Dataset/features.txt")

#credits to http://stackoverflow.com/questions/7531868/how-to-rename-a-single-column-in-a-data-frame-in-r
#credtis to https://www.biostars.org/p/62988/

colnames(activityDataSetTrain) <- make.names(featuresDescription$V2, unique = TRUE)
colnames(activityDataSetTest) <- make.names(featuresDescription$V2, unique = TRUE)



#Merges the training and the test sets to create one data set( by row since they have the same columns).
newDataSetMerged <- rbind(activityDataSetTrain,activityDataSetTest)


#Extracts only the measurements on the mean and standard deviation for each measurement. 
extractedDataSetMeanSD <- select(newDataSetMerged, contains("mean"), contains("std"))


#Uses descriptive activity names to name the activities in the data set
# Let's attach the y_labels to the new training set, then change them to the description on activity_labels.txt

#Read the y_labels
activityDataSetTrainLabels <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names = c("description"))
activityDataSetTestLabels <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names = c("description"))


#Read the labels description
labelsActivity <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("id", "labelDescription"))


#Let's also read the dataset indicating who performed the activity
subjectTrainListIdentification <- read.table("./UCI HAR Dataset/train/subject_train.txt", 
                                             col.names = c("subjectID"))

subjectTestListIdentification <- read.table("./UCI HAR Dataset/test/subject_test.txt", 
                                             col.names = c("subjectID"))

#Bind the subject list

allSubjectList <- as.numeric(unlist(rbind(subjectTrainListIdentification, subjectTestListIdentification)))

#Switch the activity labels factor from 1:5 to WALKING;WALKING_UPSTAIRS ;WALKING_DOWNSTAIRS 
#                                             ;SITTING ;STANDING ;LAYING
activityDataSetTrainLabels$description <- factor(activityDataSetTrainLabels$description,
                                                 labels=labelsActivity$labelDescription)

activityDataSetTestLabels$description <- factor(activityDataSetTestLabels$description,
                                                 labels=labelsActivity$labelDescription)


#Bind the y_labels in form of factor, that's why was used the unlist and as.factor
allYs <- as.character(unlist(rbind(activityDataSetTrainLabels, activityDataSetTestLabels)))

#Let's mutate our extratedDataSetMeanSD and create the column for the binded y_labels and subject list
extractedDataSetMeanSD <- mutate(extractedDataSetMeanSD, descriptionOfActivityPerformed = allYs)
extractedDataSetMeanSD <- mutate(extractedDataSetMeanSD, subjectID = allSubjectList)



#Appropriately labels the data set with descriptive variable names. 
#Gotta rename them all ! Got it? lol


# gsub() fuction was used to find abbreviated terms and transform them to a more readable format
# credits to http://stackoverflow.com/questions/11936339/in-r-how-do-i-replace-text-within-a-string

descriptiveNamesForColumns <- names(extractedDataSetMeanSD)

descriptiveNamesForColumns <- gsub("Acc", "Accelerometer", descriptiveNamesForColumns)
descriptiveNamesForColumns <- gsub("Gyro", "Gyroscope",descriptiveNamesForColumns)
descriptiveNamesForColumns <- gsub("Mag", "Magnitude",descriptiveNamesForColumns)
descriptiveNamesForColumns <- gsub("std", "StandardDeviation",descriptiveNamesForColumns)
descriptiveNamesForColumns <- gsub("Freq", "Frequency",descriptiveNamesForColumns)
descriptiveNamesForColumns <- gsub("mean", "Mean",descriptiveNamesForColumns)

#Little trick in this part, to replace only the first t and f in the column name
descriptiveNamesForColumns <- paste(gsub("t", "time", substring(descriptiveNamesForColumns, 1,1)), 
                                    substring(descriptiveNamesForColumns, 2), sep = "")

descriptiveNamesForColumns <- paste(gsub("f", "frequency", substring(descriptiveNamesForColumns, 1,1)), 
                                    substring(descriptiveNamesForColumns, 2), sep = "")


#Uses the operator \\. to erase all the dots in the column name
descriptiveNamesForColumns <- gsub("\\.", "", descriptiveNamesForColumns)


#Finally update the dataset with the new column names
colnames(extractedDataSetMeanSD) <- descriptiveNamesForColumns


#From the data set in step 4, creates a second, independent tidy data set with the average of each 
#variable for each activity and each subject.
grpActivity <- group_by(extractedDataSetMeanSD, descriptionOfActivityPerformed, subjectID)

#credits to http://stackoverflow.com/questions/21644848/summarizing-multiple-columns-with-dplyr
tidyDataSet <- summarize_each(grpActivity, funs(mean))

write.table(tidyDataSet, file = "./tidyDataSet.txt", row.names = FALSE)

 