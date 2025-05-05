FROM osrf/ros:humble-desktop-full

ARG USERNAME=ovali

SHELL ["bash", "-c"]

RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

# Gerekli ROS paketlerini kurma
RUN apt-get update && apt-get install -y \
    ros-humble-turtlebot3* \
    python3-pyqt5.qtmultimedia \
    sudo \
    ros-humble-nav2-bringup \
    ros-humble-navigation2 \
    ros-humble-rviz2 \
    ros-humble-tf2-sensor-msgs \
    ros-humble-geographic-msgs \
    ros-humble-cartographer \
    ros-humble-cartographer-ros \
    ros-humble-realsense2-camera \
    ros-humble-robot-localization \
    git \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

RUN apt install cppzmq-dev ros-humble-ros-gz -y --no-install-recommends --no-install-suggests || true

RUN mkdir -p /home/$USERNAME/ros2_ws/src && \
    cd /home/$USERNAME/ros2_ws/src && \
    git clone https://github.com/ros/ros_tutorials.git -b humble && \
    git clone https://github.com/yagmurke/orbit_docker.git && \
    cd /home/$USERNAME/ros2_ws && \
    source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install

RUN apt update && apt install -y \
    python3-pip \
    ffmpeg \
    libsndfile1 \
    libasound2-dev \
    alsa-utils \
    && python3 -m pip install -U \
        colcon-common-extensions  \
        minimalmodbus   \
        librosa    \
        langdetect \
        pygame \
        sounddevice \
        pydub \
        speechrecognition \
    && python3 -m pip uninstall -y numpy





USER $USERNAME
WORKDIR /home/$USERNAME


RUN echo "if [ -f /etc/bash_completion ]; then" >> ~/.bashrc && \
    echo "  . /etc/bash_completion" >> ~/.bashrc && \
    echo "fi" >> ~/.bashrc && \
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /home/$USERNAME/ros2_ws/install/setup.bash" >> ~/.bashrc && \
    echo "export TURTLEBOT3_MODEL=waffle" >> ~/.bashrc && \
    echo "source /usr/share/gazebo/setup.sh" >> ~/.bashrc && \
    echo "export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/opt/ros/humble/share/turtlebot3_gazebo/models" >> ~/.bashrc && \
    echo "export ROS_LOCALHOST_ONLY=1" >> ~/.bashrc
USER root
RUN chmod 644 /root/.bashrc && \
        chown $USERNAME:$USERNAME /root/.bashrc && \
        chmod 644 /home/$USERNAME/ros2_ws/install/setup.bash && \
        chown $USERNAME:$USERNAME /home/$USERNAME/ros2_ws/install/setup.bash


CMD ["bash"]
