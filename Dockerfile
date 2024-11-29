# Use a minimal Ubuntu base image for better performance
FROM ubuntu:20.04


# Install required packages
RUN apt-get update && \
    apt-get install -y openssh-server sudo nano && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/#Port 22/Port 888/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Create a non-root user with sudo access
ARG USER=ubuntu
ARG UID=1000
RUN useradd -rm -d /home/$USER -s /bin/bash -u $UID -G sudo $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH keys
COPY ./docker/DemoUser/id_rsa_docker.pub /home/$USER/.ssh/authorized_keys
RUN chmod 600 /home/$USER/.ssh/authorized_keys && \
    chown -R $USER:$USER /home/$USER/.ssh

# Expose the SSH port (port 888)
EXPOSE 888

# Start SSH
CMD ["/usr/sbin/sshd", "-D"]