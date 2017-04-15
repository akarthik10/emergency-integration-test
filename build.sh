#!/usr/bin/env bash



cd umassemergency
pod install
cd ..


   n=0
   until [ $n -ge 1 ]
   do
      env NSUnbufferedIO=YES xcodebuild -configuration Debug -workspace umassemergency/UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.2,name="iPhone 7 Plus" build test SYMROOT=$(PWD)/build | tee iosoutput.log | xcpretty
      if grep -q "TEST FAILED" "iosoutput.log"; then
         echo "Exiting with success"
      	exit 0
      fi
      n=$[$n+1]
      echo "Retrying again.. $n "
      xcrun simctl io booted screenshot
      killall -9 Simulator
      killall -9 com.apple.CoreSimulator.CoreSimulatorService
      sleep 15

   done
   echo "Retry failed, exiting.."
   exit 1


