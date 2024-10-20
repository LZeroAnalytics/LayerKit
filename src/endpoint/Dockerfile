FROM node:18-bullseye-slim

# Specify branch
ARG LAYERZERO_CONTRACTS_BRANCH=main

# Install essential tools
RUN apt-get update && \
    apt-get install -y git docker.io python3 build-essential curl jq

# Set the working directory
WORKDIR /workspace

# Clone the LayerZero contracts repository
RUN git clone --no-checkout https://github.com/LayerZero-Labs/LayerZero-v2.git ./
RUN git checkout ${LAYERZERO_CONTRACTS_BRANCH}

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="${PATH}:/root/.foundry/bin"

# Run foundryup to install Foundry
RUN foundryup

# Switch to evm contracts
WORKDIR /workspace/packages/layerzero-v2/evm/protocol

# Install dependencies
RUN yarn install

# Build all the contracts
RUN yarn build

WORKDIR /workspace/packages/layerzero-v2/evm/messagelib
RUN forge build

WORKDIR /workspace/packages/layerzero-v2/evm/protocol

ENTRYPOINT ["/bin/bash"]
