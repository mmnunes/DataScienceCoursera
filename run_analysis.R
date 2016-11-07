## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")


# Load: activity labels and data column names
activitylabels <- read.table("./UCI HAR Dataset/activity_labels.txt" )[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
columnsWithMeanSTD <- grepl("mean|std", features)

# Load and process X_test and y_test data.
activitytest <- read.table("./UCI HAR Dataset/test/X_test.txt", header= FALSE)
featuretest <- read.table("./UCI HAR Dataset/test/y_test.txt", header= FALSE)
subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header= FALSE)

names(activitytest) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
activitytest = activitytest[,columnsWithMeanSTD]

# Load activity labels
featuretest[,2] = activitylabels[featuretest[,1]]
names(featuretest) = c("Activity_ID", "Activity_Label")
names(subjecttest) = "subject"

# Bind data
testdata <- cbind(as.data.table(subjecttest), featuretest, activitytest)

# Load and process X_train & y_train data.
activitytrain <- read.table("./UCI HAR Dataset/train/X_train.txt", header= FALSE)
featuretrain <- read.table("./UCI HAR Dataset/train/y_train.txt", header= FALSE)
subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header= FALSE)

names(activitytrain) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
activitytrain = activitytrain[,columnsWithMeanSTD]

# Load activity labels
featuretrain[,2] = activitylabels[featuretrain[,1]]
names(featuretrain) = c("Activity_ID", "Activity_Label")
names(subjecttrain) = "subject"

# Bind data
traindata <- cbind(as.data.table(subjecttrain), featuretrain, activitytrain)

# Merges the training and the test sets to create one data set
data = rbind(testdata, traindata)


idlabels   = c("subject", "Activity_ID", "Activity_Label")
datalabels = setdiff(colnames(data), idlabels)
meltdata      = melt(data, id = idlabels, measure.vars = datalabels)

# Apply mean to dataset using dcast function
tidydata   = dcast(meltdata, subject + Activity_Label ~ variable, mean)

write.table(tidydata, file = "./tidydata.txt",row.names = FALSE)