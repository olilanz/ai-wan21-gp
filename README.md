# HunyuanVideoGP: Large Video Generation for the GPU Poor

Containerised version of the Hunyuan Video generator. It is based on the HunyuanVideo project, with deepmeepbeep's optimizations for the GPU-poor. It lets you run a quantized version of the full model on your smaller GPU, e.g. with 12GB of VRAM or even less.

Tested on RTX 3060 12GB, RTX 3090 TI, L40 and H100. On log VRAM cards, it may still work. Though, there will be limitations to video video quality and inference speed. Currently, only NVIDIA CPU's are supported, as the code relies on CUDA for the processing. 

During first start-up the container will acquire the latest model and code from [deepmeepbeep's repo](https://github.com/deepbeepmeep/HunyuanVideoGP) and the latest tencent/HunyuanVideo model from [Huggingface](https://huggingface.co/tencent/HunyuanVideo).

## Disk size and startup time

The container requires considerable disk space for storage of the AI models. On my setup I observe 7GB for the docker image itself, plus 15GB for cached data. Building the cache will happen the first time when you start the container. That can easily take 20 minutes or more. After that any restart should be faster.

It may be advisable to store the cache outside of the conatiner, e.g. by mounting a volume to /workspace.

## Variables

YUEGP_AUTO_UPDATE: Automatically updates the models and inference scripts to the latest verion upon container start-up (default: 0).
 - 0: Don't update automatically. Use the scripts that are bundled.
 - 1: Update and use the latest features / models. But also accept that this may being breaking changes.

This conatiner does not provide much confguration, as many other configuration parameters can be changed through the web interface.

### Fixing caching issues

As the container updates the models to the latest available version, there is no guarantee that the cached files from previous start-ups are compatible with updated versions. I haven't encountered any issue yet. Though, should you run into issues, just removing the cache folder will cause the startup script to rebuild the cache from scratch, and thereby fix any inconsistencies.

## Command reference

### Build the container

Building the container is straight forward. It will build the container, based on NVIDIA's CUDA development container, and add required Python dependencies for bootstrapping HunyuanVideoGP. 

```bash
docker build -t olilanz/ai-wan21-gp .
```

### Running the container

On my setup I am using the following parameters: 

```bash
docker run -it --rm --name ai-wan21-gp \
  --shm-size 24g --gpus all \
  -p 7861:7860 \
  -v /mnt/cache/appdata/ai-wan21-gp:/workspace \
  -e WAN21_AUTO_UPDATE=1 \
  olilanz/ai-wan21-gp
```
Note that you need to have an NVIDIA GPU installed, including all dependencies for Docker.

### Environment reference

I am running on a computer with an AMD Ryzen 7 3700X, 128GB Ram, an RTX 3090 TI with 24GB VRAM. CPU and Ram are plentiful. It runs stable in that configuration. The web UI handles out-of-memory errors gracefully. In case this happens, you can easily tweak the settings to balance the quality/speed/VRAM-requirements.

A video for 5 seconds in 960x544 (16:9, 540p) takes me about 15 minutes to render - with 40 infere steps and othere high quiality settings. 

## Resources
* For the GPU-Poor: https://github.com/deepbeepmeep/HunyuanVideoGP
* For the non-GPU-Poor: https://github.com/Tencent/HunyuanVideo

