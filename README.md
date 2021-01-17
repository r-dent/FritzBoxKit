#  Fritz!Box Kit

[![CocoaPods](https://img.shields.io/cocoapods/v/FritzBox-Kit.svg)](https://cocoapods.org/pods/FritzBox-Kit)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![GitHub](https://img.shields.io/github/license/r-dent/FritzBoxKit)](https://github.com/r-dent/FritzBoxKit/blob/master/LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/r-dent/FritzBoxKit/Swift)](https://github.com/r-dent/FritzBoxKit/actions)

This aims to be a Framework that provides a clean and modern Swift API for communicating with Fritz!Box routers. The focus is on home automation features.

## Features

- [x] Authentication with API
- [x] Load device information (currently limited to thermostats and switches)
- [x] Toggle switches
- [ ] Set Thermostat temperature
- [ ] Load thermostat timetable
- [ ] manipulate thermostat timetable

## The Basics

Create an instance of the SDK with your [myfritz](https://sso.myfritz.net/) URL and user credentials.

```swift
let fritzBox = FritzBox(
    host: "https://YOURID.myfritz.net:46048",
    user: "foo",
    password: "bar"
)
```

Get a session identifier by calling the `login` method. This will be used for all further requests.

```swift
fritzBox.login { result in
    if case .success(let info) = result {
        print("Info: \(String(describing: info))")
        // We are now ready to do further requests.
    }
}
```

You can now get information about devices and then act on them.

```swift
fritzBox.getDevices(completion: { result in
    if case .success(let devices) = result {
        print("Devices: \(String(describing: devices))")
        // Prints a list of devices and their properties.
    }
})
```

## Hardware

As I only have one home, this was only tested with the following setup.

- Fritz!Box 7490 (FRITZ!OS 6.83)
- 3x Fritz Dect 300 thermostat
- 1x Fritz Dect 301 thermostat

## Installation

When using [Swift Package Manager](https://swift.org/package-manager/) add this:

    .package(url: "https://github.com/r-dent/FritzBoxKit.git", from: "0.5.0")

If you´re using [CocoaPods](https://cocoapods.org/pods/FritzBox-Kit), add this to your Podfile: 

	pod 'FritzBox-Kit'
