#!/usr/bin/env bash
cd umassemergency
pod install
xcodebuild -configuration Debug -workspace UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.1,name="iPhone 7 Plus" build test SYMROOT=$(PWD)/build
