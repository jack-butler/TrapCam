import datetime
import time
import picamera2
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

vid_file = '/media/DATA/' + args.filename + '.h264'
annotate_text = args.annotate_text + datetime.datetime.now().strftime("%X %m/%d/%Y")

encoder = H264Encoder(10000000)

camera = picamera2.Picamera2()
configuration = camera.create_video_configuration()
camera.configure(configuration)

with camera.controls as ctrl:
    ctrl.Resolution = (1640, 1232)
    ctrl.FrameRate = 24
    ctrl.Sensor_Mode = 4

camera.start_recording(encoder, vid_file)
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
