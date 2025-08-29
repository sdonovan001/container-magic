## docker-run.sh \<IMAGE\> \<MAX-MEMORY\> \<MAX-CPU\>
The docker run command creates and starts a containerized applicaion.  The caller must provide the name:label of the image, the maximum amount of memory that all processes inside the container can consume and the maximum amount of a single CPU all applications in the container can consume.
### Creates a Container
It creates a new, isolated container instance based on the specified Docker image. Isolation is achieved by leveraging a union file system to create a distinct writable top layer, namespaces to restrict the applications view of system resources and cgroups to limit the applications consumption of system resources.
### Starts the Container
The container is started by executing the entrypoint defined at image build time.
## Implementation Details
### Union File System
The `mount_storage` function mounts the images layers as an overlay file system. It gets information regarding what layers to mount from file system droppings left over from the `docker-pull.sh` command. 
### Cgroups
The `create_cgroup`, `limit_cpu`, `limit_memory` and `enter_cgroup` functions each play their respective part in limiting CPU and memory consuption of all processes running inside the container.  Note: Our bash CRI only limits CPU and memory.
### Namespaces
The last line of the `docker-run.sh` script creates a new PID and mount namespace and executes our containers entrypoint after `chroot`ing to the new file system mounted by the `mount_storage` function.  Note: Our bash CRI only supports host networking.  Bridge networking could be implemented by leveraging the network namespace (an exercise for the reader perhaps).
