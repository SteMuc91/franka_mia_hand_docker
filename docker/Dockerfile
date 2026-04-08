# Start with an official ROS 2 base image for the desired distribution
FROM ros:jazzy-ros-base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=jazzy \
    RCUTILS_COLORIZED_OUTPUT=1

ARG USER_UID=1001
ARG USER_GID=1001
ARG USERNAME=user

## MuJuCo version
ARG MUJOCO_VERSION=3.3.4
ARG CPU_ARCH=x86_64

# Delete user if it exists in container 
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

# Add Isaac ROS apt repo for Jazzy to install topic-based-ros2-control
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    mkdir -p /usr/share/keyrings && \
    curl -fsSL https://isaac.download.nvidia.com/isaac-ros/repos.key \
    | gpg --dearmor -o /usr/share/keyrings/isaac-ros-archive-keyring.gpg && \
    . /etc/os-release && \
    printf 'deb [signed-by=/usr/share/keyrings/isaac-ros-archive-keyring.gpg] https://isaac.download.nvidia.com/isaac-ros/release-4 %s main\n' "${VERSION_CODENAME}" \
    > /etc/apt/sources.list.d/isaac-ros.list && \
    apt-get update;

# Install essential packages and ROS development tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bash-completion \
    cmake \
    curl \
    gdb \
    git \
    nano \
    openssh-client \
    python3-colcon-argcomplete \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-rosdep \
    mesa-utils \
    libgl1-mesa-dri \
    libglu1-mesa \
    libglvnd0 \
    libglx-mesa0 \
    libegl1 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    sudo \
    vim \
    libserial-dev \
    setserial \
    python3-pip \
    wget \
    libgtest-dev \
    libgmock-dev \
    qtbase5-dev \
    libqt5svg5-dev \
    libqt5opengl5-dev  \
    libzmq3-dev \
    libdw-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libglfw3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure and install MuJoCo
ENV MUJOCO_VERSION=${MUJOCO_VERSION}
ENV MUJOCO_DIR="/opt/mujoco/mujoco-${MUJOCO_VERSION}"
## add also LD_LIBRARY_PATH as ENV for running the docker compose service for mujoco simulation
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${MUJOCO_DIR}/lib
RUN mkdir -p ${MUJOCO_DIR}

RUN wget https://github.com/google-deepmind/mujoco/releases/download/${MUJOCO_VERSION}/mujoco-${MUJOCO_VERSION}-linux-${CPU_ARCH}.tar.gz
RUN mkdir -p /home/mujoco
RUN tar -xzf "mujoco-${MUJOCO_VERSION}-linux-${CPU_ARCH}.tar.gz" -C $(dirname "${MUJOCO_DIR}")

# Setup user configuration
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -a -G dialout $USERNAME \ 
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> /home/$USERNAME/.bashrc \
    && echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$MUJOCO_DIR/lib"  >> /home/$USERNAME/.bashrc \
    && echo "export PS1='\u@\h:\[\e[32m\]\w\[\e[0m\]\$ '" >> /home/$USERNAME/.bashrc 

USER $USERNAME

# Install some ROS 2 dependencies to create a cache layer
RUN sudo apt-get update \
    && sudo apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-gz-sim-vendor \
    ros-${ROS_DISTRO}-gz-plugin-vendor \
    ros-${ROS_DISTRO}-sdformat-urdf \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-ros2controlcli \
    ros-${ROS_DISTRO}-controller-interface \
    ros-${ROS_DISTRO}-hardware-interface-testing \
    ros-${ROS_DISTRO}-ament-cmake-clang-format \
    ros-${ROS_DISTRO}-ament-cmake-clang-tidy \
    ros-${ROS_DISTRO}-controller-manager \
    ros-${ROS_DISTRO}-ros2-control-test-assets \
    ros-${ROS_DISTRO}-hardware-interface \
    ros-${ROS_DISTRO}-transmission-interface \
    ros-${ROS_DISTRO}-control-msgs \
    ros-${ROS_DISTRO}-backward-ros \
    ros-${ROS_DISTRO}-generate-parameter-library \
    ros-${ROS_DISTRO}-realtime-tools \
    ros-${ROS_DISTRO}-joint-state-publisher \
    ros-${ROS_DISTRO}-joint-state-broadcaster \
    ros-${ROS_DISTRO}-moveit-setup-assistant \
    ros-${ROS_DISTRO}-moveit-ros-move-group \
    ros-${ROS_DISTRO}-moveit-kinematics \
    ros-${ROS_DISTRO}-moveit-planners \
    ros-${ROS_DISTRO}-moveit-planners-ompl \
    ros-${ROS_DISTRO}-moveit-ros-visualization \
    ros-${ROS_DISTRO}-joint-trajectory-controller \
    ros-${ROS_DISTRO}-moveit-simple-controller-manager \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-joint-limits \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    ros-${ROS_DISTRO}-joy \
    ros-${ROS_DISTRO}-teleop-twist-joy \
    ros-${ROS_DISTRO}-rqt-controller-manager \
    ros-${ROS_DISTRO}-rqt-joint-trajectory-controller \
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers \
    ros-${ROS_DISTRO}-ros2-controllers-test-nodes \
    ros-${ROS_DISTRO}-ros2-control-cmake \
    ros-${ROS_DISTRO}-ros-gz \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ros-${ROS_DISTRO}-pinocchio \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ros-${ROS_DISTRO}-test-msgs \
    ros-${ROS_DISTRO}-moveit-resources-panda-moveit-config \
    ros-${ROS_DISTRO}-topic-based-ros2-control \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /home/$USERNAME/.bashrc

WORKDIR /ros2_ws

# Install the missing ROS 2 dependencies
COPY ../deps /ros2_ws/src

RUN sudo chown -R $USERNAME:$USERNAME /ros2_ws \
    && vcs import src < src/dependency.repos --recursive --skip-existing \
    && vcs import src < src/franka_ros2.repos --recursive --skip-existing \
    && vcs import src < src/mia_hand.repos --recursive --skip-existing \
    && vcs import src < src/manymove.repos --recursive --skip-existing 

RUN git clone --recurse-submodules https://github.com/pastoriomarco/Groot.git 
RUN cd Groot \ 
    && cmake -S . -B build  \
    && cmake --build build --parallel 

COPY ./docker/franka_mia_hand_entrypoint.sh /franka_mia_hand_entrypoint.sh
RUN sudo chmod +x /franka_mia_hand_entrypoint.sh


