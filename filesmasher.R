library(dplyr) #used for bind_rows
library(tools) #used for filename functions
library(openxlsx) #reads XLSX files quicker than the 'xlsx' package

#manually entered path, but could be edited to take it as input from user
path <- "C:/Users/josh.fullmer/Documents/R/filesmasher"

#gets a vector of all spreadsheet files
filenames <- dir(path,pattern='.(csv|xlsx|xls)')

#create empty data frame for adding to during the loop
df <- data.frame()

#loops through each file in the filenames vector
for(i in 1:length(filenames)) {
   
   #instantiate file dataframe for access in the if clause
   file <- data.frame()
   
   #checks if the file is a XLS or XLSX based on the file extension
   if ((file_ext(filenames[i])=='xls')|(file_ext(filenames[i])=='xlsx')){
      
      #reads the first sheet in the Excel file
      file <- read.xlsx(paste(path,"/",filenames[i],sep=''),1)
      
      #gets all columns that have Date in the name for Date formatting
      datecols <- names(file)[grepl('Date',names(file))]
      
      #format each of the date columns in the sheet
      for(j in 1:length(datecols)) {
         file[[datecols[j]]] <- as.Date(as.POSIXlt(file[[datecols[j]]]*24*60*60,origin='1899-12-30',tz='gmt'))
      }
   }
   
   #checks if the file is a CSV based on the file extension
   if (file_ext(filenames[i])=='csv'){
      
      #reads the CSV file
      file <- read.csv(paste(path,"/",filenames[i],sep=''),header=T)
      
      #gets all columns that have Date in the name for Date conversion
      datecols <- names(file)[grepl('Date',names(file))]
      
      #convert each date column
      for(j in 1:length(datecols)) {
         file[[datecols[j]]] <- as.Date(file[[datecols[j]]],format='%m/%d/%Y')
      }
   }
   
   #stores the filename of the file in a column of the dataframe
   file$filename <- file_path_sans_ext(filenames[i])
   
   #combines the current file with all previously handled files
   df <- bind_rows(df,file)
}

#writes the combined dataframe to CSV
write.csv(df,file=paste(path,'/','out.csv',sep=''),na='',row.names=F)
