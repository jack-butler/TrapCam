import datetime
import time
import cv2
import picamera2
from picamera2.encoders import H264Encoder
from picamera2 import MappedArray
from picamera2.outputs import FfmpegOutput
import argparse

parser = argparse.ArgumentParser(
    prog='TrapCam',
    description='Records video from underwater cameras',
    epilog="This probably wasn't very helpful..."
)

parser.add_argument('filename', 
                    help='Filename to store the video')
parser.add_argument('-a','--annotate_text',
                    help='Annotation text to overlay onto video',
                    default='NO CAMERA NUMBER SET')

args = parser.parse_args()

vid_file = '/media/DATA/' + args.filename + '.mov'
output = FfmpegOutput(vid_file)

origin = (0, 30)
color = (255, 255, 255)
font = cv2.FONT_HERSHEY_SIMPLEX
scale = 1
thickness = 2

def apply_timestamp(request):
    timestamp = args.annotate_text + ' ' + time.strftime('%X %Y/%m/%d')
    with MappedArray(request, "main") as m:
        cv2.putText(m.array, timestamp, origin, font, scale, color, thickness)

encoder = H264Encoder(10000000)

camera = picamera2.Picamera2()
configuration = camera.create_video_configuration()
camera.configure(configuration)

camera.pre_callback = apply_timestamp

camera.video_configuration.size = (1640, 1232)
camera.set_controls({"FrameRate": 24})

camera.start_recording(encoder, output)
time.sleep(300)
camera.stop_recording()

""" with picamera2.Picamera2() as camera:
    camera.annotate_text = annotate_text
    camera.start_recording(vid_file, format = 'h264',
                           level = '4.2', 
                           intra_period = 48,
                           inline_headers = True,
                           sps_timing = True,
                           bitrate = 10000000,
                           quality = 20
                           )
    camera.wait_recording(timeout = 300)
    camera.stop_recording() 
"""
