# Usage Documantation

## docker pull
```
[root@host-name]# ./docker-pull.sh -h

Usage: ./docker-pull.sh <repo>/<image>:<label>
Description:    This script downloads container images from a 
                container registry to your local machine.

Options:
  -h            Display this usage message and exit.

Arguments:
  repo:         Name of the docker repo to pull from.
  image:        Name of the image to pull from the remote repo.
  label:        Label attached to the image.
```
## docker images
```
[root@host-name]# ./docker-images.sh -h

Usage: ./docker-images.sh
Description: This script displays container images that have been 
             pulled locally.

Options:
  -h         Display this usage message and exit.

Arguments:
  None
```
## docker run
```
[root@host-name]# ./docker-run.sh -h
Error: Not enough args!

Usage: ./docker-run.sh <image> <max-memory> <max-cpu>
Description:    This script creates and starts a new container from an image.

Options:pause
  -h            Display this usage message and exit.

Arguments:
  image:        Name of the image to create and start a running container
                from.
  max-memory:   The maximum amount of memory (in MBs) the applications running
                inside the container will be allowed to consume.  If they exceed
                this value they will be OMM killed.
  max-cpu:      The amount of a single CPU the applications running inside
                this container will be allowed to consume.  Value must be
                between 0.1 - 1.0 where 0.1 whould be 10% of a CPU and 1.0
                would be 100% of a CPU.
```
## docker ps
```
[root@crane-client src]# ./docker-ps.sh -h

Usage: ./docker-ps.sh
Description: This script displays running containers.

Options:
  -h         Display this usage message and exit.

Arguments:
  None
```
## docker exec
```
[root@host-name]# ./docker-exec.sh -h

Usage: ./docker-exec.sh <container_id> <cmd>
Description:    This script allows you to execute commands inside a
                running container.

Options:
  -h            Display this usage message and exit.

Arguments:
  container_id: Unique identifier of the running container.  Can be
                found by running ./docker-ps.sh.
  cmd:          Command to execute inside the running container.
```
## docker pause
```
[root@host-name]# ./docker-pause.sh -h

Usage: ./docker-pause.sh <container_id>
Description:    This script pauses a running container causing all
                processes inside the container to be suspended.

Options:
  -h            Display this usage message and exit.

Arguments:
  container_id: Unique identifier of the running container.  Can
                be found by running ./docker-ps.sh.
```
## docker unpause
```
[root@host-name]# ./docker-unpause.sh -h

Usage: ./docker-unpause.sh <container_id>
Description:    This script unpauses a running container causing all
                processes inside the container to be resumed.

Options:
  -h            Display this usage message and exit.

Arguments:
  container_id: Unique identifier of the running container.  Can
                be found by running ./docker-ps.sh.
```
## docker kill
```
[root@crane-client src]# ./docker-kill.sh -h

Usage: ./docker-kill.sh <container_id>
Description:    This script kills the running container that maps 
                to the container_id passed in.  All child processes
                running inside the container will also be killed.

Options:
  -h            Display this usage message and exit.

Arguments:
  container_id: Unique identifier of the running container.  Can be
                found by running ./docker-ps.sh.
```
