#!/bin/bash

ROW_WEBMIN_SOURCE='deb http://download.webmin.com/download/repository sarge contrib'

if ! $( grep -q "$ROW_WEBMIN_SOURCE" /etc/apt/sources.list ); then
    echo "$ROW_WEBMIN_SOURCE" | sudo tee -a /etc/apt/sources.list

    wget http://www.webmin.com/jcameron-key.asc
    sudo apt-key add jcameron-key.asc

    sudo apt-get update && sudo apt-get install webmin
fi