package com.mapbox.react.ar.utils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.io.InputStream;
import java.net.URL;

public class BitmapUtils {
    public static final String LOG_TAG = BitmapUtils.class.getSimpleName();

    public static Bitmap getBitmapFromURL(String url, BitmapFactory.Options options) {
        Bitmap bitmap = null;

        try {
            InputStream bitmapStream = new URL(url).openStream();
            bitmap = BitmapFactory.decodeStream(bitmapStream, null, options);
            bitmapStream.close();
        } catch (Exception e) {
            Log.w(LOG_TAG, e.getLocalizedMessage());
        }

        return bitmap;
    }
}
