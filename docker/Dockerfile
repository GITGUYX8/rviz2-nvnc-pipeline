FROM osrf/ros:galactic-desktop

ARG user_id=1000

ENV DEBIAN_FRONTEND=noninteractive

# noVNC/RViz2 stack + ttyd web terminal
RUN apt-get update && apt-get install -y \
    xvfb \
    openbox \
    x11vnc \
    novnc \
    websockify \
    supervisor \
    curl \
    libjansson-dev \
    libwebsockets-dev \
    libjson-c-dev \
    cmake \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd
RUN git clone https://github.com/tsl0922/ttyd.git \
    && cmake -S ttyd -B ttyd/build \
    && cmake --build ttyd/build \
    && cmake --install ttyd/build \
    && rm -rf ttyd

# noVNC page for RViz2
COPY rviz-novnc.html /opt/rviz-novnc/index.html
RUN cp -a /usr/share/novnc/core /opt/rviz-novnc/core \
    && cp -a /usr/share/novnc/vendor /opt/rviz-novnc/vendor

# RViz2 wrapper — forces software rendering, uses virtual display
COPY rviz2-wrapper.sh /usr/local/bin/rviz2-wrapper
RUN sed -i 's/\r$//' /usr/local/bin/rviz2-wrapper \
    && chmod +x /usr/local/bin/rviz2-wrapper

COPY supervisord.conf /etc/supervisord.conf

COPY ros_entrypoint.sh /ros_entrypoint.sh
RUN sed -i 's/\r$//' /ros_entrypoint.sh \
    && chmod +x /ros_entrypoint.sh

# Non-root user
RUN useradd -m --uid ${user_id} dockeruser
USER dockeruser

WORKDIR /home/dockeruser
ENV HOME=/home/dockeruser
ENV PYTHONUNBUFFERED=1

RUN mkdir -p /home/dockeruser/logs

RUN echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc

ENV PATH="/home/dockeruser/.local/bin:${PATH}"

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
