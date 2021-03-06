# -*- coding: utf-8 -*-
# # # Cartograms in R,
# # from http://127.0.0.1:30455/library/cartogram/html/cartogram_ncont.html with demo below: 

# +
if (!require(maptools)) { install.packages("maptools") ; require(maptools)}
if (!require(tmap)) { install.packages("tmap") ; require(tmap)}
if (!require(cartogram)) { install.packages("cartogram") ; require(cartogram)}#install.packages("cartogram")
if (!require(rgdal)) { install.packages("rgdal") ; require(rgdal)}
if (!require(magrittr)) { install.packages("magrittr") ; require(magrittr)}

data(wrld_simpl)
# -

epsg.df <- rgdal::make_EPSG()

epsg.df[sample(nrow(epsg.df)),]

# ## Mercator projection and variants 
# Mercator projection is epsg:3395 in Proj. 

epsg.df[epsg_list$code =="3395",]

epsg.df[sample(    which(grepl(pattern = "Mercator", epsg.df$prj_method, fixed = TRUE)),10),]
#?grepl
?sample

# ## Remove uninhabited regions and choose continents 
# based on wrld_simpl$REGION

# +
names(wrld_simpl)

unique(wrld_simpl$REGION)
# -

summary(wrld_simpl)#[c("ISO2",'ISO3',"UN","AREA","REGION")]

wrld_simpl[wrld_simpl$ISO2 =="RU",]

wrld_simpl[wrld_simpl$ISO2 =="NL","POP2005"] 
wrld_simpl[wrld_simpl$ISO2 =="IT","POP2005"] 

wrld_simpl[wrld_simpl$ISO2 =="NL","POP2005"]<- as.double(16327690.0)
wrld_simpl[wrld_simpl$ISO2 =="IT","POP2005"] <- as.double(58646360.0)

# ### epsg is deprecated, better to use WKT. see 

Afr <- spTransform(wrld_simpl[wrld_simpl$REGION==2 & wrld_simpl$POP2005 > 0,], CRS("+init=epsg:3395")) 
Am <- spTransform(wrld_simpl[wrld_simpl$REGION==19 & wrld_simpl$POP2005 > 0,], 
                   CRS("+init=epsg:3395"))
Asia <- spTransform(wrld_simpl[wrld_simpl$REGION==142 & wrld_simpl$POP2005 > 0,], 
                   CRS("+init=epsg:3395"))
Eur<- wrld_simpl[wrld_simpl$REGION==150 & (wrld_simpl$ISO2 !="RU") & wrld_simpl$POP2005 > 0,] %>%
        spTransform(CRS("+init=epsg:3395"))


# # Create cartogram

Afr_carto <- cartogram_dorling(Afr, "POP2005")
Eur_carto <- cartogram_dorling(Eur, "POP2005")
Am_carto <-  cartogram_dorling(Am, "POP2005")
Asia_carto <-  cartogram_dorling(Asia, "POP2005")

# ## Plot

options( repr.plot.width = 9,repr.plot.res = 300,repr.plot.height = 6)#, repr.plot.res = 200) #for Jupyter only?
par(mfcol=c(2,2)) #4 in a row. 
plot(Afr, main="original")
plot(Eur, main="original")
plot(Am, main = "original")
plot(Asia, main = "original")

# +
options( repr.plot.width = 9,repr.plot.res = 300,repr.plot.height = 5)#, repr.plot.res = 200) #for Jupyter only?
par(mfcol=c(1,2)) #4 in a row. 
plot(Afr, main="distorted (sp)")
plot(Afr_carto, col = "red", add=TRUE)

plot(Eur, main="distorted (sp)")
plot(Eur_carto, col = "red", add=TRUE)
# -

# # Same with sf objects

# +
if (!require(sf)) { install.packages("sf") ; require(sf)}

Afr_sf = st_as_sf(Afr)

Afr_sf_carto <- cartogram_dorling(Afr_sf, "POP2005")
# -

# # ## Plot sf objects

# +
par(mfcol=c(1,3))
plot(Afr, main="original")

plot(Afr_carto, main="distorted (sp)")
plot(st_geometry(Afr_sf_carto), main="distorted (sf)")

#??cartogram  #full explanation of the cartogram package
# -

# ### newer version from 
# # https://inbo.github.io/tutorials/tutorials/spatial_crs_coding/
#
# eur <- spTransform(eur, CRS("+init:epsg:31370"))#31370 for belge lambert 72 projection. 
# #the ‘World Geodetic System 1984’ (WGS84) is a geodetic CRS with EPSG code 4326
# ?CRS
#
# #### construct cartogram & plot it

# +
Afr_cont <- cartogram_cont(Afr, "POP2005", itermax = 5)
tm_shape(Afr_cont) + tm_polygons("POP2005", style = "jenks") +
  tm_layout(frame = FALSE, legend.position = c("left", "bottom"))

#> Warning in CPL_crs_from_proj4string(x): GDAL Message 1: +init=epsg:XXXX syntax
#> is deprecated. It might return a CRS with a non-EPSG compliant axis order.

# -

?tm_shape

# ## Non contiguous version

# +
# construct cartogram
Afr_ncont <- cartogram_ncont(Afr, "POP2005")

# plot it
tm_shape(Afr) + tm_borders() +
  tm_shape(Afr_ncont) + tm_polygons("POP2005", style = "jenks") +
  tm_layout(frame = FALSE, legend.position = c("left", "bottom"))
# -

par(mfcol=c(1,3))
plot(Eur, main="original")
plot(Eur_carto, main="distorted (sp)")
Eur_sf = st_as_sf(Eur)
Eur_sf_carto <- cartogram_dorling(Eur_sf, "POP2005")
plot(st_geometry(Eur_sf_carto), main="distorted (sf)")

tm_shape(Eur) + tm_polygons("POP2005", style = "jenks") +
  tm_layout(frame = FALSE, legend.position = c("left", "bottom")) 

Eur_cont <- cartogram_cont(Eur, "POP2005", itermax = 5)
tm_shape(Eur_cont) + tm_polygons("POP2005", style = "jenks") +
  tm_layout(frame = FALSE, legend.position = c("left", "bottom"))

Eur_cont <- cartogram_cont(Eur, "POP2005", itermax = 20)
tm_shape(Eur_cont) + tm_polygons("POP2005", style = "jenks") +
  tm_layout(frame = FALSE, legend.position = c("left","top"))

# ## note how Italy had wrongly shrunk in the original, as well as the Netherlands. The problem is the Data: 56 million and 16 million became 5.6 and 1.6 million. 

# +
# construct cartogram
Eur_ncont <- cartogram_ncont(Eur, "POP2005")

# plot it
tm_shape(Eur) + tm_borders() +
  tm_shape(Eur_ncont) + tm_polygons("POP2005", style = "jenks") +
  tm_layout(frame = FALSE, legend.position = c("left", "bottom"))

# +
## a third set of commands from 
# -

if (!require(geojsonio)) { install.packages("geojsonio") ; require(geojsonio)}
cities <- st_read(system.file("vectors/cities.shp", package = "rgdal"))
cities

# +
cities <-   cbind(st_drop_geometry(cities),         st_coordinates(cities))
head(cities, 10) # top 10 rows

# ## sf package
# Note that also the stars package, useful to represent vector and raster data cubes, uses the below approach.
#
# Let’s check whether sf uses (for Windows: comes with) the minimal PROJ/GDAL versions that we want!

sf::sf_extSoftVersion()
