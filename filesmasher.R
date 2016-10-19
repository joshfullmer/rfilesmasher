library(dplyr)
library(tools)
library(openxlsx)

path <- "C:/Users/josh.fullmer/Documents/R/filesmasher"

filenames <- dir(path,pattern='.(csv|xlsx|xls)')

df <- data.frame()

for(i in 1:length(filenames)) {
   file <- data.frame()
   if ((file_ext(filenames[i])=='xls')|(file_ext(filenames[i])=='xlsx')){
      file <- read.xlsx(paste(path,"/",filenames[i],sep=''),1)
      datecols <- names(file)[grepl('Date',names(file))]
      for(j in 1:length(datecols)) {
         file[[datecols[j]]] <- as.Date(as.POSIXlt(file[[datecols[j]]]*24*60*60,origin='1899-12-30',tz='gmt'))
      }
   }
   if (file_ext(filenames[i])=='csv'){
      file <- read.csv(paste(path,"/",filenames[i],sep=''),header=T)
      datecols <- names(file)[grepl('Date',names(file))]
      for(j in 1:length(datecols)) {
         file[[datecols[j]]] <- as.Date(file[[datecols[j]]],format='%m/%d/%Y')
      }
   }
   file$filename <- file_path_sans_ext(filenames[i])
   df <- bind_rows(df,file)
}

#df$Lead.Create.Date <- as.POSIXlt(df$Lead.Create.Date*24*60*60,origin='1899-12-30',tz='gmt')

write.csv(df,file=paste(path,'/','out.csv',sep=''),na='',row.names=F)
