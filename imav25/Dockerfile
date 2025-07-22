FROM aerostack2_gpu

USER root

RUN rm -r /var/lib/apt/lists/*
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
 
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt update
RUN apt install -y ros-humble-librealsense2
RUN apt install -y ros-humble-pointcloud-to-laserscan
