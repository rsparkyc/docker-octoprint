# OctoPrint

[![build status][travis-image]][travis-url]

This is a Dockerfile to set up [OctoPrint](http://octoprint.org/). It is a fork of [nunofgs/docker-octoprint](https://github.com/nunofgs/docker-octoprint) intended specifically for building and managing the container on a Raspberry pi 3b+. 

Added to the base project is the following:
- Updated base image to stretch (and now buster) to fix an issue with supervisor version (> v3.0)
- Added makefile system for building and managing the image. Please update the makefile to use your docker repo settings.
- Use of a data volume instead of directory mount so that all container configuration files are encapsulated
- Makefile command to back up the configuration in a container and push to Dockerhub (again, update your repo name in the Makefile if you're going to take advantage of this) 

To do:
- Add running the Octoprint container from a backed up data container 

# Credits

Forked from https://github.com/nunofgs/docker-octoprint. Thanks for huge head start on this!

Original credits go to https://bitbucket.org/a2z-team/docker-octoprint. I initially ported this to the raspberry pi 2 and later moved to a multiarch image.

## License

MIT

[travis-image]: https://img.shields.io/travis/nunofgs/docker-octoprint.svg?style=flat-square
[travis-url]: https://travis-ci.org/nunofgs/docker-octoprint
