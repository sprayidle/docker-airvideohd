FROM phusion/baseimage:0.9.17

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Configure user nobody to match unRAID's settings
RUN \
usermod -u 99 nobody && \
usermod -g 100 nobody && \
usermod -d /home nobody && \
chown -R nobody:users /home

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install VLC
RUN \
  add-apt-repository ppa:mc3man/trusty-media && \
  apt-get update && \
  apt-get install -y vlc && \
  apt-get install -y vlc-plugin-libde265 && \
  apt-get install -y wget && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/*

# Download AirVideoHD
RUN wget -O /AirVideoServerHD-2.2.0.tar.bz2 "https://s3.amazonaws.com/AirVideoHD/Download/AirVideoServerHD-2.2.3.tar.bz2"

# Decompress AirVideoHD
RUN tar jxf /AirVideoServerHD-2.2.0.tar.bz2

# Copy default 
COPY server.properties /server.properties.new

### Configure Service Startup
COPY rc.local /etc/rc.local
RUN chmod a+x /etc/rc.local && \
	mkdir -p /config/logs && \
	cp -n /server.properties.new /config/server.properties && \
	chown -R nobody:users /config && \
	mkdir /conversionPath && \
	chown -R nobody:users /conversionPath && \
	mkdir /videos && \
	chown -R nobody:users /videos

RUN mkdir /etc/service/airvideohd
ADD airvideohd.sh /etc/service/airvideohd/run
RUN chown nobody:users /etc/service/airvideohd/run && \
    chmod a+x /etc/service/airvideohd/run
	
EXPOSE 45633

VOLUME ["/config", "/conversionPath", "/videos"]

### END