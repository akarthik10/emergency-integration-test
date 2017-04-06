#!/usr/bin/env bash
cd umassemergency
pod install
xcodebuild -configuration Debug -workspace UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.2,id="86B2CA7C-0247-4257-BFEA-8035084AF2C" build test SYMROOT=$(PWD)/build
