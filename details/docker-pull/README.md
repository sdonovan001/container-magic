## docker pull \<your-repo-name\>/chart-app:1.0
The docker pull command downloads a container image from a remote registry to your local machine and stores it in [OCI](https://opencontainers.org/) format.  It then performs a bit of processing on the downloaded artifacts so that the image can quickly be transitioned into running state. 

## Union File System
Docker leverages a union file systems, such as OverlayFS, primarily for its ability to implement copy-on-write (CoW) semantics and layered file systems, which are fundamental to Docker's efficiency and functionality.

### Image Layering and Efficiency
Docker images are composed of multiple read-only layers. Overlay file systems allow these layers to be stacked on top of each other, presenting a unified view of the file system. This means common base layers are shared across multiple images and containers, providing data duplication and significantly reducing disk space usage.

### Copy-on-Write for Container Isolation and Performance
When a container is launched from an image, an overlay file system creates a thin, writable layer on top of the read-only image layers. Any modifications made within the container are written only to this new, upper layer, leaving the original image layers untouched. This CoW mechanism ensures:

* **Isolation:** Changes in one container do not affect other containers or the base image.
* **Speed:** New containers can be launched almost instantly as they don't require copying entire images.
* **Resource Efficiency:** Only the modified data is stored, saving disk space and I/O.

### Efficient Updates and Rollbacks
The layered structure facilitates incremental updates. When an image is updated, only the changed layers need to be downloaded, not the entire image. This also enables easy rollbacks to previous versions by simply pointing to an older set of layers.  Overlay file systems simplify the management of image layers and container data, providing a robust and efficient mechanism for Docker to handle its core operations.

## Implementation Details
### gcrane
We are cheating a bit on the pull command.  While it is interesting to explore the details of container runtime implementation WRT Linux kernel functionality, exploring the details of the image format and the minutia of how to replicate it with bash... not so much.  Our docker-pull.sh script will leverage [gcrane](https://github.com/google/go-containerregistry/blob/main/cmd/gcrane/README.md).  Gcrane is a tool created by Google to help you efficiently migrate and manage container images.  It is NOT a container runtime but its functionality is a subset of a container runtime.

### Extract Manifest / Process Configs
A container manifest is a JSON document that serves as a detailed description of an image. It is designed to be consumed by a container runtime, such as the Docker engine, to understand and correctly execute the image. We will use information in the manifest to extract and mount the images root file system, identify / export required environment variables and find the entrypoint of the image.

### Extract Layers
If we want to be able to quickly transition a pulled image to a running container, we should uncompress and untar all of the layers that make up the root file system of the image.
