#!/bin/bash

circleci orb pack src > orb.yml
circleci orb publish orb.yml roopakv/swissknife@dev:alpha
rm -rf orb.yml
