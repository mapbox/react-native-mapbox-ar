package com.mapbox.react.ar.utils;

import android.graphics.Color;

import com.facebook.react.bridge.ReadableArray;

public class GeoUtils {
    public static final double M_TO_PX_SCALAR = 40075000.0;
    public static final double TILE_SIZE = 256.0;

    public static double scaleElevation(double elevation, double zoomLevel, double modifier) {
        double value = elevation / Math.abs(
                M_TO_PX_SCALAR * Math.cos(Math.PI / 180) / (Math.pow(2.0, zoomLevel) * TILE_SIZE));
        return value * modifier;
    }

    public static float getElevation(int pixel) {
        int R = Color.red(pixel);
        int G = Color.green(pixel);
        int B = Color.blue(pixel);
        return ((R * 256 * 256 + G * 256 + B) / 10) - 10000;
    }

    public static float[] bboxFromReadableArray(ReadableArray array) {
        float[] bbox = new float[4];

        for (int i = 0; i < bbox.length; i++) {
            bbox[i] = (float) array.getDouble(i);
        }

        return bbox;
    }
}
