#!/usr/bin/env bash

#cd "$MINER_DIR/$MINER_NAME/"
#echo  $MINER_DIR
#echo $MINER_NAME


[[ ! -e ./lolminer.conf ]] && echo "No config file found, exiting" && pwd && exit 1

lolzil $(< lolminer.conf)  | tee --append /var/log/miner/custom/$(date +"%Y_%m_%d_%I_%M_%p").log


