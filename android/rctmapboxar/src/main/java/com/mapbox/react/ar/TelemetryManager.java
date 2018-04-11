package com.mapbox.react.ar;

import android.content.Context;

import com.mapbox.android.telemetry.AppUserTurnstile;
import com.mapbox.android.telemetry.Event;
import com.mapbox.android.telemetry.MapboxTelemetry;
import com.mapbox.android.telemetry.TelemetryEnabler;
import com.mapbox.react.ar.generated.Config;

public class TelemetryManager {
    private static TelemetryManager INSTANCE;

    private Context context;
    private MapboxTelemetry mapboxTelemetry;

    private TelemetryManager(Context context) {
        this.context = context;

        final String accessToken = MapboxManager.getInstance().getAccessToken();
        mapboxTelemetry = new MapboxTelemetry(context, accessToken, Config.SDK_USER_AGENT);
        setupTelemetry(accessToken);
    }

    public void sendEvent(Event event) {
        if (mapboxTelemetry != null) {
            mapboxTelemetry.push(event);
        }
    }

    public static TelemetryManager getInstance(Context context) {
        if (INSTANCE == null) {
            INSTANCE = new TelemetryManager(context);
        }
        return INSTANCE;
    }

    private void setupTelemetry(String accessToken) {
        mapboxTelemetry = new MapboxTelemetry(context, accessToken, Config.SDK_USER_AGENT);

        TelemetryEnabler.State telemetryState = TelemetryEnabler.retrieveTelemetryStateFromPreferences();
        if (TelemetryEnabler.State.ENABLED.equals(telemetryState)) {
            mapboxTelemetry.enable();
            sendEvent(new AppUserTurnstile(Config.SDK_ID, Config.NPM_VERSION));
        }
    }
}
