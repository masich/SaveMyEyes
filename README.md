# SaveMyEyes

## MenuBar macOS application that helps to take breaks while using the computer.
[![CodeFactor](https://www.codefactor.io/repository/github/masich/savemyeyes/badge)](https://www.codefactor.io/repository/github/masich/savemyeyes)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

You can choose a specific time interval and break time which perfects for you. For now, there are only a limited number of options, but the app will support direct time input in the future. 

Time interval - time in minutes to work on the computer before notification about break will be generated.

Break time - time in minutes to rest your eyes.

Features:
* Some general predefined work and break time intervals sets.
* Time settings selected by the user are saved in local storage.
* Automatically pauses and resumes timer depending on user activity.
* Sends reminder notifications based on the time presets selected by the user.

The app is built using ```SwiftUI``` and requires macOS 10.15 to run.

## Installation guide
* Download the latest [release](https://github.com/masich/SaveMyEyes/releases/) ```.dmg``` image and mount it.
* Drag & Drop SaveMyEyes app to the Application folder.
* Open SaveMyEyes.
* According to the latest Catalina changes the [warning](Images/Readme/Installation/Warning.png) will appear.
* Go to the System Preferences and open it's Security & Privacy tab.
* Click your ["Open Anyway"](Images/Readme/Installation/Security.png) button.
* Now you can use this app without any restrictions and warnings.

This problem is caused because of the Apple's new software notarization system (as I correctly understood, it costs 100$ per year).
[Info](https://support.apple.com/en-us/HT202491) from Apple site about this warning.

## Screenshots
### MenuBar app
![MenuBar app](Images/Readme/Screenshots/MenuAppScreenshot.png)

### Notifications
![Notifications](Images/Readme/Screenshots/NotificationsScreenshot.png)

## License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details.