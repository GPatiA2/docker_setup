FROM aerostack2_gpu
RUN apt install -y libxcb-cursor0 libz3-dev coinor-libcbc3 ros-humble-tf-transformations -y 
RUN pip3 install rdflib reasonable textual pyperclip numpy==1.26.0 cfclient cflib pyerfa>=2.0.1.4 astropy>=6.0 utm

RUN apt update --allow-releaseinfo-change && \
    apt install -y \
        ros-humble-rclcpp-cascade-lifecycle* \
        ros-humble-ament-cmake-clang-format && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/optitrack_ws/src && \
    cd /root/optitrack_ws/src && \
    git clone https://github.com/MOCAP4ROS2-Project/mocap4ros2_optitrack.git && \
    vcs import < mocap4ros2_optitrack/dependency_repos.repos && \
    cd /root/optitrack_ws && \
    rosdep install --from-paths src --ignore-src -r -y && \
    bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"


RUN apt-get update && apt-get install -y zstd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://claude.ai/install.sh | bash && curl -fsSL https://ollama.com/install.sh | sh

RUN npm install -g opencode-ai

WORKDIR /root
