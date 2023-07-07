import datetime
import time
import cv2
import picamera2
from picamera2.encoders import H264Encoder
from picamera2 import MappedArray
from picamera2.outputs import FfmpegOutput
import argparse
import logging

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

logging.basicConfig(filename='/home/' + args.annotation_text + '/camera_error.log',
                    level=logging.DEBUG,
                    format='%(asctime)s %(levelname)s %(name)s %(message)s')
logger = logging.getLogger(__name__)

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

try:
    camera = picamera2.Picamera2()
    configuration = camera.create_video_configuration()
    camera.configure(configuration)

    camera.pre_callback = apply_timestamp

    camera.video_configuration.size = (1640, 1232)
    camera.set_controls({"FrameRate": 24})

    camera.start_recording(encoder, output)
    time.sleep(300)
    camera.stop_recording()
except Exception as e:
    logger.error(e)
