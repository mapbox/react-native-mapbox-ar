# Mapbox Augmented Reality SDK Demo Applicationfor React Native

This example application shows off our Terrain component for now. Stay tuned more to come!

# Getting started

You will need to create a `tokens.json` file that will contain your Mapbox access token
and Viro API key

```
{
  "mapbox": <mapbox access token>,
  "viro": <viro api key>
}
```

add this file to the top level of the example project. Once this file is in place
all you should need to do is run on **devices** that support ARCore and ARKit. **This
does not work in the simulator**

# Install Dependencies

Starting from directory `react-native-mapbox-ar`

```
npm i or yarn install
cd RNMapboxARDemo
npm i or yarn install

# iOS only
cd ios
pod install
```

# Start React Native Packager

In a new tab run

```
npm start
```

# Run on Android

It's always best to open up the project first in Android Studio

```
adb reverse tcp:8081 tcp:8081
react-native run-android --variant=gvrRelease
```

# Run on iOS

* Before we can run on our iOS device you must add your signing team in Xcode
<img src="https://s15.postimg.cc/7v84y132z/signing.png" />

* Open up `RNMapboxARDemo.xcworkspace`

* Make sure your ARKit supported device is connected to Xcode then switch your build device to your connected device
<img src="https://s33.postimg.cc/4s1iu9xwf/select_phone.png" />

* Now run from Xcode
<img src="https://s15.postimg.cc/ijbvwri63/build.png" />
