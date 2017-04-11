#!/usr/bin/env bash



cd umassemergency
pod install
cd ..

unbuffer xcodebuild -configuration Debug -workspace umassemergency/UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.2,name="iPhone 7 Plus" build test SYMROOT=$(PWD)/build | tee iosoutput.log | xcpretty -t
