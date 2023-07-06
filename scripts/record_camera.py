import time
import picamera
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

vid_file = '/media/DATA/' + args.filename

with picamera.PiCamera(resolution = (1640, 1232), framerate = 24, sensor_mode = 4) as camera:
    camera.annotate_text = args.annotate_text
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
