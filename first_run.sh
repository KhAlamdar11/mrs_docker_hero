#!/bin/bash
set -e


IMAGE_NAME="mrs_hero_image"
CONTAINER_NAME="mrs_hero_container"

# Students: the folder of your ROS 2 package on your laptop, e.g. "~/MY_PACKAGE_NAME"
# (docs/installation.md, step 3.1). In the container it is ~/ros2_ws/src/<folder name>.
# Left empty, no package is bound.
MY_PACKAGE_PATH=""

PACKAGE_VOLUME=()
if [ -n "$MY_PACKAGE_PATH" ]; then
    MY_PACKAGE_PATH="${MY_PACKAGE_PATH/#\~/$HOME}"
    if [ ! -d "$MY_PACKAGE_PATH" ]; then
        echo "MY_PACKAGE_PATH at the top of first_run.sh must be an existing folder, or empty (now: \"$MY_PACKAGE_PATH\")."
        exit 1
    fi
    MY_PACKAGE_NAME=$(basename "$MY_PACKAGE_PATH")
    PACKAGE_VOLUME=(--volume "$MY_PACKAGE_PATH":/root/ros2_ws/src/"$MY_PACKAGE_NAME":rw)
fi


# X11 setup
XAUTH=/tmp/.docker.xauth

echo "Preparing Xauthority data..."

xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')

if [ ! -f "$XAUTH" ]; then
    if [ -n "$xauth_list" ]; then
        echo "$xauth_list" | xauth -f "$XAUTH" nmerge -
    else
        touch "$XAUTH"
    fi
    chmod a+r "$XAUTH"
fi

echo "Done."

echo ""
echo "Verifying file contents:"
file "$XAUTH"
echo "--> It should say \"X11 Xauthority data\"."
echo ""

echo "Permissions:"
ls -FAlh "$XAUTH"
echo ""


# Run container
echo "Starting container: $CONTAINER_NAME"
echo "Using image: $IMAGE_NAME"

docker run -it \
    --env DISPLAY=$DISPLAY \
    --env QT_X11_NO_MITSHM=1 \
    --env TERM=xterm-256color \
    --volume /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --volume /dev:/dev \
    --volume /var/run/dbus:/var/run/dbus:z \
    --volume "$(pwd)":/root/ros2_ws/src/hero_mrs:rw \
    "${PACKAGE_VOLUME[@]}" \
    --net host \
    --privileged \
    --gpus all \
    --name "$CONTAINER_NAME" \
    "$IMAGE_NAME" \
    bash -c "

        source /opt/ros/\$ROS2_DISTRO/setup.bash

        cd /root/ros2_ws

        # Build workspace if not built
        if [ ! -d install ]; then
            echo 'Building ROS2 workspace...'
            colcon build --symlink-install
        else
            echo 'Workspace already built.'
        fi

        source install/setup.bash

        exec bash
    "