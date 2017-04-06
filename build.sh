#!/usr/bin/env bash
cd umassemergency
xcodebuild -configuration Debug -workspace UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.2,id="7B6F8C6B-B67A-4F64-BB70-AE1FF077ACC2" build test SYMROOT=$(PWD)/build
