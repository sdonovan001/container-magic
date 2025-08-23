## docker pull 
The docker pull command downloads a container image from a remote registry to your local machine.

## Union File System
Docker leverages a union file systems, such as OverlayFS, primarily for its ability to implement copy-on-write (CoW) semantics and layered file systems, which are fundamental to Docker's efficiency and functionality.

### Image Layering and Efficiency
Docker images are composed of multiple read-only layers. Overlay file systems allow these layers to be stacked on top of each other, presenting a unified view of the file system. This means common base layers are shared across multiple images and containers, preventing data duplication and significantly reducing disk space usage.

### Copy-on-Write for Container Isolation and Performance
When a container is launched from an image, an overlay file system creates a thin, writable layer on top of the read-only image layers. Any modifications made within the container are written only to this new, upper layer, leaving the original image layers untouched. This CoW mechanism ensures:

* **Isolation:** Changes in one container do not affect other containers or the base image.
* **Speed:** New containers can be launched almost instantly as they don't require copying entire images.
* **Resource Efficiency:** Only the modified data is stored, saving disk space and I/O.
