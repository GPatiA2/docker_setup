FROM aerostack2_gpu
RUN mkdir -p /root/optitrack_ws/src && \ 
    cd /root/optitrack_ws/src && \ 
    git clone https://github.com/MOCAP4ROS2-Project/mocap4ros2_optitrack.git && \ 
    vcs import < mocap4ros2_optitrack/dependency_repos.repos && \ 
    cd /root/optitrack_ws && \ 
    rosdep install --from-paths src --ignore-src -r -y && \ 
    bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"

RUN mkdir -p /root/crazyflie_ws/src && \
  cd /root/crazyflie_ws/src && \
  git clone -b ros2 https://github.com/IMRCLab/motion_capture_tracking.git && \
  cd /root/crazyflie_ws/src/motion_capture_tracking && \
  git submodule update --init --recursive && \
  cd /root/crazyflie_ws && \
  bash -c "source /opt/ros/humble/setup.bash && colcon build --packages-select motion_capture_tracking_interfaces motion_capture_tracking"

RUN apt install ros-humble-tf-transformations -y

RUN pip3 install cflib transforms3d==0.4.2 pyerfa>=2.0.1.4 astropy>=6.0 --ignore-installed
