## docker-run.sh <IMAGE> <MAX-MEMORY> <MAX-CPU>
The docker run command creates and starts a containerized applicaion.  The caller must provide the name:label of the image, the maximum amount of memory that all processes inside the container can consume and the maximum amount of a single CPU all applications in the container can consume.
### Creates a Container
It creates a new, isolated container instance based on the specified Docker image. Isolation is achieved by leveraging a union file system to create a distinct writable top layer, namespaces to restrict the applications view of system resources and cgroups to limit the applications consumption of system resources.
### Starts the Container
After creation a container is started by executing the entrypoint defined and image build time.
## Implementation Details
### Union File System

### Cgroups

### Namespaces
