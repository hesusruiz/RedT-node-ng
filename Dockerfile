################################################
# PRODUCTION ALASTRIA NODE
# Jesus Ruiz (Jan-2023)
################################################

FROM ubuntu:22.04 AS production

# Set the timezone to yours, but this should be good for any location in CET
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set the volumes to share data with the host
VOLUME /root/alastria

# Make sure we are in the root directory
WORKDIR /root

# Run the entrypoint script, which is mapped from the host into a volume inside the container
CMD ["/bin/sh", "alastria/config/start_geth.sh" ]
