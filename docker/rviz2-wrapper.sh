#!/bin/bash
set -e

export DISPLAY=:98
export NO_AT_BRIDGE=1
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
export QT_X11_NO_MITSHM=1
unset WAYLAND_DISPLAY
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

source /opt/ros/galactic/setup.bash
exec rviz2 "$@"
