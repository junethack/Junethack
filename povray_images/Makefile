# This makefile renders all the pov files in 400x300 (except the front view 
# in 800x600). The resulting images will be transparent and somewhat usable
# on the web though they may need some resizing.
#
# USE POVRAY 3.7!!!!!11
# povray 3.6 doesn't render alpha channel onto the PNGs correctly for some
# reason.

.PHONY: all ascended grand_prize genders most_ascensions most_ascensions_streak pudding_award front_view

all: ascended grand_prize genders most_ascensions most_ascensions_streak front_view pudding_award

# Ascended
# A plain trophy without a seal
ascended:
	povray +A +AM2 +W400 +H300 +UA web_view.pov

# Grand prize
# Like the Ascended trophy but with a seal
grand_prize:
	povray +A +AM2 +W400 +H300 +UA grand_prize.pov

# Genders
# Two trophies, one pink, one blue
genders:
	povray +A +AM2 +W400 +H300 +UA genders.pov

# Most Ascensions
# Many trophies side by side without seals
most_ascensions:
	povray +A +AM2 +W400 +H300 +UA most_ascensions.pov

# Longest Ascension Streak
# Many trophies side by side with seals
most_ascensions_streak:
	povray +A +AM2 +W400 +H300 +UA most_ascensions_streak.pov

# P letters. (looks a little crappy IMO --Adeon)
pudding_award:
	povray +A +AM2 +W400 +H300 +P +UA pudding_award.pov

# Large render for seeing details on the trophy
front_view:
	povray +A +AM2 +W800 +H600 +UA front_view.pov

