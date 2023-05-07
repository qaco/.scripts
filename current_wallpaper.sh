#!/bin/bash

gsettings get org.mate.background picture-filename | sed "s/'//g" | sed 's/.*Favoris\///g'
