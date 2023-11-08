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
library(leaflet)
library(maps)

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

# data exploration
names(hui_data)
# temperature
plot(hui_data$date, hui_data$water_temp, type = "o")
# salinity
plot(hui_data$date, hui_data$salinity, type = "o")
# turbidity
plot(hui_data$date, hui_data$turbidity, type = "o")
# ph
plot(hui_data$date, hui_data$ph, type = "o")
# oxygen
plot(hui_data$date, hui_data$oxygen, type = "o")
# oxygen saturation
plot(hui_data$date, hui_data$oxygen_sat, type = "o")
# nitrogen
plot(hui_data$date, hui_data$nitrogen, type = "o")
# phosphorous 
plot(hui_data$date, hui_data$phosphorus, type = "o")
# phosphate
plot(hui_data$date, hui_data$phosphate, type = "o")
# silicate
plot(hui_data$date, hui_data$silicate, type = "o")
# nitrate
plot(hui_data$date, hui_data$nitrate_ni, type = "o")
# ammonia
plot(hui_data$date, hui_data$ammonia, type = "o")

# see data in Voyager
# bit.ly/40qg69Y 

# save data
write_csv(hui_data, paste0(huiDir, "hui_water_quality_esri_edit.csv"))

### LEAFLET MAP ###

# map legend colors
temp_pal<-colorNumeric(palette = "OrRd", domain = hui_data$water_temp)
turb_pal<-colorNumeric(palette = "YlGn", domain = hui_data$turbidity)
salt_pal<-colorNumeric(palette = "Blues", domain = hui_data$salinity)

# leaflet map
leaflet(hui_data, options = leafletOptions(minZoom = 0, maxZoom = 18)) %>% 
  addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
  addCircleMarkers(lng = ~X, lat = ~Y, group = "Temperature", 
                   color = ~temp_pal(water_temp), stroke = F, fillOpacity = 0.5,
                   label = ~water_temp,
                   labelOptions = labelOptions(textOnly = TRUE)) %>%
  addLegend("bottomleft", pal = temp_pal, values = ~water_temp,
            title = "Degrees C", opacity = 1, group = "Temperature") %>%
  addCircleMarkers(lng = ~X, lat = ~Y, group = "Turbidity", 
                   color = ~turb_pal(turbidity), stroke = F, fillOpacity = 0.5,
                   label = ~turbidity,
                   labelOptions = labelOptions(textOnly = TRUE)) %>%
  addLegend("bottomleft", pal = turb_pal, values = ~turbidity,
            title = "Turbidity", opacity = 1, group = "Turbidity") %>%
  addCircleMarkers(lng = ~X, lat = ~Y, group = "Salinity", 
                   color = ~salt_pal(salinity), stroke = F, fillOpacity = 0.5,
                   label = ~salinity,
                   labelOptions = labelOptions(textOnly = TRUE)) %>%
  addLegend("bottomleft", pal = salt_pal, values = ~salinity,
            title = "Salinity", opacity = 1, group = "Salinity") %>%
  addLayersControl(overlayGroups = c("Temperature", "Turbidity", "Salinity"),
                   options = layersControlOptions(collapsed = F)) %>%
  hideGroup(c("Turbidity", "Salinity"))


### END ###