#!/bin/bash

set -euo pipefail  # Exit on error, show commands, handle pipes safely

echo "🔧 Running startup script..."

# Set up environment variables
AUTO_UPDATE=${AUTO_UPDATE:-0}

CACHE_HOME="/workspace/cache"
export HF_HOME="${CACHE_HOME}/huggingface"
export TORCH_HOME="${CACHE_HOME}/torch"
CKPTS_HOME="${CACHE_HOME}/ckpts"
LORA_HOME="${CACHE_HOME}/loras"
LORA_I2V_HOME="${CACHE_HOME}/loras_i2v"
OUTPUT_HOME="/workspace/output"

echo "📂 Setting up cache directories..."
mkdir -p "${CACHE_HOME}" "${HF_HOME}"  "${TORCH_HOME}" "${CKPTS_HOME}" "${LORA_HOME}" "${LORA_I2V_HOME}" "${OUTPUT_HOME}"

# Clone or update application repository
REPO_HOME="${CACHE_HOME}/repo"
if [ ! -d "$REPO_HOME" ]; then
    echo "📥 Unpacking app repository..."
    mkdir -p "$REPO_HOME"
    tar -xzvf APP.tar.gz --strip-components=1 -C "$REPO_HOME"
fi
if [[ "$AUTO_UPDATE" == "1" ]]; then
    echo "🔄 Updating the app repository..."
    git -C "$REPO_HOME" reset --hard
    git -C "$REPO_HOME" pull
fi

# Ensure symlinks for models & output
ln -sfn "${CKPTS_HOME}" "$REPO_HOME/ckpts"
ln -sfn "${LORA_HOME}" "$REPO_HOME/lora"
ln -sfn "${LORA_I2V_HOME}" "$REPO_HOME/lora_i2v"
ln -sfn "${OUTPUT_HOME}" "$REPO_HOME/gradio_outputs"
touch "/workspace/config.json"
ln -sfn "/workspace/config.json" "$REPO_HOME/gradio_config.json"  

# Virtual environment setup
VENV_HOME="${CACHE_HOME}/venv"
echo "📦 Setting up Python virtual environment..."
if [ ! -d "$VENV_HOME" ]; then
    # Create virtual environment, but re-use globally installed packages if available (e.g. via base container)
    python3 -m venv "$VENV_HOME" --system-site-packages
fi
source "${VENV_HOME}/bin/activate"

# Ensure latest pip version
pip install --no-cache-dir --upgrade pip wheel

# Install required dependencies
echo "📦 Installing Python dependencies..."
pip -q install --no-cache-dir \
    packaging \
    torch==2.6.0 \
    torchvision  \
    torchaudio \
    --index-url https://download.pytorch.org/whl/test/cu124  
pip -q install --no-cache-dir -r "$REPO_HOME/requirements.txt" \
    flash-attn==2.7.2.post1 \
    sageattention==1.0.6

# Start the service
APP_ARGS="--server-name 0.0.0.0 --server-port 7860 --compile --profile 1 --multiple-images --verbose 2"

echo "🚀 Starting the application..."
cd "$REPO_HOME"
python3 -u gradio_server.py ${APP_ARGS} 2>&1 | tee "${CACHE_HOME}/output.log"
echo "❌ The WAN21 service has terminated."
