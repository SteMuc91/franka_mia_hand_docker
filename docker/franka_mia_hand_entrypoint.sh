#!/bin/bash

# for use in debug mode: 
set -ex
cd /ros2_ws
## Import mia hand and many move repo.
vcs import /ros2_ws/src < /ros2_ws/deps/mia_hand.repos --recursive --skip-existing
vcs import /ros2_ws/src  < /ros2_ws/deps/manymove.repos --recursive --skip-existing 

#
cd /ros2_ws
if [ ! -d "/ros2_ws/src/franka_ros2_repo" ]; then
    mkdir -p src/franka_ros2_repo
fi
# Import franka_ros2 and franka ros2 dependency repo.
vcs import /ros2_ws/src/franka_ros2_repo < /ros2_ws/deps/dependency.repos --recursive --skip-existing
cd src
vcs import franka_ros2_repo < /ros2_ws/deps/franka_ros2.repos --recursive --skip-existing
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

