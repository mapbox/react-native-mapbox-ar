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

public class FSUtils {
    public static File createTempFile(Context context, StringBuilder content, String ext) {
        File file = null;

        try {
            file = File.createTempFile("this-is-cool", ext, context.getCacheDir());
            FileOutputStream outputStream = new FileOutputStream(file);
            outputStream.write(content.toString().getBytes());
            outputStream.close();
        } catch (IOException e) {
            Log.w("dfsdf", e.getLocalizedMessage());
        }

        return file;
    }

    public static File createTempImageFile(Context context, Bitmap bitmap) {
        File file = null;
        FileOutputStream outputStream = null;

        try {
            file = File.createTempFile("this-is-cool", ".jpg", context.getCacheDir());
            outputStream = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
            outputStream.close();
        } catch (IOException e) {
            Log.w("dfsdf", e.getLocalizedMessage());
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
