#!/bin/bash
	gst-launch-1.0 \
	v4l2src ! videoscale ! videoconvert ! video/x-raw,width=640,height=640,format=RGB,framerate=30/1,pixel-aspect-ratio=1/1 ! tee name=t \
	t. ! queue ! tensor_converter ! other/tensors,num_tensors=1,types=uint8,format=static,dimensions=3:640:640:1 ! \
	tensor_transform mode=arithmetic option=typecast:float32,add:0.0,div:255.0 ! \
	queue leaky=2 max-size-buffers=2 ! \
	tensor_filter framework=tensorflow2-lite model=yolov8s_float16.tflite ! \
	other/tensors,num_tensors=1,types=float32,format=static,dimensions=8400:84:1 ! \
	tensor_transform mode=transpose option=1:0:2:3 ! \
	tensor_decoder mode=bounding_boxes option1=yolov8 option2=./coco-80.txt option3=0 option4=640:640 option5=640:640 ! \
	video/x-raw,width=640,height=640,format=RGBA ! mix.sink_0 \
	t. ! queue ! mix.sink_1 compositor name=mix sink_0::zorder=2 sink_1::zorder=1 ! videoconvert ! autovideosink
