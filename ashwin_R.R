library(dplyr)

crime<-read.csv("crime_file.csv")

# Total crimes by beat 
crimes_by_beat<-crime %>% group_by(HPD_Beat) %>% summarize(Total_Crimes=n())

# houston police beats data 
# downloaded from http://cohgis.mycity.opendata.arcgis.com/datasets/fb3bb02ec56c4bb4b9d0cf3b8b3e5545_4

library(rgdal)

hpd_beats_data<-readOGR(dsn="Houston_Police_Beats",layer = "Houston_Police_Beats")

crimes_by_beat<-crimes_by_beat %>% rename(Beats=HPD_Beat)

# left join both data 

hpd_beats_data@data <- left_join(hpd_beats_data@data, crimes_by_beat)


# plotting on map

library(tmap)
qtm(hpd_beats_data, "Total_Crimes") # plot the basic map

# only the completed cases
comp_cases<-hpd_beats_data[complete.cases(hpd_beats_data@data),]
qtm(comp_cases, "Total_Crimes",text="Beats",text.size = .5) # plot the basic map

crime_by_offense<-crime %>% group_by(HPD_Beat,Offense) %>% summarize(Total_Crimes=n())
