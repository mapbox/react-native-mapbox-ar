package com.mapbox.react.ar.modules;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.mapbox.react.ar.MapboxManager;
import com.mapbox.react.ar.services.terrian.TerrainIntentService;
import com.mapbox.react.ar.services.terrian.TerrainResponse;
import com.mapbox.react.ar.services.terrian.TerrainResultReceiver;

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

    @ReactMethod
    public void getTerrianObjectUri(Promise promise) {
        Context context = getReactApplicationContext();
        Intent intent = new Intent(context, TerrainIntentService.class);

        TerrainResultReceiver receiver = new TerrainResultReceiver(new Handler());
        receiver.setCallback(new TerrianGenerationCallback(promise));
        intent.putExtra(TerrainResultReceiver.EXTRA_NAME, receiver);

        context.startService(intent);
    }

    private static class TerrianGenerationCallback implements TerrainResultReceiver.TerrianResultCallback {
        Promise promise;

        TerrianGenerationCallback(Promise promise) {
            this.promise = promise;
        }

        @Override
        public void onSuccess(TerrainResponse response) {
            promise.resolve(Arguments.makeNativeMap(response.data));
        }

        @Override
        public void onError(String error) {
            promise.reject("-1", error);
        }
    }
}
