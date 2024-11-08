################################################################################
#      Race & Ethnicity Dot Maps for Dane County, WI and Johnson County, KS    #
#                 Authors: Nate Shipley                                        #
################################################################################


########################### #
## Load Libraries
########################### #
library(tidycensus) # Has all census api info
library(tidyverse) # dplyr, ggplot2, tidyr, readr
library(sf) # mapping tools 
library(viridis)
library(rgdal)
library(raptr)


########################### #
## Load CENSUS API KEY IF NEEDED
# Only need to do once, can request https://api.census.gov/data/key_signup.html
#census_api_key("YourKeyHere",install = T, overwrite = T)


########################### #
# Get Variabels (both DICENNIAL and ACS)
########################### #

vars_dec <- c(Tot_Pop = "P1_001N", # Total Population
              Tot_White = "P2_005N", # Total Population White Non-Hispanic
              Tot_Black = "P2_006N", # Total Population Black Non-Hispanic
              Tot_Asian = "P2_008N", # Total Population Asian Non-Hispanic
              Tot_HispLat = "P2_002N", # Total Population Hispanic or Latino
              Tot_AmInd = "P2_007N", # Total Population American Indian Non-Hispanic
              Tot_NaHaw = "P2_009N", # Total Population Hawaiian or Pacific Islander Non-Hispanic
              Tot_Two = "P2_011N", # Total Population Two or More Non-Hispanic
              Tot_Other = "P2_010N") # Total Population Other Non-Hispanic



########################### #
# Dane County Dec Data Block Group 2020
########################### #

# Pull Data
Dane_County_Block_Group_2020_DEC <- tidycensus::get_decennial(geography = "block group",
                                                              variables = vars_dec,
                                                              state = "WI",
                                                              county = "Dane",
                                                              year = 2020,
                                                              geometry = T, #this adds the geometry SF
                                                              output= "wide")


# Remove the Lakes
Dane_County_Block_Group_2020_DEC <- Dane_County_Block_Group_2020_DEC %>%
  filter(!(GEOID == '550259917020'|GEOID == '550259917030'))


# First lets join all other races into an OTHER group
Dane_County_Block_Group_2020_DEC$Total_Other <- (Dane_County_Block_Group_2020_DEC$Tot_AmInd + 
                                                   Dane_County_Block_Group_2020_DEC$Tot_NaHaw + 
                                                   Dane_County_Block_Group_2020_DEC$Tot_Two + 
                                                   Dane_County_Block_Group_2020_DEC$Tot_Other)

# Try to adjust for the population
Dane_County_Block_Group_2020_DEC$Tot_White <- round(Dane_County_Block_Group_2020_DEC$Tot_White/5, 0)
Dane_County_Block_Group_2020_DEC$Tot_Black <- round(Dane_County_Block_Group_2020_DEC$Tot_Black/5, 0)
Dane_County_Block_Group_2020_DEC$Tot_Asian <- round(Dane_County_Block_Group_2020_DEC$Tot_Asian/5, 0)
Dane_County_Block_Group_2020_DEC$Tot_HispLat <- round(Dane_County_Block_Group_2020_DEC$Tot_HispLat/5, 0)
Dane_County_Block_Group_2020_DEC$Total_Other <- round(Dane_County_Block_Group_2020_DEC$Total_Other/5, 0)

# Now create population samples
Dane_County_BG_DEC_Pop_White <- st_sample(Dane_County_Block_Group_2020_DEC,
                                          Dane_County_Block_Group_2020_DEC$Tot_White, by_polygon=T)

Dane_County_BG_DEC_Pop_Black <- st_sample(Dane_County_Block_Group_2020_DEC,
                                          Dane_County_Block_Group_2020_DEC$Tot_Black, by_polygon=T)

Dane_County_BG_DEC_Pop_Asian <- st_sample(Dane_County_Block_Group_2020_DEC,
                                          Dane_County_Block_Group_2020_DEC$Tot_Asian, by_polygon=T)

Dane_County_BG_DEC_Pop_HispLat <- st_sample(Dane_County_Block_Group_2020_DEC,
                                            Dane_County_Block_Group_2020_DEC$Tot_HispLat, by_polygon=T)

Dane_County_BG_DEC_Pop_Other <- st_sample(Dane_County_Block_Group_2020_DEC,
                                          Dane_County_Block_Group_2020_DEC$Total_Other, by_polygon=T)


Dane_County_BG_DEC_Population_Dot_Map <- ggplot() + 
  geom_sf(data = Dane_County_Block_Group_2020_DEC,alpha=.05) +
  theme_classic() + 
  labs(title = "Racial Dot Map of Dane County by Block Group, 2020 Census") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme(axis.line = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        plot.title = element_text(size = 16, face = "bold")) + 
  geom_sf(data = Dane_County_BG_DEC_Pop_Asian, color = "#FF0000", size = .01, alpha=.1) +
  geom_sf(data = Dane_County_BG_DEC_Pop_Black, color = "#55FF00", size = .01, alpha=.1) + 
  geom_sf(data = Dane_County_BG_DEC_Pop_HispLat, color = "#FFAA00", size = .01, alpha=.1) + 
  geom_sf(data = Dane_County_BG_DEC_Pop_Other, color = "#895A44", size = .01, alpha=.1) + 
  geom_sf(data = Dane_County_BG_DEC_Pop_White, color = "#73B2FF", size = .01, alpha=.1)

ggsave(Dane_County_BG_DEC_Population_Dot_Map, file = './Dane_County_BG_DEC_Population_Dot_Map_v1.jpg', width = 10.6, height = 7.1)






########################### #
# Johnson County Dec Data Block Group 2020
########################### #

# Pull Data
Johnson_County_Block_Group_2020_DEC <- tidycensus::get_decennial(geography = "block group",
                                                              variables = vars_dec,
                                                              state = "KS",
                                                              county = "Johnson",
                                                              year = 2020,
                                                              geometry = T, #this adds the geometry SF
                                                              output= "wide")


# First lets join all other races into an OTHER group
Johnson_County_Block_Group_2020_DEC$Total_Other <- (Johnson_County_Block_Group_2020_DEC$Tot_AmInd + 
                                                      Johnson_County_Block_Group_2020_DEC$Tot_NaHaw + 
                                                      Johnson_County_Block_Group_2020_DEC$Tot_Two + 
                                                      Johnson_County_Block_Group_2020_DEC$Tot_Other)

# Try to adjust for the population
# Johnson_County_Block_Group_2020_DEC$Tot_White <- round(Johnson_County_Block_Group_2020_DEC$Tot_White/2, 0)
# Johnson_County_Block_Group_2020_DEC$Tot_Black <- round(Johnson_County_Block_Group_2020_DEC$Tot_Black/2, 0)
# Johnson_County_Block_Group_2020_DEC$Tot_Asian <- round(Johnson_County_Block_Group_2020_DEC$Tot_Asian/2, 0)
# Johnson_County_Block_Group_2020_DEC$Tot_HispLat <- round(Johnson_County_Block_Group_2020_DEC$Tot_HispLat/2, 0)
# Johnson_County_Block_Group_2020_DEC$Total_Other <- round(Johnson_County_Block_Group_2020_DEC$Total_Other/2, 0)

# Now create population samples
Johnson_County_BG_DEC_Pop_White <- st_sample(Johnson_County_Block_Group_2020_DEC,
                                             Johnson_County_Block_Group_2020_DEC$Tot_White, by_polygon=T)

Johnson_County_BG_DEC_Pop_Black <- st_sample(Johnson_County_Block_Group_2020_DEC,
                                             Johnson_County_Block_Group_2020_DEC$Tot_Black, by_polygon=T)

Johnson_County_BG_DEC_Pop_Asian <- st_sample(Johnson_County_Block_Group_2020_DEC,
                                             Johnson_County_Block_Group_2020_DEC$Tot_Asian, by_polygon=T)

Johnson_County_BG_DEC_Pop_HispLat <- st_sample(Johnson_County_Block_Group_2020_DEC,
                                               Johnson_County_Block_Group_2020_DEC$Tot_HispLat, by_polygon=T)

Johnson_County_BG_DEC_Pop_Other <- st_sample(Johnson_County_Block_Group_2020_DEC,
                                             Johnson_County_Block_Group_2020_DEC$Total_Other, by_polygon=T)


Johnson_County_BG_DEC_Population_Dot_Map <- ggplot() + 
  geom_sf(data = Johnson_County_Block_Group_2020_DEC,alpha=.05) +
  theme_classic() + 
  labs(title = "Racial Dot Map of Dane County by Block Group, 2020 Census") +
  scale_x_continuous(expand = c(0, 0)) + 
  scale_y_continuous(expand = c(0, 0)) + 
  theme(axis.line = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        plot.title = element_text(size = 16, face = "bold")) + 
  geom_sf(data = Johnson_County_BG_DEC_Pop_Asian, color = "#FF0000", size = .01, alpha=.1) +
  geom_sf(data = Johnson_County_BG_DEC_Pop_Black, color = "#55FF00", size = .01, alpha=.1) + 
  geom_sf(data = Johnson_County_BG_DEC_Pop_HispLat, color = "#FFAA00", size = .01, alpha=.1) + 
  geom_sf(data = Johnson_County_BG_DEC_Pop_Other, color = "#895A44", size = .01, alpha=.1) + 
  geom_sf(data = Johnson_County_BG_DEC_Pop_White, color = "#73B2FF", size = .01, alpha=.1)

ggsave(Johnson_County_BG_DEC_Population_Dot_Map, file = './Johnson_County_BG_DEC_Population_Dot_Map_v1.jpg', width = 10.6, height = 7.1)











