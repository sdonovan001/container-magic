## Overview 
```
Any sufficiently advanced technology is indistinguishable from magic.
   - Arthur C. Clark's 3rd Law
```

While Docker and other container runtimes may seem like magic I assure you they are not.  They are implemented on top of 3 different kernel features: union file system, cgroups and namespaces. This repo is an attempt to demystify application containerization.  We'll do this by implementing a simplified container runtime using bash.  Why bash... because just about everyone can read bash.  A container runtime has quite a large surface area so we will limit our implementation to a small subset of functionality. Since most people reading this will already be familiar with Docker, we'll use it as a common language to describe what we are implementing.

* [docker pull](/doc/README.md#docker-pull)
* [docker images](/doc/README.md#docker-images)
* [docker run](/doc/README.md#docker-run)
* [docker ps](/doc/README.md#docker-ps)
* [docker exec](/doc/README.md#docker-exec)
* [docker pause](/doc/README.md#docker-pause)
* [docker unpause](/doc/README.md#docker-unpause)
* [docker kill](/doc/README.md#docker-kill)
 
## Prerequisites
If you want to kick the tires (and I hope that you do), you'll need root access to a Linux machine running a kernel that support cgroups v2 (you can verify this by running `[root@host-name]# stat -fc %T /sys/fs/cgroup/` on the command line). This machine won't need a container runtime installed because that functionality is provided by the scripts in this repo. This machine will, however, need [gcrane](https://github.com/google/go-containerregistry/blob/main/cmd/gcrane/README.md) installed into `/usr/local/bin`.  You'll also need a docker repo to push / pull a test image to / from and some sort of machine (Win, Mac, Linux) with Docker installed to build and push the test image to your repo.

## Start Your Journey Here
The video below contains a test drive of our bash based container runtime.  I would start by watching it so you have a clear understanding of what we've implemented. After watching the video, go to the [chart-app](/chart-app/README.md) directory and build / push the test image.  At this point you can explore the scripts for yourself.  
<p> </p>

__Note:__ You can drill down on the links of each individual command for usage doc.
