FROM aerostack2_gpu
RUN pip3 install miniKanren
RUN pip3 install rdflib
RUN apt update --allow-releaseinfo-change && \
    apt install -y \
        ros-humble-rclcpp-cascade-lifecycle* \
        ros-humble-ament-cmake-clang-format && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
