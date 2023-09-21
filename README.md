# base-images

This repo contains the base container images which are used across our code base and ensures they are rebuilt / patched weekly.

# To add a new image

    create a directory for the new image
    add your docker file and any other files necessary
    In .github/workflows in this repo edit weekly_image_build.yaml under Jobs: and add your image to the weekly builder
    ** make sure to edit the "override tag" option to name it. an example would be tag=go-base
    You can add to "build when called" which will allow you to rebuild the image by triggering it manually.
