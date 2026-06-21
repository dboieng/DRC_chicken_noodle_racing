import cv2

pipeline0 = (
    "nvarguscamerasrc sensor-id=0 ! "
    "video/x-raw(memory:NVMM), width=1280, height=720 ! "
    "nvvidconv ! video/x-raw, format=BGRx ! "
    "videoconvert ! video/x-raw, format=BGR ! appsink"
)

pipeline1 = (
    "nvarguscamerasrc sensor-id=1 ! "
    "video/x-raw(memory:NVMM), width=1280, height=720 ! "
    "nvvidconv ! video/x-raw, format=BGRx ! "
    "videoconvert ! video/x-raw, format=BGR ! appsink"
)

left = cv2.VideoCapture(pipeline0, cv2.CAP_GSTREAMER)
right = cv2.VideoCapture(pipeline1, cv2.CAP_GSTREAMER)

while True:
    ret0, frame0 = left.read()
    ret1, frame1 = right.read()

    if ret0:
        cv2.imshow("Left", frame0)

    if ret1:
        cv2.imshow("Right", frame1)

    if cv2.waitKey(1) == 27:
        break
