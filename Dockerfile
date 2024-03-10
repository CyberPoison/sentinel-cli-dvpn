# Use the official Golang image as base
FROM --platform=linux/amd64 golang:latest

RUN apt-get update && apt-get install -y ca-certificates wget

# Add V2Ray APT key
RUN wget -qO - https://apt.v2raya.org/key/public-key.asc | tee /etc/apt/keyrings/v2raya.asc

# Add V2Ray APT repository
RUN echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | tee /etc/apt/sources.list.d/v2raya.list

RUN apt-get update && apt-get install -y systemd iproute2
# Install necessary packages
RUN apt-get update && apt-get install -y git curl openresolv wireguard-tools v2raya v2ray

# Set environment variables
ENV HOME /root

# Install Go
RUN go version

# Clone the repository
RUN git clone https://github.com/sentinel-official/cli-client.git "${HOME}/sentinelcli"

# Change directory to sentinelcli
WORKDIR "${HOME}/sentinelcli"

# Build and install
RUN make install

# Create a symbolic link
RUN ln -s "${HOME}/sentinelcli" /usr/local/bin/sentinelcli

# Copy setup_network.sh into the Docker container
COPY setup_network.sh /root/setup_network.sh

# Make setup_network.sh executable
RUN chmod +x /root/setup_network.sh

# Define the CMD to execute setup_network.sh
CMD ["/root/setup_network.sh"]

