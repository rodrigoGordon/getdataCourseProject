# getdataCourseProject
R analysis on Human Activity dataset

The main points in the run_analysis.R script are: 
    - Read and pre-processing
    - Binding and Selection
    - Generation of Tidy dataset
    
###Let's start with Read and pre-process the data:

If you're forking this repo, don't forget to set your working directory 
```{r}
setwd()
```

To the Git folder created in your computer. Then from lines 6 to 21 in thw run_analysis.R file, we simply download the dataset, read the txt files. It should run just fine, if your working directory is set up correctly. Then from lines 22 to 27, it's assign the header for our dataset through the 

```{r}
colNames(y) <- make.names(x, unique = TRUE)

```
Where y it's our dataset that will receive the column from x$V2 coulmn names. The function make.names it's used, because we need to avoid invalid characters in the names of column, which could give us trouble later on in the assignment.

### Bindig and Selecting our data
Since the original reseachers divided the dataset into training and test portions, we need to bind/merge them to have the complete raw data of measurements.Using
```{r}
newDataSetYouWant <- rbind(x,y)
```

But remember that you should call rbind only when x and y have the same exact column, otherwise you should use the merge() function.

####Selecting a smaller dataset
As requested in the assignment, we need to select only the columns that measure some kind of mean and standard deviation on the complete raw data. You can do this through the combination of select() and contains() functions from the dplyr package:
```{r}
subSetForMeanAndStandardDeviation <- select(completeDataSetYouHave, contains("mean"), contains("std"))
```
There is an option inside contains() for Upper case letter, but it wasn't used here.

##Creation of the tidy dataset
Let's fast forward to the creation the tidy dataset, but if you're interested in every single detail of the process, such as: inclusion of new columns, update of column name; Take a look at the comments in the script.

Proceeding, to create the tidy dataset we have to:
    -  Group the rows by subject and activity
    -  Summarize the columns by their mean
    -  Write the data.frame to a file
To do such things we can use:

```{r}
groupObject <- group_by(X, columnAFromXtoBeGrouped, columnBFromXtoBeGrouped)
```
####Let's summarize
```{r}
tidyDataSet <- summarize_each(grpActivity, funs(mean))
```
####Let's create the tidyDataSet.txt file
```{r}
write.table(tidyDataSet, file = "./tidyDataSet.txt", row.names = FALSE)
```
    
And now you should have a file in your working directory called tidyDataset.txt, with 180 rows and 88 columns.

