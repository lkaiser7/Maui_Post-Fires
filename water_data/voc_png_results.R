# Maui Fires Information Hub #
# data processed on hub site #

# VOC water sampling png image results from WRRC
# https://github.com/cshuler/VOC_Processing_Maui/tree/main/Scripts/temp

# MOVE PREVIOUS FILES TO "old_data" FOLDER FOR RECORD CHECKS

### SET UP ###

hubDir<-"C:/Users/lkais/Dropbox/PacIOOS/Projects/Maui_Fires_Hub/Maui_Post-Fires/"
# setwd(hubDir) # directory set by project with git hub integration

# load packages
# install.packages("stringr")
library(openxlsx)
library(stringr)
library(dplyr)
library(readr)

# voc processing path
vocDir<-paste0(hubDir, "water_data/")
list.files(vocDir)

# git path
gitDir<-"C:/Users/lkais/Dropbox/PacIOOS/Projects/Maui_Fires_Hub/water_data/VOC_Processing_Maui/"

### DATA ###

# master sheet
voc_mast<-read.xlsx(paste0(vocDir, "Maui_Master_VOC_Sheet-013124.xlsx"))
head(voc_mast)
table(voc_mast$Results.Link)
voc_orig<-voc_mast

# release only records approved and shared with homeowners first
table(voc_mast$Post.Results, useNA = "ifany")
# filter results 
voc_mast<-voc_mast[which(is.na(voc_mast$Post.Results)),]
head(voc_mast) # 416/451 records to release

# git image files path
pngDir<-paste0(gitDir, "Scripts/temp/")
# create png data frame
png_files<-data.frame(png.file = list.files(pngDir))
# replace spaces in png file names
png_files$png.space<-str_replace_all(png_files$png.file, " ", "%20")
head(png_files)

# parse sample ids and trim extra spaces
png_files$Sample.ID<-str_trim(str_split(png_files$png.file, "_", simplify = TRUE)[,1])
tail(png_files)
# create full url 
git_url<-"https://github.com/cshuler/VOC_Processing_Maui/blob/main/Scripts/temp/"
png_files$url.link<-paste0(git_url, png_files$png.space, "?raw=true")
head(png_files)
tail(png_files)

### IMAGE RESULTS ###

# add urls to results in master sheet by match with all upper case
voc_mast$Results.Link<-png_files$url.link[match(toupper(voc_mast$Sample.ID),
                                                toupper(png_files$Sample.ID))]
head(voc_mast)
tail(voc_mast)
table(is.na(voc_mast$Results.Link)) # 382 results matched
# 34 missing results
voc_mast[,1][is.na(voc_mast$Results.Link)]

# 55 unreleased png files
no_png<-anti_join(png_files, voc_mast)
# head(no_png)
no_png$png.file
# 47 samples with no results
no_mast<-anti_join(voc_mast, png_files)
# head(no_mast)
no_mast$Sample.ID

### MANUAL EDITS ###

# change png list to match master
# "no_png$png.file"<-voc_mast[,1][is.na(voc_mast$Results.Link)]

# "31_.png"<-"08-25-CKS-31"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "08-25-CKS-31")]<-
  png_files$url.link[which(png_files$png.file == "31_.png")]

# "E-1-A_.png"<-"E-1"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "E-1")]<-
  png_files$url.link[which(png_files$png.file == "E-1-A_.png")]

# "9-26-JES-1_.png"<-"9-29-JES-1"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-29-JES-1")]<-
  png_files$url.link[which(png_files$png.file == "9-26-JES-1_.png")]

### PREVIOUS MANUAL EDITS IF NEEDED ###
# "8-30-23-KELLIE-1_.png"<-"8-30-23-kellie-1"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "8-30-23-kellie-1")]<-
  png_files$url.link[which(png_files$png.file == "8-30-23-KELLIE-1_.png")]
# "8-30-23-KELLIE-2_.png"<-"8-30-23-kellie-2"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "8-30-23-kellie-2")]<-
  png_files$url.link[which(png_files$png.file == "8-30-23-KELLIE-2_.png")]
# "9-1-23-KELLIE-1_.png"<-"9-1-23-Kellie-1"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-1-23-Kellie-1")]<-
  png_files$url.link[which(png_files$png.file == "9-1-23-KELLIE-1_.png")]
# "9-1-23-KELLIE-2_.png"<-"9-1-23-Kellie-2"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-1-23-Kellie-2")]<-
  png_files$url.link[which(png_files$png.file == "9-1-23-KELLIE-2_.png")]
# "9-1-23-KELLIE-3_.png"<-"9-1-23-Kellie-3"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-1-23-Kellie-3")]<-
  png_files$url.link[which(png_files$png.file == "9-1-23-KELLIE-3_.png")]
# "9-14-CKS-1_.png"<-"9-14-Cks-1"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-14-Cks-1")]<-
  png_files$url.link[which(png_files$png.file == "9-14-CKS-1_.png")]
# "9-14-CKS-3_.png"<-"9-14-Cks-3"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-14-Cks-3")]<-
  png_files$url.link[which(png_files$png.file == "9-14-CKS-3_.png")]
# "9-14-CKS-5_.png"<-"9-14-Cks-5"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "9-14-Cks-5")]<-
  png_files$url.link[which(png_files$png.file == "9-14-CKS-5_.png")]
"09-14-CKS-6_.png"<-"09-14-Cks-6"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "09-14-Cks-6")]<-
  png_files$url.link[which(png_files$png.file == "09-14-CKS-6_.png")]
# "10-03-23-JL-05_nan.png"<-"10-03-23-Jl-05"
voc_mast$Results.Link[which(voc_mast$Sample.ID == "10-03-23-Jl-05")]<-
  png_files$url.link[which(png_files$png.file == "10-03-23-JL-05_nan.png")]

### ADDITIONAL MANUAL EDITS FOR FUTURE RUNS ###
# # "DBR-Spigot_unknown.png"<-"Diamond B Ranch- spigot after water"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Diamond B Ranch- spigot after water")]<-
#   png_files$url.link[which(png_files$png.file == "DBR-Spigot_unknown.png")]
# # "DBR-Trough_unknown.png"<-"Diamond B Ranch- water trough after tank"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Diamond B Ranch- water trough after tank")]<-
#   png_files$url.link[which(png_files$png.file == "DBR-Trough_unknown.png")]
# # "HR-Holo_unknown.png"<-"Haleakala Ranch- Holomalia paddock"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Haleakala Ranch- Holomalia paddock")]<-
#   png_files$url.link[which(png_files$png.file == "HR-Holo_unknown.png")]
# # "HR-Home_unknown.png"<-"Haleakala Ranch- home paddock trough"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Haleakala Ranch- home paddock trough")]<-
#   png_files$url.link[which(png_files$png.file == "HR-Home_unknown.png")]
# # "HR-Stables_unknown.png"<-"Haleakala Ranch- stables"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Haleakala Ranch- stables")]<-
#   png_files$url.link[which(png_files$png.file == "HR-Stables_unknown.png")]
# # "TLR-House_unknown.png"<-"Triple L Ranch- house spigot"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Triple L Ranch- house spigot")]<-
#   png_files$url.link[which(png_files$png.file == "TLR-House_unknown.png")]
# # "TLR-Lower_unknown.png"<-"Triple L Ranch- lower livestock trough"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Triple L Ranch- lower livestock trough")]<-
#   png_files$url.link[which(png_files$png.file == "TLR-Lower_unknown.png")]
# # "TLR-Trough_unknown.png"<-"Triple L Ranch- livestock water trough"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Triple L Ranch- livestock water trough")]<-
#   png_files$url.link[which(png_files$png.file == "TLR-Trough_unknown.png")]
# # "UR-Tank Cleaned_unknown.png"<-"Ulupalakua Ranch- Field 3 upper tank"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Ulupalakua Ranch- Field 3 upper tank")]<-
#   png_files$url.link[which(png_files$png.file == "UR-Tank Cleaned_unknown.png")]
# # "UR_Spigot_unknown.png"<-"Ulupalakua Ranch- Vineyard spigot"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Ulupalakua Ranch- Vineyard spigot")]<-
#   png_files$url.link[which(png_files$png.file == "UR_Spigot_unknown.png")]
# # "UR_Tank_unknown.png"<-"Ulupalakua Ranch- Vineyard tank"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Ulupalakua Ranch- Vineyard tank")]<-
#   png_files$url.link[which(png_files$png.file == "UR_Tank_unknown.png")]
# # "UR_Trough_unknown.png"<-"Ulupalakua Ranch- Upper livestock trough"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Ulupalakua Ranch- Upper livestock trough")]<-
#   png_files$url.link[which(png_files$png.file == "UR_Trough_unknown.png")]
# # "Z-1_ Makanoe Place, .png"<-"Z-1 House top of hill"
# voc_mast$Results.Link[which(voc_mast$Sample.ID == "Z-1 House top of hill")]<-
#   png_files$url.link[which(png_files$png.file == "Z-1_ Makanoe Place, .png")]

# 31 missing public entries
table(is.na(voc_mast$Results.Link))
voc_mast$Sample.ID[which(is.na(voc_mast$Results.Link))]
# # return only completed results samples
# voc_results<-voc_mast[which(voc_mast$Results.Link != "NA"),]  # -1

# updated adjusted xy for more randomization
#n_adj<-runif(n = dim(voc_mast)[1], min = -0.0005, max = 0.0005)
for(p in 1:dim(voc_mast)[1]){  # p = 1 
  # offset between 250-500 ft.
  xy_offset<-runif(n = 1, min = 0.0003, max = 0.00045)
  # randomly multiply by -1 or 1 to offset in different directions
  voc_mast$X_adj[p]<-as.numeric(voc_mast$X[p]) + (xy_offset * sample(c(-1, 1), 1))
  voc_mast$Y_adj[p]<-as.numeric(voc_mast$Y[p]) + (xy_offset * sample(c(-1, 1), 1))
}

# check how close coordinates are?

# rename filtered/unfiltered water sample types
table(voc_mast$SampleType, useNA = "ifany")
# unfiltered
voc_mast$FilterStatus[which(voc_mast$SampleType != "Tap Water Filtered")]<-"Unfiltered"
voc_mast$FilterStatus[which(is.na(voc_mast$SampleType))]<-"Unfiltered"
# filtered
voc_mast$FilterStatus[which(voc_mast$SampleType == "Tap Water Filtered" |
                              voc_mast$SampleType == "filtered shower water" |
                              voc_mast$SampleType == "tap filtered water" |
                              voc_mast$SampleType == "Tap Water filtered" |
                              voc_mast$SampleType == "shower filter with whole house filtration" |
                              voc_mast$SampleType == "Tap Water filtered shower and whole house filter" |
                              voc_mast$SampleType == "Tap water whole house filtration system" |
                              voc_mast$SampleType == "Tap Water whole house filtration system")]<-"Filtered"
table(voc_mast$FilterStatus, useNA = "ifany")
# check sample type by filter status
table(voc_mast$SampleType[which(voc_mast$FilterStatus == "Filtered")], useNA = "ifany")
table(voc_mast$SampleType[which(voc_mast$FilterStatus == "Unfiltered")], useNA = "ifany")

# save updated data file (csv for arc online and xlsx to view and edit)
write_csv(voc_mast, paste0(vocDir, "Maui_Master_VOC_Sheet-013124-url.csv"))

# remove all PII to publish online
names(voc_mast)
voc_public<-voc_mast[,c(1, 23:26)]
voc_public

# SAVE AS SAME FILE NAME TO SEEMLESSLY UPLOAD TO ARCGIS ONLINE!
write_csv(voc_public, paste0(vocDir, "Maui_Master_VOC_Sheet-public-url.csv"))
#write.xlsx(new_loc, paste0(vocDir, "Maui_Master_VOC_Sheet-013124.xlsx"))

### NEXT STEPS ###
# update csv in ArcGIS Online Content
# update feature layer in ArcGIS Online ("Overwrite entire feature layer")
# this will then automatically update the web map and dashboard

# push updated scripts to git (not raw data!)

### END ###