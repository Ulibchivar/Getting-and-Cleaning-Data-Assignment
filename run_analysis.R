## load packages

install.packages('downloader', repos='http://cran.us.r-project.org')
install.packages('plyr')
library(downloader)
library(plyr)

## Set working directory
setwd("C:/Users/polin/R projects/Cleaning_data_assignment")


## download

link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"     
download(link,dest = "raw_data.zip")
unzip("raw_data.zip")



##  Update working directory to UCI HAR Dataset folder
setwd("C:/Users/polin/R projects/Cleaning_data_assignment/UCI HAR Dataset")



## Read in data
x_test <- read.table("test/X_test.txt")
x_train <- read.table("train/X_train.txt")
y_test <- read.table("test/Y_test.txt")
y_train <- read.table("train/Y_train.txt")
subject_test <- read.table("test/subject_test.txt")
subject_train <- read.table("train/subject_train.txt")
activity_labels<-read.table(file.path("activity_labels.txt"), col.names = c("Id", "activity"))
features<-read.table(file.path("features.txt"), colClasses = c("character"))



## Merge datasets
train_data<-cbind(cbind(x_train, subject_train), y_train)
test_data<-cbind(cbind(x_test, subject_test), y_test)
all_data<-rbind(train_data, test_data)

##labels
labels<-rbind(rbind(features, c(562, "Subject")), c(563, "Id"))[,2]
names(all_data)<-labels



## Extract mean and standard deviation 
extracted_mean_std <- all_data[,grepl("mean\\(\\)|std\\(\\)|Subject|Id", names(all_data))]


## Add activity labels
extracted_mean_std <- join(extracted_mean_std, activity_labels, by = "Id", match = "first")
extracted_mean_std <- extracted_mean_std[,-1]



## Make names for descriptive

names(extracted_mean_std) <- gsub("([()])","",names(extracted_mean_std))
names(extracted_mean_std) <- make.names(names(extracted_mean_std))
names(extracted_mean_std)<-gsub("BodyBody", "Body", names(extracted_mean_std))
names(extracted_mean_std)<-gsub("Acc", "Accelerometer", names(extracted_mean_std))
names(extracted_mean_std)<-gsub("Gyro", "Gyroscope", names(extracted_mean_std))
names(extracted_mean_std)<-gsub("^t", "time", names(extracted_mean_std))
names(extracted_mean_std)<-gsub("^f", "frequency", names(extracted_mean_std))
names(extracted_mean_std)<-gsub("Mag", "Magnitude", names(extracted_mean_std))



## create second dataset with averages
means_final <-aggregate(. ~Subject + activity, extracted_mean_std, mean)

## create final output dataset
write.table(means_final, file = "tidy_data.txt",row.name=FALSE)