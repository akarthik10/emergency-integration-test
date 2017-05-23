# emergency-integration-test

This repository contains the code for executing an integration test everytime something is committed and pushed into bitbucket repositories of iOS emergency app and the portal. `.travis.yml` contains code to install dependencies and starta test. Especially, the call to `build.sh` in it executes the test target in the iOS emergency application project.

The project contains an encrypted rsa private key to be used to get direct access to private bitbucket repositories. To update the key, use `travis encrypt-file` command to encrypt the key, place the encrypted key in github repository (and decrypt it during Travis execution with a password known only to Travis, as generated during `encrypt-file`)

The test target in iOS emergency application resides in the `UMassEmergencyIntegrationTests/UMassEmergencyIntegrationTests.swift` file. The file contains `setUp`, `test*` and `tearDown` methods. Each test starts with the keyword `test` to identify it as a test.

The entire test logic resides in the `test*` methods of the iOS test target class. If an external command needs to be executed, the test logic issues a HTTP request to a HTTP server listening on port 5555 outside the iOS VM to execute the command. This is frequently used to set simulator location and to take screenshots.

On the portal side, once the app is ready to receive notifications, the test logic executes a python script to launch the portal send a notification of well defined attributes. This uses selenium to launch the website and trigger corresponding inputs. The test logic, after executing code to send notification from portal, expects notification to arrive in the app. If a notification appears on map, the test is successful.
