# Overview 
```
Any sufficiently advanced technology is indistinguishable from magic.
   - Arthur C. Clark's 3rd Law
```

Application containerization has been around for a long time.  Its roots can be traced back to 1979 when the chroot system call was introduced in UNIX V7 but it wasn't until 2013 when Docker was open sourced that containers went mainstream. This repo is an attempt to demystify application containerization.  We'll do this by implementing a simplified container runtime using bash.  Why bash... because just about everyone can read bash.  A container runtime has quite a large surface area so we will limit our implementation to a small subset of functionality. Since most people reading this will already be familiar with Docker, we'll use it as a common language to describe what we are implementing.

* [docker pull](/details/docker-pull/README.md)
* [docker images](/details/docker-images/README.md)
* [docker run](/details/docker-run/README.md)
* [docker ps](/details/docker-ps/README.md)
* [docker exec](/details/docker-exec/README.md)
* [docker pause](/details/docker-pause/README.md)
* [docker unpause](/details/docker-unpause/README.md)
* [docker kill](/details/docker-kill/README.md)
 
## Prerequisites
If you want to kick the tires (and I hope that you do), you'll need root access to a Linux machine running a kernel that support cgroups v2. This machine won't need a container runtime installed because that functionality is provided by the scripts in this repo. You'll also need a docker repo to push / pull a test image to / from and some sort of machine (Win, Mac, Linux) with Docker installed to build and push the test image to your repo.
