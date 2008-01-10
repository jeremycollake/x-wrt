#!/bin/sh
./cleanw.sh && make && ./mkimages.sh && ./compress_images.sh && ./upload_files.sh jcollake
