Instructions
============

On a Raspberry Pi (preferably a fast one, like a 3B), install the required
packages with the following commands::

    sudo apt-get install libav-tools povray povray-includes python3 \
        fonts-dejavu-core make

If you wish, edit the variables at the top of the ``Makefile`` (these allow you
to set things like the frame resolution and the number of frames to render).
The defaults produce a 720p (HD) movie with 10,000 frames (~7 minutes long at
24fps).

Finally, run::

    make

Then sit back for a long time while it renders (be aware that the defaults will
require several hundred megs of free space on your SD card).
