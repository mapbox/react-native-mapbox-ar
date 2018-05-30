# Mapbox Augmented Reality SDK Demo Applicationfor React Native

# Getting started

You will need to create a `token.json` file that will contain your Mapbox access token
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

```
npm start
```

if you're running on Android you'll also need to run this command in order for the react native packager
to communicate with your device

```
adb reverse tcp:8081 tcp:8081
```
