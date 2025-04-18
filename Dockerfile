# Use the development container, which includes necessary CUDA libraries and the CUDA Compiler.
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04
# could this be a better base image? pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

# Set system variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV CUDA_HOME=/usr/local/cuda
ENV PATH="$CUDA_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"

# Ensure Python outputs everything that's printed inside the application
# (solvws the issue of not seeing the output of the application in the container)
ENV PYTHONUNBUFFERED=1

# Dynamic memory allocation for PyTorch in order to reduce memory fragmentation.
# (reduces risk of OOM eerors in low VRAM scenarios)
ENV PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# Install system dependencies in a single step to reduce layer size
RUN apt update && apt install -y \
    git \
    libgl1-mesa-glx libglib2.0-0 \
    python3.10 python3-pip python3.10-venv && \
    python3 -m pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# Package the startup script and the latest version of the HVGP repositories
WORKDIR /app

RUN git clone --single-branch --depth=1 https://github.com/deepbeepmeep/Wan2GP.git APP && \
    tar -czf APP.tar.gz APP && \
    rm -rf APP

COPY startup.sh startup.sh

# Expose the required port (make sure it's used in the startup script)
EXPOSE 7860

# Parameters for the startup script
ENV AUTO_UPDATE=0

# Default command to run the container
CMD ["bash", "./startup.sh"]
