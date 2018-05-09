package com.mapbox.react.ar;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.mapbox.react.ar.modules.RCTMapboxARModule;
import com.mapbox.react.ar.modules.RCTMapboxARTerrainModule;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


public class RCTMapboxARPackage implements ReactPackage {
    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();

        modules.add(new RCTMapboxARModule(reactContext));
        modules.add(new RCTMapboxARTerrainModule(reactContext));

        return modules;
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}