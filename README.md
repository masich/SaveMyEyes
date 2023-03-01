# SaveMyEyes

## MenuBar macOS application that helps to take breaks while using the computer.
[![CodeFactor](https://www.codefactor.io/repository/github/masich/savemyeyes/badge)](https://www.codefactor.io/repository/github/masich/savemyeyes)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

You can choose specific work and break time intervals that are perfect for you.

Work time is a time interval in minutes to work on the computer before a notification about a break is generated.

Break time is a time interval in minutes to rest your eyes.

Features:
* Minimalistic application design.
* Time settings selected by the user are saved in local storage.
* Automatically pauses and resumes timer depending on user activity.
* Sends reminder notifications based on the time presets selected by the user.

The app is built using ```SwiftUI``` and requires macOS 10.15 to run.

## Installation guide
SaveMyEyes can be installed using `brew` or manually through `.dmg` image.

### Using `brew` 
* Run `brew tap masich/brew` to pull `masich/brew` Tap on your local machine
* Run `brew install --cask savemyeyes`

### Manually through `.dmg` image
* Download the latest [release](https://github.com/masich/SaveMyEyes/releases/) `.dmg` image and mount it
* [Drag & Drop](Images/Readme/Installation/Drag&Drop.png) SaveMyEyes app to the Application folder
* Open SaveMyEyes

### No matter how you install the app, the rest steps are the same
* According to the latest Catalina changes, the following [warning](Images/Readme/Installation/Warning.png) will appear
* Go to the System Preferences and open its Security & Privacy tab
* Click your ["Open Anyway"](Images/Readme/Installation/Security.png) button
* Now, you can use this app without any restrictions and warnings

This problem is caused by Apple's new software notarization system (as I correctly understood, it costs 100$ per year).
[Info](https://support.apple.com/en-us/HT202491) from the Apple site about this warning.

## Screenshots
### MenuBar app
![MenuBar app](Images/Readme/Screenshots/MenuAppScreenshot.png)

### Notifications
![Notifications](Images/Readme/Screenshots/NotificationsScreenshot.png)

## License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details.