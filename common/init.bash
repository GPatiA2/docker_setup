#! /bin/bash

echo "Enter docker directory: "
read docker_dir

echo "Enter base image dir"
read base_img_dir

echo "export DOCKER_CFG_DIR=$docker_dir" >> ~/.bashrc
echo "source $docker_dir/common/commands.bash" >> ~/.bashrc
echo "export DOCKER_BASE_IMG=$base_img_dir" >> ~/.bashrc
