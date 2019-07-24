FROM nvidia/cuda:9.1-cudnn7-devel

## OpenCV 3.4 Installation ##
## RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ yakkety universe" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libopenexr-dev libgdal-dev
RUN apt-get install -y build-essential cmake
RUN apt-get install -y qt5-default libvtk6-dev
RUN apt-get install -y libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev libgtk2.0-dev
RUN apt-get install -y ffmpeg
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8 
RUN apt-get install -y pkg-config
RUN apt-get install -y python-dev python-tk python3-dev python3-tk
RUN apt-get install -y unzip wget

RUN pip3 install scipy

RUN wget https://github.com/opencv/opencv/archive/3.4.0.zip
#RUN wget https://github.com/opencv/opencv_contrib/archive/3.4.zip
RUN unzip 3.4.0.zip
RUN rm 3.4.0.zip
#RUN unzip 3.4.zip -d opencv_contrib
#RUN rm 3.4.zip

WORKDIR /opencv-3.4.0
RUN mkdir build
WORKDIR /opencv-3.4.0/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
         -D WITH_FFMPEG=ON \
         -D INSTALL_PYTHON_EXAMPLES=ON \
         -D INSTALL_C_EXAMPLES=ON \
         -D OPENCV_ENABLE_NONFREE=ON \
         -D PYTHON_EXECUTABLE=/usr/bin/python3 \
         -D BUILD_EXAMPLES=OFF \
#         -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
         ..
RUN make -j12
RUN make install
RUN ldconfig

## Installing ninja-build to compile PreROIPooling
RUN apt-get install ninja-build
WORKDIR /
RUN git clone https://github.com/visionml/pytracking.git
RUN git submodule update --init  
# Downloading networks
WORKDIR /pytracking
RUN pip3 install -r requirements.txt
RUN mkdir pytracking/networks
RUN bash pytracking/utils/gdrive_download 1JUB3EucZfBk3rX7M3_q5w_dLBqsT7s-M pytracking/networks/atom_default.pth

# ECO Network
RUN bash pytracking/utils/gdrive_download 1aWC4waLv_te-BULoy0k-n_zS-ONms21S pytracking/networks/resnet18_vggmconv1.pth

RUN python3 -c "from pytracking.evaluation.environment import create_default_local_file; create_default_local_file()"
RUN python3 -c "from ltr.admin.environment import create_default_local_file; create_default_local_file()"
