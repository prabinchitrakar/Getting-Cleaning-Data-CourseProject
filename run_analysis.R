# the 'run_analysis.R' script does the following:

#1. Download and unzip the required input files

download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', destfile='input_files.zip', method='curl')
unzip('input_files.zip')

#2. Creates a folder "output" in the work directory and sets it as new work directory.

WorkDir <- getwd()
OpDir <- "output"
dir.create(file.path(WorkDir, OpDir))
setwd(file.path(mainDir, subDir))

#3. Creates a dataset by merging the train and test sets.

make_subject_dataset <- function() {
    subject_test <- read.table('./UCI HAR Dataset/test/subject_test.txt')
    subject_train <- read.table('./UCI HAR Dataset/train/subject_train.txt')
    subject_merged <- rbind(subject_train, subject_test)
    names(subject_merged) <- "subject"
    subject_merged
}

make_X_dataset <- function() {
    X_test <- read.table('./UCI HAR Dataset/test/X_test.txt')
    X_train <- read.table('./UCI HAR Dataset/train/X_train.txt')
    X_merged  <- rbind(X_train, X_test)
}

make_y_dataset <- function() {
    y_test <- read.table('./UCI HAR Dataset/test/y_test.txt')
    y_train <- read.table('./UCI HAR Dataset/train/y_train.txt')
    y_merged  <- rbind(y_train, y_test)
}

subject_dataset <- make_subject_dataset()
X_dataset <- make_X_dataset()
y_dataset <- make_y_dataset()


#4. For each measurement, mean and standard deviation is extracted.

get_selected_measurements <- function() {
    features <- read.table('./UCI HAR Dataset/features.txt', header=FALSE, col.names=c('id', 'name'))
    feature_selected_columns <- grep('mean\\(\\)|std\\(\\)', features$name)
    filtered_dataset <- X_dataset[, feature_selected_columns]
    names(filtered_dataset) <- features[features$id %in% feature_selected_columns, 2]
    filtered_dataset
}

X_filtered_dataset <- get_selected_measurements()

#5. Uses descriptive activity names to name the activities in the dataset

activity_labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header=FALSE, col.names=c('id', 'name'))


#6. Appropriately labels the dataset with descriptive activity names. 

y_dataset[, 1] = activity_labels[y_dataset[, 1], 2]
names(y_dataset) <- "activity"


#7. Creates whole_dataset_with_descriptive_activity_names.csv file.

whole_dataset <- cbind(subject_dataset, y_dataset, X_filtered_dataset)
write.csv(whole_dataset, "./output/whole_dataset_with_descriptive_activity_names.csv")


#8. Creates files final_clear_dataset.csv and final_clear_dataset.txt.

measurements <- whole_dataset[, 3:dim(whole_dataset)[2]]
clear_dataset <- aggregate(measurements, list(whole_dataset$subject, whole_dataset$activity), mean)
names(clear_dataset)[1:2] <- c('subject', 'activity')
write.csv(clear_dataset, "./output/final_clear_dataset.csv")
write.table(clear_dataset, "./output/final_clear_dataset.txt" , row.name=FALSE)
