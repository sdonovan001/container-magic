## Usage Documantation
### docker pull
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
### docker images
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
