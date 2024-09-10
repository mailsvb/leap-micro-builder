#!/bin/bash
cp -R /data/boot/ /leap/ && \
cp -R /data/combustion/ /leap/ && \
xorriso -indev /leap.iso -outdev /data/osem-leap-micro.iso -map /leap / -- -boot_image any replay -volid 'COMBUSTION'
exit
