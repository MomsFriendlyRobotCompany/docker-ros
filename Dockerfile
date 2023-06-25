FROM ros:rolling-ros-base-jammy
RUN apt-get update \
    && apt-get upgrade -y

COPY bashrc /root/.bashrc

RUN apt-get install -y openssh-server sudo python3
RUN mkdir /var/run/sshd

# user:password | chpasswd
RUN useradd -ms /bin/bash kevin && echo "kevin:kevin" | chpasswd
RUN adduser kevin sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]