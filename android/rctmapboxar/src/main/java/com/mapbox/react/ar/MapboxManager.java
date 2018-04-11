package com.mapbox.react.ar;

public class MapboxManager {
    private static MapboxManager INSTANCE;
    private String accessToken;

    private MapboxManager(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public static MapboxManager getInstance() {
        return getInstance(null);
    }

    public static MapboxManager getInstance(String accessToken) {
        if (INSTANCE == null && accessToken != null && !accessToken.isEmpty()) {
            INSTANCE = new MapboxManager(accessToken);
        }
        return INSTANCE;
    }
}
