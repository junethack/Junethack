# This makefile renders all the pov files in 400x300 (except the front view 
# in 800x600). The resulting images will be transparent and somewhat usable
# on the web though they may need some resizing.
#
# USE POVRAY 3.7!!!!!11
# povray 3.6 doesn't render alpha channel onto the PNGs correctly for some
# reason.

# Final images have _f at the end of them (e.g. ascended_f.png).

COMMON_POVS = trophy.pov seal.pov

.PHONY: all clean postprocess

all: postprocess

clean:
	rm -f ascended.png genders.png grand_prize.png most_ascensions.png \
	      most_ascensions_density.png front_view.png pudding_award.png \
          analog_clock.png digital_clock.png ascended_f.png genders_f.png \
		  grand_prize_f.png most_ascensions_f.png \
		  most_ascensions_density_f.png front_view_f.png \
		  pudding_award_f.png lowest_score.png lowest_score_f.png

# Postprocessing normalizes the images. The parameters may need tuning...
# Current effect is just equalization. It makes colors much more vivid
# and adds contrast.
postprocess: ascended.png grand_prize.png genders.png \
             most_ascensions.png most_ascensions_density.png \
             front_view.png pudding_award.png \
			 analog_clock.png digital_clock.png \
			 lowest_score.png
	convert -equalize ascended.png ascended_f.png
	convert -equalize genders.png genders_f.png
	convert -equalize grand_prize.png grand_prize_f.png
	convert -equalize most_ascensions.png most_ascensions_f.png
	convert -equalize most_ascensions_density.png most_ascensions_density_f.png
	convert -equalize front_view.png front_view_f.png
	convert -equalize pudding_award.png pudding_award_f.png
	convert -equalize lowest_score.png lowest_score_f.png
	cp analog_clock.png analog_clock_f.png
	cp digital_clock.png digital_clock_f.png

# Lowest score (without depth)
# It's the normal trophy without seal, with a peace symbol stamped on it
lowest_score.png: ascended.png peace_symbol.png
	composite -geometry 60x60+165+0 peace_symbol.png ascended.png lowest_score.png

# Analog clock (for realtime speedruns?)
analog_clock.png: analog_clock.pov
	povray +A +AM2 +W400 +H300 +UA analog_clock.pov

# Digital clock (for gametime speedruns?)
digital_clock.png: digital_clock.pov
	povray +A +AM2 +W400 +H300 +UA digital_clock.pov

# Ascended
# A plain trophy without a seal
ascended.png: ascended.pov ${COMMON_POVS}
	povray +A +AM2 +W400 +H300 +UA ascended.pov

# Grand prize
# Like the Ascended trophy but with a seal
grand_prize.png: grand_prize.pov ${COMMON_POVS}
	povray +A +AM2 +W400 +H300 +UA grand_prize.pov

# Genders
# Two trophies, one pink, one blue
genders.png: genders.pov ${COMMON_POVS}
	povray +A +AM2 +W400 +H300 +UA genders.pov

# Most Ascensions
# Many trophies side by side without seals
most_ascensions.png: most_ascensions.pov ${COMMON_POVS}
	povray +A +AM2 +W400 +H300 +UA most_ascensions.pov

# Longest Ascension Density
# Many trophies side by side with seals
most_ascensions_density.png: most_ascensions_density.pov ${COMMON_POVS}
	povray +A +AM2 +W400 +H300 +UA most_ascensions_density.pov

# P letters. (looks a little crappy IMO --Adeon)
pudding_award.png: pudding_award.pov ${COMMON_POVS}
	povray +A +AM2 +W400 +H300 +UA pudding_award.pov

# Large render for seeing details on the trophy
front_view.png: front_view.pov ${COMMON_POVS}
	povray +A +AM2 +W800 +H600 +UA front_view.pov

