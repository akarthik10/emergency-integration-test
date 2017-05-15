#!/usr/bin/env bash



cd umassemergency
sudo gem install cocoapods
pod install
cd ..


   n=0
   until [ $n -ge 1 ]
   do
      env NSUnbufferedIO=YES xcodebuild -configuration Debug -workspace umassemergency/UMassEmergency.xcworkspace -scheme UMassEmergency -sdk iphonesimulator -destination platform="iOS Simulator",OS=10.2,name="iPhone 7 Plus" build test SYMROOT=$(PWD)/build | tee iosoutput.log | xcpretty
      echo "Exit status is $?"

      if grep -q "TEST SUCCEEDED" iosoutput.log ; then
         echo "Exiting with success"
      	exit 0
      fi
      n=$[$n+1]
      echo "Retrying again.. $n "

      osascript -e 'tell application "iOS Simulator" to quit'
      osascript -e 'tell application "Simulator" to quit'
      xcrun simctl erase all

   done
   echo "Retry failed, exiting.."
   exit 1


