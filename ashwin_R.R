library(dplyr)

crime<-read.csv("crime_file.csv")



# Summarizing crimes by beats and offense types
crime_by_offense<-crime %>% group_by(HPD_Beat,Offense) %>% summarize(Total_Crimes=n())
# Number of types of offenses
num_offense<-crime_by_offense$Offense %>% unique %>% length

beats_vs_offense<-crime %>% 
                select(HPD_Beat,Offense) %>% 
                group_by(HPD_Beat,Offense) %>% 
                summarise(X=n())

library(reshape2)

beats_vs_offense<-dcast(beats_vs_offense,HPD_Beat~Offense, fill = 0 )

# Total Crimes
beats_vs_offense<-beats_vs_offense %>% mutate("Total Crimes" = rowSums(.[2:num_offense+1]))

# rename the beats column (to match with shape data) 
beats_vs_offense<-beats_vs_offense %>% rename(Beats=HPD_Beat)
# houston police beats SHAPE data 
# downloaded from http://cohgis.mycity.opendata.arcgis.com/datasets/fb3bb02ec56c4bb4b9d0cf3b8b3e5545_4

library(rgdal)

hpd_beats_data<-readOGR(dsn="Houston_Police_Beats",layer = "Houston_Police_Beats")

plot(hpd_beats_data)

# left join Beats SHAPE data and Beats_vs_offense data 

hpd_beats_data@data <- left_join(hpd_beats_data@data, beats_vs_offense)


# plotting on map

library(tmap)

# offense names 
offs_name<-names(beats_vs_offense)[-1]

# tmap plot
tplot<-function (X,Y){
  tm_shape(X) +
  tm_polygons(Y, 
              title=Y)
}

# Plotting all the beats 
tplot(hpd_beats_data,offs_name)

# only the beats for which data 
# is available
comp_cases<-hpd_beats_data[complete.cases(hpd_beats_data@data),]
tplot(comp_cases,offs_name)

