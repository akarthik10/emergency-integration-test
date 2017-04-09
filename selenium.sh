#!/usr/bin/env bash

sudo pip install selenium

tail -f iosoutput.log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"Launch edu.umass.arun.UMassEmergency"* ]] && pkill -P $$ tail
done
echo "App launched, starting selenium test"
python test.py
