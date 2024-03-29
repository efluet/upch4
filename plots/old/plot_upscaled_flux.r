
# /----------------------------------------------------------------------------#
#/    Get other plotting obj

# Get mapping theme
source("./plots/theme/theme_gif_map.r")

# Get country polygons
source("./plots/get_country_bbox_shp_for_ggplot_map.r")


# /----------------------------------------------------------------------------#
#/    get polygon of continent outline                                     -----
library(rworldmap)
data(coastsCoarse)
coastsCoarse_df <- fortify(coastsCoarse)
coastsCoarse_df <- arrange(coastsCoarse_df, id)


# /----------------------------------------------------------------------------#
#/    Get predicted flux grid

flux <- brick('../output/results/grid/upch4_med_nmolm2sec.nc')# , varname="upch4")

# Get date list
parseddates <- readRDS('../output/results/parsed_dates.rds')


# /----------------------------------------------------------------------------#
#/     Get tower locations                                               -------

bams_towers <- read.csv("../data/towers/BAMS_site_coordinates.csv")
xy <- bams_towers[,c(3,4)]

bams_towers <- data.frame(SpatialPointsDataFrame(coords = xy, data = bams_towers))
# proj4string = crs(flux)))



# /-----------------------------------------------------------------------------#
#/    Start animation & lopping                                             -----

ani.options("convert")
saveGIF({

# Loop time steps
for (t in 1:(length(names(flux)))){
	
	# /----------------------------------------------------------------------------#
	#/    Get predicted grids

	# reformat rasters  for graph in ggplot 
	flux_df <- as(flux[[t]], "SpatialPixelsDataFrame")
	flux_df <- as.data.frame(flux_df)
	names(flux_df) <- c("layer", "x", "y")

	m <- ggplot() +
		
		# background countries
		geom_polygon(data=countries_df, aes(long, lat, group=group), fill="grey90") +
		
		# Flux grid
		geom_tile(data=flux_df, aes(x=x, y=y, fill=layer)) +
		
		# Coastline
		geom_path(data=coastsCoarse_df, aes(long, lat, group=group), color='black', size=0.07) +
		
		# Tower sites
		geom_point(data=bams_towers, aes(Longitude, Latitude), 
							 color='black', fill= "green", shape=21,  size=0.4, stroke=0.1) +
		
		# Write title as month-day format
		ggtitle(substr(parseddates[t], 1, 7)) + 
		
		scale_x_continuous(limits=c(-180, 180))+
		scale_y_continuous(limits=c(-60, 90))+
		scale_fill_distiller(palette='YlOrRd', direction=1, limits=c(0, 0.02), breaks=seq(0, 0.025, 0.005))+
		
		
		guides(fill = guide_legend(title = expression(paste("Tg CH"[4]*" month"^-1)))) +
		#guides(shape = guide_legend(override.aes = list(size = 10))) +
		
		coord_equal() +

		gif_map_theme #+      
		#theme(legend.position=c(0.1, 0.3))
	
	show(m)
	
			
	}
},  movie.name = "/home/groups/robertj2/ch4_upscaling/output/figures/ch4_upscaled_v0251.gif", 
		ani.width=2000, ani.height=1000, ani.res= 800, 
		interval = 0.6, loop=TRUE, clean=TRUE)
#dev.off()
warnings()

# labs(title = paste("CH4 emission", str_sub(names(masked_flux_stack[[t]]),-10,-1), 'ymd'),
#      #subtitle = "Uscaled from 35? eddy covariance flux towers",
#      caption = "Uscaled from eddy covariance flux towers.\nNote: only showing pixels with >1% wetland area")+


# library(filesstrings)
# 
# file.move("C:/path/to/file/some_file.txt", "C:/some/other/path")


#"../output/figures/gif/ch4_upscaled_v020.gif"

##  percentage wetland
# flux <- as(masked_flux_stack[[t]], "SpatialPixelsDataFrame")
# flux <- as.data.frame(flux)
# names(flux) <- c("layer","x","y")

#flux <- flux[flux$layer > 0,]
#flux$layer <- flux$layer * 100


# # convert to discontinuous 
# my_breaks = seq(0,400,50)
# flux$layer <- cut(flux$layer, breaks = my_breaks, dig.lab=10)
# 
# # replace the categories stings to make them nicer in the legend
# flux$layer <- gsub("\\(|\\]", "", flux$layer)
# flux$layer <- gsub("\\,", "-", flux$layer)

