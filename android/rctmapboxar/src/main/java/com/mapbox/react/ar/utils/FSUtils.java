package com.mapbox.react.ar.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.util.UUID;

public class FSUtils {
    public static final String LOG_TAG = FSUtils.class.getSimpleName();
    public static final String FILE_PREFIX = "mapboxar-object-";
    public static final String IMG_PREFIX = "mapboxar-image";

    public static File createTempFile(Context context, StringBuilder content, String ext) {
        File file = null;

        try {
            String fileName = FILE_PREFIX + UUID.randomUUID().toString();
            file = File.createTempFile(fileName, ext, context.getCacheDir());
            FileOutputStream outputStream = new FileOutputStream(file);
            outputStream.write(content.toString().getBytes());
            outputStream.close();
        } catch (IOException e) {
            Log.w(LOG_TAG, e.getLocalizedMessage());
        }

        return file;
    }

    public static File createTempImageFile(Context context, Bitmap bitmap) {
        File file = null;
        FileOutputStream outputStream = null;

        try {
            String fileName = IMG_PREFIX + UUID.randomUUID().toString();
            file = File.createTempFile(fileName, ".jpg", context.getCacheDir());
            outputStream = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
            outputStream.close();
        } catch (IOException e) {
            Log.w(LOG_TAG, e.getLocalizedMessage());
        }

        if (file == null) {
            return null;
        }

        return file;
    }

    public static void appendStringToFile(File file, StringBuilder content) throws IOException {
        Writer out = new BufferedWriter(new FileWriter(file, true));
        out.write(content.toString());
        out.close();
        content.delete(0, content.length() - 1);
    }
}
