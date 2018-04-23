package com.mapbox.react.ar.utils;

public class GeoUtils {
    public static final double M_TO_PX_SCALAR = 40075000.0;

    public static double scaleElevation(double elevation, double zoomLevel) {
        return elevation / Math.abs(
                M_TO_PX_SCALAR * Math.cos(Math.PI / 180) / (Math.pow(2.0, zoomLevel) * 256));
    }
}
