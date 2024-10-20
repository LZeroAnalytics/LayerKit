FROM node:18-bullseye-slim

# Specify branch
ARG LAYERZERO_CONTRACTS_BRANCH=main

# Install essential tools
RUN apt-get update && \
    apt-get install -y git docker.io python3 build-essential curl jq

# Set the working directory
WORKDIR /workspace

# Clone the LayerZero contracts repository
RUN git clone --no-checkout https://github.com/tiljrd/devtools.git ./
RUN git checkout ${LAYERZERO_CONTRACTS_BRANCH}

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="${PATH}:/root/.foundry/bin"

# Run foundryup to install Foundry
RUN foundryup

# Switch to evm contracts
WORKDIR /workspace/packages/test-devtools-evm-foundry

# Install dependencies
RUN npm install

# Build all the contracts
RUN forge build

ENTRYPOINT ["/bin/bash"]
