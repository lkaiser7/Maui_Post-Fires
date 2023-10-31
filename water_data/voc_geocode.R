# Maui Fires Information Hub #
# data processed on hub site #

# VOC water sampling results from WRRC
# https://github.com/cshuler/VOC_Processing_Maui/tree/main 

### SET UP ###

hubDir<-"C:/Users/lkais/Dropbox/PacIOOS/Projects/Maui_Fires_Hub/"
setwd(hubDir)

# load packages
# install.packages("stringr")
library(readr)
library(sf)
library(stringr)
library(tidygeocoder)
library(openxlsx)

# voc processing path
vocDir<-paste0(hubDir, "water_data/voc_processing/")
list.files(vocDir)

# map data
hi_map<-read_sf(paste0(hubDir, "map_data/"), "Coastline")
hi_map; plot(hi_map$geometry)
# maui only
maui_map<-hi_map[which(hi_map$isle == "Maui"),]
maui_map; plot(maui_map$geometry)

### DATA ###

# sample requests sheet
voc_samp<-read_csv(paste0(vocDir, "Maui Community Water Sampling Requests-Sample_Data_10_10.csv"))
voc_samp
# check for NA or missing addresses
voc_samp[which(is.na(voc_samp$Address)),]  # 1 entry 
data.frame(voc_samp[which(voc_samp$X == 0),]) # 6 entries

# master sheet
voc_loc<-read_csv(paste0(vocDir, "MASTER_Maui_VOC_Sheet.csv"))
voc_loc
# check if up to date with current Google Sheet
# https://docs.google.com/spreadsheets/d/1lMeStcrFw_LnOJJsD5aB_aRGTKpOSq5I9Q0cIUR_vnY/edit?usp=sharing
tail(voc_loc)
# check for NA or missing addresses
voc_loc[which(is.na(voc_loc$Location)),]  # 5 entries
voc_loc$Location

# DATA PARSE
# sample sheet addresses (351)
samp_add<-voc_samp[, c(1:4, 10:12)]
# reduce number and street of address
samp_add$Number<-str_split(samp_add$Address, " ", simplify = TRUE)[,1]
samp_add$Street<-str_split(samp_add$Address, " ", simplify = TRUE)[,2]
# simplified address
samp_add$NumSt<-str_c(samp_add$Number, " ", samp_add$Street)
samp_add

# master sheet locations (210)
mast_loc<-voc_loc[, c(1:7, 9:15)]
# reduce number and street of address
mast_loc$Number<-str_split(mast_loc$Location, " ", simplify = TRUE)[,1]
mast_loc$Street<-str_split(mast_loc$Location, " ", simplify = TRUE)[,2]
# simplified address
mast_loc$NumSt<-str_c(mast_loc$Number, " ", mast_loc$Street)
# add counter for entries
mast_loc$COUNT<-c(1:dim(voc_loc)[1])
mast_loc

# DATA MATCH
# merge sample sheet with master sheet
ms_merge<-merge(mast_loc, samp_add[,-8:-9], by = "NumSt") # 95 matches 
tail(ms_merge)
ms_merge[,c(2,13)]

# format master data sheet output
voc_mast<-voc_loc[,c(-18:-19)]
# add counter for entries
voc_mast$COUNT<-c(1:dim(voc_loc)[1])
# add empty columns
voc_mast$NumSt<-mast_loc$NumSt
voc_mast$Address<-NA
voc_mast$X<-NA
voc_mast$Y<-NA
head(as.data.frame(voc_mast))

### GEOCODING ###

# geocode original location
geo_loc<-voc_mast %>%
  geocode(Location, method = "arcgis", long = longitude, lat = latitude)
# check addresses
loc_check<-geo_loc %>%
  reverse_geocode(long = longitude, lat = latitude, method = "arcgis", 
                  address = address_found, full_results = T)
loc_check$address_found
head(as.data.frame(loc_check))
# limit to only correct Maui County addresses (131)
hi_loc<-loc_check[which(loc_check$Subregion == "Maui County"),] 
head(as.data.frame(hi_loc[, c(2, 25)]))

# geocode short form  address
geo_ns<-voc_mast %>%
  geocode(NumSt, method = "arcgis", long = longitude, lat = latitude)
# check addresses
ns_check<-geo_ns %>%
  reverse_geocode(long = longitude, lat = latitude, method = "arcgis",
                  address = address_found, full_results = T)
head(as.data.frame(ns_check))
# limit to only correct Maui County addresses (28)
hi_ns<-ns_check[which(ns_check$Subregion == "Maui County"),] 
head(as.data.frame(hi_ns[, c(2, 25)]))

### GAP FILL FORMATTED MASTER SHEET ###

# loop through master count and add merged data
for(n in 1:dim(voc_mast)[1]){  # n = 98 for debugging 
  # select first entry
  master_row<-voc_mast[n, ]
  # find count 
  m_count<-master_row$COUNT
  # count checker
  c_check<-table(m_count==ms_merge$COUNT)
  
  # merge check
  merge_row<-ms_merge[which(ms_merge$COUNT == m_count),]
  # location check
  loc_row<-hi_loc[which(hi_loc$COUNT == m_count),]
  # NumSt check
  ns_row<-hi_ns[which(hi_ns$COUNT == m_count),]
  
  # gap fill geocoded data with data
  if(dim(merge_row)[1] != 0){
    # subset merged table by count
    merge_row<-ms_merge[which(ms_merge$COUNT == m_count),]
    # add merged row data from sample sheet to formatted master sheet
    voc_mast$Address[n]<-merge_row$Address
    voc_mast$X[n]<-merge_row$X
    voc_mast$Y[n]<-merge_row$Y
  }else if(dim(loc_row)[1] != 0){
    # add data from geocode to formatted master sheet
    voc_mast$Address[n]<-loc_row$address_found
    voc_mast$X[n]<-loc_row$longitude
    voc_mast$Y[n]<-loc_row$latitude
  }else if(dim(ns_row)[1] != 0){
    # add data from geocode to formatted master sheet
    voc_mast$Address[n]<-ns_row$address_found
    voc_mast$X[n]<-ns_row$longitude
    voc_mast$Y[n]<-ns_row$latitude
  }

}

head(as.data.frame(voc_mast))
tail(as.data.frame(voc_mast))
summary(voc_mast[,21:22])
# still missing 47 entries...  

# # save more accurate geocoded sheet
# write_csv(voc_mast, paste0(vocDir, "MASTER_Maui_geocoded.csv"))
# save as xlsx to retain xy decimal points
write.xlsx(voc_mast, paste0(vocDir, "MASTER_Maui_geocoded.xlsx"))

# # reverse merge master sheet with sample sheet for Sample IDs
# ss_merge<-merge(samp_add[,-8:-9], voc_mast, by = "NumSt", all.y = T)
# head(ss_merge)
# summary(ss_merge[,28:29])
# write_csv(ss_merge, paste0(vocDir, "Sampling_geocoded.csv"))

### MANUAL EDITS ###
# manually edit NA entries to better geocode missing entries

# edit saved geocoded sheet to address remaining 48 entries
mast_edit<-read.xlsx(paste0(vocDir, "MASTER_Maui_geocoded-MANUAL.xlsx"))
head(mast_edit)

# re-geocode edited NA entries
xy_na<-mast_edit[which(is.na(mast_edit$X)),]
head(xy_na)

# geocode NAs
geo_na<-xy_na %>%
  geocode(Location, method = "arcgis", long = longitude, lat = latitude)
# check addresses
na_check<-geo_na %>%
  reverse_geocode(long = longitude, lat = latitude, method = "arcgis",
                  address = address_found, full_results = T)
head(as.data.frame(na_check))
# limit to only correct Maui County addresses
hi_na<-na_check[which(na_check$Subregion == "Maui County"),] 
head(as.data.frame(hi_na[, c(2, 25)]))

# add NAs
for(f in 1:dim(hi_na)[1]){  # f = 2
  na_count<-hi_na$COUNT[f]
  na_row<-hi_na[f,]
  mast_edit$Address[which(mast_edit$COUNT == na_count)]<-na_row$address_found
  mast_edit$X[which(mast_edit$COUNT == na_count)]<-na_row$longitude
  mast_edit$Y[which(mast_edit$COUNT == na_count)]<-na_row$latitude
}

summary(mast_edit[,21:22])
# missing 25 entries
mast_edit$Location[which(is.na(mast_edit$X))]

# # manual address lookup
# add_fix<-as.data.frame(mast_edit[81:82,])
# add_geo<-add_fix %>%
#   reverse_geocode(long = X, lat = Y, method = "arcgis",
#                   address = address_found, full_results = T)
# add_geo$address_found

# check values
zero_check<-mast_edit[which(mast_edit$X == 0),]  # 5
as.data.frame(zero_check)
# replace 0 values with NA
mast_edit$X[which(mast_edit$X == 0)]<-NA
mast_edit$Y[which(mast_edit$Y == 0)]<-NA
na_all<-mast_edit[is.na(mast_edit$X),]  # 30 total

# check plot
plot(maui_map$geometry)
# sample points
points(voc_samp$X, voc_samp$Y, col = "blue", pch = 16)
# geocoded points
points(mast_edit$X, mast_edit$Y, col = "red")

# adjust lat/long values for privacy
mast_edit$X_adj<-mast_edit$X + 0.0003
mast_edit$Y_adj<-mast_edit$Y + 0.0003
# plot privacy points
points(mast_edit$X_adj, mast_edit$Y_adj, col = "green")

# PLOT NOTES: about 4 points out of range

# save master edit file (with missing 33 NA entries)
write_csv(mast_edit, paste0(vocDir, "MASTER_Maui_geocoded-101223.csv"))
# save as xlsx to retain xy decimal points
write.xlsx(mast_edit, paste0(vocDir, "MASTER_Maui_geocoded-101223.xlsx"))

# ### NOT RUN: MISSING ENTRIES ###
# 
# # check missing values
# na_check<-mast_edit[is.na(mast_edit$X),]  
# head(as.data.frame(na_check))
# as.data.frame(na_check[,c(2, 18:19)])
# 
# # try with different street endings
# 
# # Road
# na_check$alt_end<-paste(na_check$NumSt, "Road")
# na_geo<-na_check %>%
#   geocode(alt_end, method = "arcgis", long = longitude, lat = latitude)
# # check addresses
# na_add<-na_geo %>%
#   reverse_geocode(long = longitude, lat = latitude, method = "arcgis",
#                   address = address_found, full_results = T)
# head(as.data.frame(na_add))
# # limit to only correct Maui County addresses (9)
# hi_na<-na_add[which(na_add$Subregion == "Maui County"),] 
# as.data.frame(hi_na[, c(2, 22:26)])
# 
# # add to NAs
# for(f in 1:dim(na_check)[1]){  # f = 2
#   na_count<-na_check$COUNT[f]
#   fill_row<-hi_na[which(hi_na$COUNT == na_count),]
#   if(dim(fill_row)[1] != 0){
#     na_check$Address[f]<-hi_na$address_found
#     na_check$X[f]<-hi_na$longitude
#     na_check$Y[f]<-hi_na$latitude
#   }
# }
# 
# # Drive
# na_check$alt_end<-paste(na_check$NumSt, "Drive")
# na_geo<-na_check %>%
#   geocode(alt_end, method = "arcgis", long = longitude, lat = latitude)
# # check addresses
# na_add<-na_geo %>%
#   reverse_geocode(long = longitude, lat = latitude, method = "arcgis",
#                   address = address_found, full_results = T)
# head(as.data.frame(na_add))
# # limit to only correct Maui County addresses (9)
# hi_na<-na_add[which(na_add$Subregion == "Maui County"),] 
# as.data.frame(hi_na[, c(2, 22:26)])
# 
# # Way
# na_check$alt_end<-paste(na_check$NumSt, "Way")
# na_geo<-na_check %>%
#   geocode(alt_end, method = "arcgis", long = longitude, lat = latitude)
# # check addresses
# na_add<-na_geo %>%
#   reverse_geocode(long = longitude, lat = latitude, method = "arcgis",
#                   address = address_found, full_results = T)
# head(as.data.frame(na_add))
# # limit to only correct Maui County addresses (9)
# hi_na<-na_add[which(na_add$Subregion == "Maui County"),] 
# as.data.frame(hi_na[, c(2, 22:26)])
# 
# # Circle
# na_check$alt_end<-paste(na_check$NumSt, "Circle")
# na_geo<-na_check %>%
#   geocode(alt_end, method = "arcgis", long = longitude, lat = latitude)
# # check addresses
# na_add<-na_geo %>%
#   reverse_geocode(long = longitude, lat = latitude, method = "arcgis",
#                   address = address_found, full_results = T)
# head(as.data.frame(na_add))
# # limit to only correct Maui County addresses (9)
# hi_na<-na_add[which(na_add$Subregion == "Maui County"),] 
# as.data.frame(hi_na[, c(2, 22:26)])
# 

### END ###