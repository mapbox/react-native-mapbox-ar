package com.mapbox.react.ar.modules;

import android.annotation.SuppressLint;
import android.content.Context;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.mapbox.react.ar.MapboxManager;

public class RCTMapboxARModule extends ReactContextBaseJavaModule {
    static final String SET_MAPBOX_TOKEN = "You must set your Mapbox access token";
    static final String REACT_CLASS = RCTMapboxARModule.class.getSimpleName();

    public RCTMapboxARModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void setAccessToken(String accessToken) {
        MapboxManager.getInstance(accessToken);
    }

    @ReactMethod
    public void getAccessToken(Promise promise) {
        String accessToken = MapboxManager.getInstance().getAccessToken();

        if (accessToken != null && !accessToken.isEmpty()) {
            promise.resolve(accessToken);
        } else {
            promise.reject("-1", SET_MAPBOX_TOKEN);
        }
    }

    @ReactMethod
    public void assertAccessToken(Promise promise) throws Exception {
        MapboxManager mapboxManager = MapboxManager.getInstance();
        if (mapboxManager == null) {
            throw new Exception(SET_MAPBOX_TOKEN);
        }

        final String accessToken = mapboxManager.getAccessToken();
        if (accessToken == null || accessToken.isEmpty()) {
           throw new Exception(SET_MAPBOX_TOKEN);
        }
    }
}
