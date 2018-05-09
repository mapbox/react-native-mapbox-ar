package com.mapbox.react.ar.modules;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.mapbox.react.ar.core.TerrainTile;
import com.mapbox.react.ar.services.terrain.TerrainIntentService;
import com.mapbox.react.ar.services.terrain.TerrainResponse;
import com.mapbox.react.ar.services.terrain.TerrainResultReceiver;

public class RCTMapboxARTerrainModule extends ReactContextBaseJavaModule {
    public static final String REACT_CLASS = RCTMapboxARTerrainModule.class.getSimpleName();

    public RCTMapboxARTerrainModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void createMesh(ReadableMap options, Promise promise) {
        Context context = getReactApplicationContext();
        Intent intent = new Intent(context, TerrainIntentService.class);

        TerrainResultReceiver receiver = new TerrainResultReceiver(new Handler());
        receiver.setCallback(new RCTMapboxARTerrainModule.TerrainGenerationCallback(promise));

        intent.putExtra(TerrainIntentService.EXTRA_RECEIVER, receiver);
        intent.putExtra(TerrainIntentService.EXTRA_WIDTH, options.getInt("width"));
        intent.putExtra(TerrainIntentService.EXTRA_HEIGHT, options.getInt("height"));
        intent.putExtra(TerrainIntentService.EXTRA_ZOOM, (float) options.getDouble("zoom"));
        intent.putExtra(TerrainIntentService.EXTRA_SAMPLE_SIZE, options.getInt("sampleSize"));
        intent.putExtra(TerrainIntentService.EXTRA_HEIGHT_MODIFIER, (float) options.getDouble("heightModifier"));
        intent.putExtra(TerrainIntentService.EXTRA_TILES, TerrainTile.fromReadableArray(options.getArray("tiles")));
        intent.putExtra(TerrainIntentService.EXTRA_SATELLITE_TILE, options.getString("satelliteURI"));

        context.startService(intent);
    }

    private static class TerrainGenerationCallback implements TerrainResultReceiver.TerrianResultCallback {
        Promise promise;

        TerrainGenerationCallback(Promise promise) {
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
