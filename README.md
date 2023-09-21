# base-images

This repo contains the base container images which are used across our code base and ensures they are rebuilt / patched weekly.

# To add a new image
1. create a directory for the new image
2. add your docker file and any other files necessary
3. In .github/workflows in this repo edit weekly_image_build.yaml under Jobs: and add your image to the weekly builder
4. ** make sure to edit the "override tag" option to name it.  an example would be tag=go-base
5. You can add to "build when called" which will allow you to rebuild the image by triggering it manually.
