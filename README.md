#  Fritz!Box Kit

This aims to be Framework that provides a clean and modern Swift API for communicating with Fritz!Box routers. The focus is on home automation features.

## Features

- [x] Authentication with API
- [x] Load device information (currently limited to thermostats)
- [ ] Set Thermostat temperature
- [ ] Toggle switches
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
fritzBox.login { (info, error) in
    if error == nil {
        print("Info: \(String(describing: info))")
        // We are now ready to do further requests.
    }
}
```

You can now get information about devices and then act on them.

```swift
fritzBox.getDevices(completion: { [weak self] (devices, deviceError) in
    if error == nil {
        print("Devices: \(String(describing: devices))")
        // Prints a list of devices and their properties.
    }
})
```