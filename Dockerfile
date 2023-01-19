################################################
# PRODUCTION ALASTRIA NODE
# Jesus Ruiz
################################################

FROM ubuntu:22.04 AS production

# Set the timezone to yours, but this should be good for any location in CET
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install the minimum required tools in production
# mc is the Midnight Commander, small but powerful file manager
# Will make life easier if you should enter inside the container for diagnostics
RUN apt-get update
RUN apt-get -y install \
        wget \
        nano \
        vim \
        cron \
        mc \
    && apt-get autoremove \
    && apt-get clean

# Configure Midnight Commander to navigate with the arrow keys
RUN echo "sed -i 's/navigate_with_arrows=false/navigate_with_arrows=true/' /root/.config/mc/ini" > /root/mci.sh \
    && echo "/usr/share/mc/bin/mc.sh" >> /root/mci.sh

# Set the volumes to share data with the host
VOLUME /root/alastria

# Make sure we are in the root directory
WORKDIR /root

# Run the entrypoint script, which is mapped from the host into a volume inside the container
CMD ["/bin/bash", "alastria/config/start_geth.sh" ]
