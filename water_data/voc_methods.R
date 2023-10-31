# VOC Processing Methods

### MAIN METHODS ###
# Download updated WRRC Google Sheet
# https://docs.google.com/spreadsheets/d/1lMeStcrFw_LnOJJsD5aB_aRGTKpOSq5I9Q0cIUR_vnY/edit?usp=sharing

# IF FIRST TIME:
# Run "voc_geocode.R" script

# ALL OTHER UPDATES AFTER FIRST TIME:
# Run "voc_geocode_update.R" script
# This will geocode all new WRRC entries
# NOTE: may need to manually enter some lat/long points from Google Maps
# Move previous files to "old_data/" folder for legacy checks as needed

# Pull request from WRRC git hub for water sampling png image results
# https://github.com/cshuler/VOC_Processing_Maui/tree/main/Scripts/temp
# Open "VOC_Processing_Maui" project and run "voc_git_pull.R" script

# Run "voc_png_results.R" script
# NOTE: may need to manually match sample id names in files 

# Upload new "Maui_Master_VOC_Sheet-updated-url.csv" file to AGOL
# https://services1.arcgis.com/x4h61KaW16vFs7PM/arcgis/rest/services/Maui_Master_VOC_Sheet_updated_url/FeatureServer
# Click "Update Data" and then "Overwrite entire feature layer" 
# WRRC Water Sampling Results Dashboard will then subsequently be updated
# https://www.arcgis.com/apps/dashboards/7405acc0abbb45a2b3e33f54e9162261 

### REPEAT UPDATE AT LEAST WEEKLY OR AS NEEDED ###