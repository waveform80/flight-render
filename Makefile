DATA_URL=http://raspberrypi.org/files/pycon-flight-2015-09-17.csv
FRAME_WIDTH=1280
FRAME_HEIGHT=720
FRAME_COUNT=10000
FONT_PATH=/usr/share/fonts/truetype/roboto/hinted

SHELL=/bin/bash
FRAME_NUMBERS=$(shell seq -f "%05g" 0 $$(($(FRAME_COUNT) - 1)))
FRAMES=$(foreach frame,$(FRAME_NUMBERS),flight-data-$(frame).png)

all: flight-data.mp4

clean:
	#@rm -f flight-data.csv
	@rm -f flight-data.inc
	@rm -f *.png
	@rm -f *.pov-state
	@rm -f flight-data.mp4

flight-data.mp4: $(FRAMES)
	ffmpeg -f image2 -r 24 -i flight-data-%05d.png -c:v libx264 -preset slow $@

$(FRAMES): flight-data.pov flight-data.csv flight-data.py
	FONT_PATH=$(FONT_PATH) \
		FRAME_WIDTH=$(FRAME_WIDTH) \
		FRAME_HEIGHT=$(FRAME_HEIGHT) \
		FRAME_COUNT=$(FRAME_COUNT) \
		python3 flight-data.py flight-data.csv

flight-data.csv:
	wget $(DATA_URL) -O $@

