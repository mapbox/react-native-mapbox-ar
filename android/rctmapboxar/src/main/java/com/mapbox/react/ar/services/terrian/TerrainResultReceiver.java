package com.mapbox.react.ar.services.terrian;

import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;

public class TerrainResultReceiver extends ResultReceiver {
    public static final int RESULT_OK = 1000;
    public static final int RESULT_ERROR = -1;
    public static final String RESULT_NAME = "terrianResponse";
    public static final String EXTRA_NAME = "terrianReceiver";

    private TerrianResultCallback callback;

    public TerrainResultReceiver(Handler handler) {
        super(handler);
    }

    public void setCallback(TerrianResultCallback callback) {
        this.callback = callback;
    }

    public interface TerrianResultCallback {
        void onSuccess(TerrainResponse response);
        void onError(String error);
    }

    @Override
    protected void onReceiveResult(int resultCode, Bundle resultData) {
        if (callback != null) {
            if(resultCode == RESULT_OK){
                callback.onSuccess((TerrainResponse) resultData.get(RESULT_NAME));
            } else {
                callback.onError((String) resultData.getSerializable(RESULT_NAME));
            }
        }
    }
}
