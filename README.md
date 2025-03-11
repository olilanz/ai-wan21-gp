# Wan2GP: Wan2.1 Video Generation for the GPU Poor

Containerized version of the Wan2.1 video generator. It is based on the Wan2.1 project, with deepmeepbeep's optimizations for the GPU-poor. It lets you run a quantized version on your smaller GPU, e.g. as low as 6GB of VRAM (22GB optimal).

Tested on RTX 3060 12GB and RTX 3090 TI. On low VRAM cards, it may still work. Though, there will be limitations to video quality, length and inference speed. Currently, only NVIDIA CPU's are supported, as the code relies on CUDA for the processing. 

During first start-up the container will acquire the latest code from [deepmeepbeep's repo](https://github.com/deepbeepmeep/Wan2GP) and the latest Wan-AI model from [Huggingface](https://huggingface.co/Wan-AI).

## Disk size and startup time

The container requires considerable disk space for storage of the AI models. On my setup I observe 7GB for the docker image itself, plus 80GB for cached data. Building the cache will happen the first time when you start the container. That can easily take 20 minutes or more. After that any restart should be faster.

It may be advisable to store the cache outside of the conatiner, e.g. by mounting a volume to /workspace.

## Variables

WAN21_AUTO_UPDATE: Automatically updates the models and inference scripts to the latest version upon container start-up (default: 0).
 - 0: Don't update automatically. Use the scripts that are bundled.
 - 1: Update and use the latest features / models. But also accept that this may being breaking changes.

This container does not provide much configuration, as many other configuration parameters can be changed through the web interface.

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

A video for 5 seconds in 480p takes me about 10 minutes to render - with 30 inference steps and other high quality settings, e.g. 14b model.

## Resources
* For the GPU-Poor: https://github.com/deepbeepmeep/Wan2GP
* For the non-GPU-Poor: https://github.com/Wan-Video/Wan2.1

