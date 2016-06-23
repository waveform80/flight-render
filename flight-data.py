import sys
import os
import io
import csv
import subprocess
import datetime as dt
from bisect import bisect
from collections import namedtuple
from itertools import tee

WIDTH = int(os.environ['FRAME_WIDTH'])
HEIGHT = int(os.environ['FRAME_HEIGHT'])
FRAMES = int(os.environ['FRAME_COUNT'])
FONT_PATH = os.environ['FONT_PATH']

class Vector(namedtuple('Vector', ('x', 'y', 'z'))):
    def __str__(self):
        return '<{self.x},{self.y},{self.z}>'.format(self=self)

FlightData = namedtuple('FlightData', (
    'temp_h',
    'temp_p',
    'humidity',
    'pressure',
    'orientation',
    'mag',
    'accel',
    'gyro',
    'timestamp',
    ))

with io.open(sys.argv[1], 'r', newline='') as in_file:
    data = [
        FlightData(
            float(temp_h),
            float(temp_p),
            float(humidity),
            float(pressure),
            Vector(float(orient_x), float(orient_z), float(orient_y)),
            Vector(float(mag_x), float(mag_y), float(mag_z)),
            Vector(float(accel_x), float(accel_y), float(accel_z)),
            Vector(float(gyro_x), float(gyro_y), float(gyro_z)),
            dt.datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S.%f')
            )
        for row in csv.reader(
            line for index, line in enumerate(in_file)
            if '\0' not in line # file ends with NULLs (truncated?)
            and index > 0 # first row is column titles
            )
        for (
            temp_h,
            temp_p,
            humidity,
            pressure,
            orient_x, orient_z, orient_y,
            mag_x, mag_y, mag_z,
            accel_x, accel_y, accel_z,
            gyro_x, gyro_y, gyro_z,
            timestamp) in (row,)
        ]

def pairwise(iterable):
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)

# Sanity check: ensure all timestamps increase
for index, (row1, row2) in enumerate(pairwise(data)):
    if row1.timestamp >= row2.timestamp:
        assert False, "Time goes backwards on line %d of %s" % (index + 1, sys.argv[1])

flight_start = dt.datetime(2015, 9, 20, 9, 14, 41) # flight data starts 3 days earlier?!
flight_end = data[-1].timestamp
flight_duration = flight_end - flight_start
frame_duration = flight_duration / FRAMES
timestamps = [r.timestamp for r in data]

for frame_num in range(FRAMES):
    frame_timestamp = flight_start + (frame_num * frame_duration)
    frame_data = data[bisect(timestamps, frame_timestamp)]
    # convert frame_timestamp to POV-Ray's weirdo format (fractional days since
    # 1st Jan 2000)
    frame_timestamp = (frame_timestamp - dt.datetime(2000, 1, 1, 0, 0, 0)).total_seconds() / 86400
    # write data to flight-data.inc file (tried using Declare on the command
    # line but bloody POV rounds such values to 6 sig figs!)
    print('Rendering frame {frame_num}'.format(**globals()))
    with io.open('flight-data.inc', 'w') as include:
        include.write("""\
#declare temp_h={frame_data.temp_h:.10f};
#declare temp_p={frame_data.temp_p:.10f};
#declare craft_orientation=<{frame_data.orientation.x:.10f},{frame_data.orientation.y:.10f},{frame_data.orientation.z:.10f}>;
#declare flight_timestamp={frame_timestamp:.10f};
""".format(**globals()))
    args = tuple(
        s.format(**globals()) for s in (
            'povray', '+W{WIDTH}', '+H{HEIGHT}', '-D', '+L{FONT_PATH}',
            '+Iflight-data.pov', '+Oflight-data-{frame_num:05d}.png',
            ))
    subprocess.check_call(args)
