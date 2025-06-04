#!/bin/bash
set -e

sed -i "s/QColor(float(r), float(g), float(b))/QColor.fromRgbF(float(r), float(g), float(b))/" \
  /opt/ros/humble/local/lib/python3.10/dist-packages/qt_dotgraph/dot_to_qt.py

# setup safe
# cp /root/.gitconfig_local /root/.gitconfig

# setup ros2 environment
echo 'alias vim=nvim' >> ~/.bashrc

cp /root/.gitconfig_local /root/.gitconfig
#git config --global --add safe.directory /root/aerostack2_ws/src/aerostack2
git config --global --add safe.directory '*'

. /opt/ros/$ROS_DISTRO/setup.sh && rosdep install --from-paths /root/aerostack2_ws/src --ignore-src -r -y
# source $AEROSTACK2_PATH/as2_cli/setup_env.bash
# echo 'source $AEROSTACK2_PATH/as2_cli/setup_env.bash' >> .bashrc
exec "$@"
