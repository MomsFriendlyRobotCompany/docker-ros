FROM ros
RUN apt-get update \
    && apt-get upgrade -y

COPY bashrc /root/.bashrc

CMD ["/opt/ros/melodic/bin/roscore"]
