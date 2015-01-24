#!/bin/bash
set -x
set -e
#change the SPI reset pin for acrdude
sed -i 's/reset = 25/reset = 30/' /etc/avrdude.conf
