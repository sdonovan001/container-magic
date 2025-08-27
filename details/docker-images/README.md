## docker-images.sh
The docker images command lists all images that are stored on the local Docker host. 

### Implementation Details
There's nothing special going on here.  This script just does an (ls / grep / sed / awk) of the image root directory and displays the names of any images it finds.
