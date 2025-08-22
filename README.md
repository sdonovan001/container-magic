# Overview 
```
Any sufficiently advanced technology is indistinguishable from magic.
   - Arthur C. Clark's 3rd Law
```

Application containerization has been around for a long time.  Its roots can be traced back to 1979 when the chroot system call was introduced in UNIX V7 but it wasn't until 2013 when Docker was open sourced that containers went mainstream. This repo is an attempt to demystify application containerization.  We'll do this by implementing a simplified container runtime using bash.  Why bash... because just about everyone can read bash.  A container runtime has quite a large surface area so we will limit our implementation to a small subset of functionality. Since most people reading this will already be familiar with Docker, we'll use it as a common language to describe what we are implementing.

* docker pull
* docker images
* docker run
* docker ps
* docker exec
* docker pause
* docker resume
* docker kill
 
