package com.mapbox.react.ar.core;

import android.content.Context;
import android.util.Log;

import com.mapbox.react.ar.utils.FSUtils;

import java.io.File;
import java.io.IOException;

public class ObjectFileWriter {
    public static final String LOG_TAG = ObjectFileWriter.class.getSimpleName();

    private static final short BYTES_PER_CHAR = 11;
    private static final int MAX_MB_IN_BUILDER_BYTES = 8 * 1000000;

    private File objectFile;
    private StringBuilder contentBuffer;

    public ObjectFileWriter(Context context) {
        this.contentBuffer = new StringBuilder();
        this.objectFile = FSUtils.createTempFile(context, contentBuffer, ".obj");
    }

    public void appendData(String ...data) throws IOException {
        for (int i = 0; i < data.length; i++) {
            contentBuffer.append(data[i]);
        }

        if (shouldFlush()) {
            Log.d(LOG_TAG, "Flushed object file writer buffer");
            //writeToFile();
        }
    }

    public void writeToFile() throws IOException {
        FSUtils.appendStringToFile(objectFile, contentBuffer);
        contentBuffer.setLength(0);
    }

    public File getFile() throws IOException {
        if (contentBuffer.length() > 0) {
            writeToFile();
        }
        return objectFile;
    }

    private boolean shouldFlush() {
        return contentBuffer.length() * BYTES_PER_CHAR >= MAX_MB_IN_BUILDER_BYTES;
    }
}
