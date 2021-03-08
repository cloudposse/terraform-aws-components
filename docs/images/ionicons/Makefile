# These icons are from https://github.com/ionic-team/ionicons/tree/v2.0.1/src
# They are licensed MIT Copyright (c) 2015-present Ionic (http://ionic.io/)
#   https://github.com/ionic-team/ionicons/blob/master/LICENSE
ICON_PACK ?= ionicons
ICON_VERSION ?= 2.0.1
ICON_RAW_URL ?= https://raw.githubusercontent.com/ionic-team/$(ICON_PACK)/v$(ICON_VERSION)/src/
ICON_WIDTH ?= 16
ICON_HEIGHT ?= $(ICON_WIDTH)
ICON_COLOR ?= 999999

ICONS +=  social-facebook-outline.svg
ICONS +=  social-linkedin-outline.svg
ICONS +=  social-twitter-outline.svg
ICONS +=  social-googleplus-outline.svg
ICONS +=  social-reddit-outline.svg
ICONS +=  ios-email-outline.svg

deps:
	sudo yum -y install librsvg2-tools

clean:
	rm -f *.svg

fetch:
	for icon in $(ICONS); do \
		output=$$(basename $${icon} .svg)-$(ICON_VERSION).svg; \
		curl -sSL -o $${output} $(ICON_RAW_URL)/$${icon}; \
		resize=$$(basename $${output} .svg)-$(ICON_WIDTH)x$(ICON_HEIGHT)-$(ICON_COLOR).svg; \
		rsvg-convert -a -h $(ICON_HEIGHT) -w $(ICON_WIDTH) -f svg $${output} -o $${resize}; \
		sed -i 's/rgb(0%,0%,0%)/#$(ICON_COLOR)/' $${resize}; \
	done

