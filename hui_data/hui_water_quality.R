# Maui Fires Information Hub #
# data processed on hub site #

# Water Quality Data
# Hui O Ka Wai Ola 
# downloaded from PacIOOS
#https://pae-paha.pacioos.hawaii.edu/erddap/tabledap/index.html?page=1&itemsPerPage=1000 

### SET UP ###

hubDir<-"C:/Users/lkais/Dropbox/PacIOOS/Projects/Maui_Fires_Hub/Maui_Post-Fires/"
setwd(hubDir)

# load packages
#install.packages("readr")
library(readr)

# water quality path
huiDir<-paste0(hubDir, "hui_data/")
list.files(huiDir)

### DATA ###
# hui_data<-read_csv(paste0(huiDir, "hui_water_quality.csv"))
hui_data<-read_csv(paste0(huiDir, "hui_water_quality_esri.csv")) # date/time separate
hui_data

# replace missing -9999 values with NA
hui_data[hui_data == -9999]<-NA
summary(hui_data)

# save data
write_csv(hui_data, paste0(wqDir, "hui_water_quality_esri_edit.csv"))

### END ###