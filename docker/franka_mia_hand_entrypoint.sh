#!/bin/bash

# for use in debug mode: 
set -ex
## Import dependency and mia hand repo
vcs import /ros2_ws/src < /ros2_ws/src/dependency.repos --recursive --skip-existing
vcs import /ros2_ws/src < /ros2_ws/src/mia_hand.repos --recursive --skip-existing
vcs import /ros2_ws/src  < /ros2_ws/src/manymove.repos --recursive --skip-existing \

#
cd /ros2_ws
if [ ! -d "/ros2_ws/src/franka_ros2_repo" ]; then
    mkdir -p src/franka_ros2_repo
fi
cd src
vcs import franka_ros2_repo < franka_ros2.repos --recursive --skip-existing
##
cd /ros2_ws
source /opt/ros/jazzy/setup.bash
sudo apt-get update
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y

# Creating enough /dev/ttyUSB nodes to allow Mia Hand plugging/unplugging during
# container running.
user_name="$(id -u -n)"
for port in {0..9}
do
  if ( ! [ -c /dev/ttyUSB${port} ] ); then
    sudo mknod /dev/ttyUSB${port} c 188 ${port}
    sudo chown ${user_name}:dialout /dev/ttyUSB${port}
  fi
done

exec "$@"

