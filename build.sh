#!/usr/bin/env bash



cd umassemergency
pod install
xcodebuild -configuration Debug -workspace UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.2,name="iPhone 7 Plus" build test SYMROOT=$(PWD)/build &

sleep 550

sudo pip install selenium

python test.py &
