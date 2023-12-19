# Maui Fires Information Hub #
# data processed on hub site #

### SET UP ###

hubDir<-"C:/Users/lkais/Dropbox/PacIOOS/Projects/Maui_Fires_Hub/Maui_Post-Fires/"
# setwd(hubDir) # directory set by project with git hub integration

# load packages
# install.packages("stringr")
library(readr)
library(sf)
library(stringr)
library(tidygeocoder)
library(openxlsx)

# voc processing path
vocDir<-paste0(hubDir, "water_data/")
list.files(vocDir)

### DATA ###

# DOWNLOAD NEW DATA UPDATE (current as of 12/18/2023)
# check if up to date with current Google Sheet
# https://docs.google.com/spreadsheets/d/1lMeStcrFw_LnOJJsD5aB_aRGTKpOSq5I9Q0cIUR_vnY/edit?usp=sharing

# new master sheet
new_loc<-read_csv(paste0(vocDir, "MASTER_Maui_VOC_Sheet.csv"))
tail(new_loc)

# previous geocoded master sheet
prev_loc<-read.xlsx(paste0(vocDir, "Maui_Master_VOC_Sheet-112023.xlsx"))
#prev_loc<-read_csv(paste0(vocDir, "Maui_Master_VOC_Sheet-112023.csv"))
tail(prev_loc)

# check entry differences
new_entry<-dim(new_loc)[1]-dim(prev_loc)[1]

# subset new data
loc_update<-tail(new_loc, n = new_entry)
# # if too many NAs, geocode all missing values
# loc_update<-new_loc[which(is.na(new_loc$X)),]
# loc_update$Location_CASE<-toupper(loc_update$Location)
loc_update

### GEOCODE ###

# geocode original location
new_geo<-loc_update %>%
  geocode(Location, method = "arcgis", long = longitude, lat = latitude)
# check addresses
loc_check<-new_geo %>%
  reverse_geocode(long = longitude, lat = latitude, method = "arcgis", 
                  address = address_found, full_results = T)
loc_check$address_found
head(as.data.frame(loc_check))
# limit to only correct Maui County addresses
hi_loc<-loc_check[which(loc_check$Subregion == "Maui County"),] 
as.data.frame(hi_loc[, c(2, 20:24)])

# # add long/lat data to xy
# hi_loc$X<-hi_loc$longitude
# hi_loc$Y<-hi_loc$latitude

# add to new dataset
for(n in 1:dim(hi_loc)[1]){  # n = 1
  new_loc$X[which(new_loc$`Sample ID` == hi_loc$`Sample ID`[n])]<-hi_loc$longitude[n]
  new_loc$Y[which(new_loc$`Sample ID` == hi_loc$`Sample ID`[n])]<-hi_loc$latitude[n]
}
as.data.frame(tail(new_loc, n = new_entry))

# # adjust lat/long values for privacy
# new_loc$X_adj<-new_loc$X + 0.0003
# new_loc$Y_adj<-new_loc$Y + 0.0003

# check NAs
na_check<-new_loc[which(is.na(new_loc$X)),]
na_check$Location # 22

# MANUAL FILL (from Google Maps search)
# new_loc$X[which(new_loc$Location == "1739 Ainakea Place")]<--156.68557
# new_loc$Y[which(new_loc$Location == "1739 Ainakea Place")]<-20.9014923
# new_loc$X[which(new_loc$Location == "136 Kulamanu Cir Kula Hi 96790 United States")]<--156.3196926
# new_loc$Y[which(new_loc$Location == "136 Kulamanu Cir Kula Hi 96790 United States")]<-20.7806863
# new_loc$X[which(new_loc$Location == "1719 AA place Lahaina HI 96761")]<--156.6838961
# new_loc$Y[which(new_loc$Location == "1719 AA place Lahaina HI 96761")]<-20.9008004
# new_loc$X[which(new_loc$Location == "15 Wai Kulu Place, Lahaina HI 96761")]<--156.6426177
# new_loc$Y[which(new_loc$Location == "15 Wai Kulu Place, Lahaina HI 96761")]<-20.8445923
# new_loc$X[which(new_loc$Location == "1701 AA place Lahaina Hi 96761")]<--156.6839944
# new_loc$Y[which(new_loc$Location == "1701 AA place Lahaina Hi 96761")]<-20.9003986
# new_loc$X[which(new_loc$Location == "15200 Haleakala Hwy Kula Hi 96790")]<--156.3104874
# new_loc$Y[which(new_loc$Location == "15200 Haleakala Hwy Kula Hi 96790")]<-20.7777746
# new_loc$X[which(new_loc$Location == "21 Kai Nana Pl Kula HI 96790 United States")]<--156.3301997
# new_loc$Y[which(new_loc$Location == "21 Kai Nana Pl Kula HI 96790 United States")]<-20.760726
new_loc$X[which(new_loc$Location == "4422 A Lower Kula Rd")]<--156.3301738
new_loc$Y[which(new_loc$Location == "4422 A Lower Kula Rd")]<-20.7616131
new_loc$X[which(new_loc$Location == "310 Waipoli Rd")]<--156.3313896
new_loc$Y[which(new_loc$Location == "310 Waipoli Rd")]<-20.7395986
new_loc$X[which(new_loc$Location == "321 Waipoli Rd")]<--156.3290839
new_loc$Y[which(new_loc$Location == "321 Waipoli Rd")]<-20.7399932
new_loc$X[which(new_loc$Location == "66 Cooke Rd")]<--156.3108239
new_loc$Y[which(new_loc$Location == "66 Cooke Rd")]<-20.7602029

new_loc$Location[which(is.na(new_loc$X))] # 16

# save updated data file (csv for arc online and xlsx to view and edit)
#write_csv(new_loc, paste0(vocDir, "Maui_Master_VOC_Sheet-121323.csv"))
write.xlsx(new_loc, paste0(vocDir, "Maui_Master_VOC_Sheet-121823.xlsx"))

### END ###