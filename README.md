# Example App to Demonstrate Call Recording
This app is designed to demonstrate a simple audio call recording feature using the VonageClientSDKVoice SDK. For detailed information about the SDK, please refer to the Vonage Voice API documentation.

# Prerequisites
- Xcode 15+: Ensure you have Xcode version 15 or later installed.
- iOS 16: The application is designed to run on iOS 16.

# Setup Instructions
- Navigate to the Project Folder: Open your terminal and navigate to the project directory.
- Install Dependencies: Use CocoaPods to install the necessary dependencies. Run the following command in your terminal:

```
pod install
```
- Open the Workspace: After the dependencies are installed, open the Xcode workspace file (.xcworkspace).

# Usage
- App Setup: Replace the token in the ViewDelegate file at line 143 with a valid user token.

- Create Session: Once you have updated the token, press `Create session` to create a session with Vonage APIs.

- Start a Call: Press the `call` button to start a server call.

- Call Invite: whenever a call invite is received, app will show a alert to answer or `reject` the `invite`.

- Hangup: Press hangup to end the call.

- Play Current Recording: You can play the recorded file by pressing Play current Recording.

- File Size Label: The label displays the size (in seconds) of the current recording once it is finished.

- Recording of a call: App will start recording the call whenever it receives `answer` in `legStatusUpdate` delegate method, and stops recording when a `hangup` is received. And the audio file will be saved `documentDirectory` in `userDomainMask`


# Notes
Ensure that you have a stable internet connection for the call recording functionality to work properly.
Familiarize yourself with the Vonage Voice API documentation for advanced features and customizations.

# Support
If you encounter any issues or have questions, please refer to the Vonage support page for assistance.

# License
This project is licensed under the Vonage License. See the LICENSE file for more details.

Thank you for using the Example App to demonstrate call recording with the VonageClientSDKVoice SDK. We hope this README provides all the necessary information to get you started. Enjoy coding!
