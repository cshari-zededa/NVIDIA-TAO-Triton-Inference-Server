FROM dustynv/tritonserver:r36.2.0

RUN rm -rf /opt/tritonserver/backends/pytorch /opt/tritonserver/tensorflow

COPY libboost_filesystem.so.1.80.0 /opt/tritonserver/lib/ 
COPY models /models

RUN echo "deb https://repo.download.nvidia.com/jetson/common r36.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-sources.list && \
    echo "deb https://repo.download.nvidia.com/jetson/t234 r36.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-sources.list && \
    echo "deb https://repo.download.nvidia.com/jetson/ffmpeg r36.3 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-sources.list

RUN apt-key adv --fetch-key https://repo.download.nvidia.com/jetson/jetson-ota-public.asc
RUN apt-get update

RUN mkdir -p /opt/nvidia/l4t-packages/ && \
    touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall && \
    rm -f /etc/ld.so.conf.d/nvidia-tegra.conf /etc/nv_tegra_release

RUN DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y install ssh nvidia-l4t-dla-compiler

# Create a new user with a password (Change `myuser` and `mypassword` as needed)
RUN useradd -m -s /bin/bash myuser && \
    echo 'myuser:mypassword' | chpasswd && \
    mkdir -p /home/myuser/.ssh && \
    chmod 700 /home/myuser/.ssh

# Configure SSH to allow password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config

#ENTRYPOINT ["/opt/tritonserver/bin/tritonserver","--model-repository=/models"]
# Start SSH service
#CMD ["bash", "-c", "service ssh start; while true; do sleep 60; done"]
