package com.mapbox.react.ar.utils;

import android.content.Context;
import android.util.Log;

import com.mapbox.react.ar.geometries.BufferGeometry;
import com.mapbox.react.ar.geometries.Geometry;
import com.mapbox.react.ar.math.Matrix3;
import com.mapbox.react.ar.math.Matrix4;
import com.mapbox.react.ar.math.Vector2;
import com.mapbox.react.ar.math.Vector3;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ObjFileExporter {
    private static Matrix4 WORLD_MATRIX = new Matrix4();
    private static Matrix3 NORMAL_WORLD_MATRIX = Matrix3.getNormalMatrix(WORLD_MATRIX);

    public static File createFile(Context context, String objectName, BufferGeometry bufferGeometry) throws IOException {
        ObjectFileWriter writer = new ObjectFileWriter(context);

        writer.appendData("o " + objectName + "\n");
        writer.appendData("g\n");

        String[] line = new String[3];
        Vector3 vector3 = new Vector3();
        Vector2 vector2 = new Vector2();

        line[0] = "v ";
        line[2] = "\n";

        for (int i = 0; i < bufferGeometry.position.size(); i += 3) {
            vector3.x = bufferGeometry.position.get(i);
            vector3.y = bufferGeometry.position.get(i + 1);
            vector3.z = bufferGeometry.position.get(i + 2);

            // convert from model space to world space
            vector3.applyMatrix4(WORLD_MATRIX);

            line[1] = vector3.toString();
            writer.appendData(line);
        }

        line[0] = "vn ";
        for (int i = 0; i < bufferGeometry.normal.size(); i += 3) {
            vector3.x = bufferGeometry.position.get(i);
            vector3.y = bufferGeometry.position.get(i + 1);
            vector3.z = bufferGeometry.position.get(i + 2);

            // convert from model space to world space
            vector3.applyMatrix3(NORMAL_WORLD_MATRIX);

            line[1] = vector3.toString();
            writer.appendData(line);
        }


        line[0] = "vt ";
        for (int i = 0; i < bufferGeometry.uv.size(); i += 2) {
            vector2.x = bufferGeometry.uv.get(i);
            vector2.y = bufferGeometry.uv.get(i + 1);
            line[1] = vector2.toString();
            writer.appendData(line);
        }

        String faceStrFormat = "%d/%d/%d";
        List<String> face = new ArrayList<>();

        line[0] = "f ";
        for (int i = 0; i < bufferGeometry.position.size() / 3; i += 3) {
            for (int m = 0; m < 3; m++) {
                int j = i + m + 1;
                face.add(String.format(faceStrFormat, j, j, j));
            }
            String faceStr = ListUtils.join(face, " ");
            line[1] = faceStr;
            writer.appendData(line);
            face.clear();
        }

        writer.appendData("s off\n");

        return writer.getFile();
    }

    private static final class ObjectFileWriter {
        private static final short BYTES_PER_CHAR = 11;
        private static final int MAX_MB_IN_BUILDER_BYTES = 5 * 1000000;

        private File objectFile;
        private StringBuilder contentBuffer;

        public ObjectFileWriter(Context context) {
            this.contentBuffer = new StringBuilder();
            this.objectFile = FSUtils.createTempFile(context, contentBuffer, ".obj");
        }

        public void appendData(String ...data) {
            for (int i = 0; i < data.length; i++) {
                contentBuffer.append(data[i]);
            }

            if (shouldFlush()) {
                writeToFile();
            }
        }

        public boolean shouldFlush() {
            return contentBuffer.length() * BYTES_PER_CHAR >= MAX_MB_IN_BUILDER_BYTES;
        }

        public void writeToFile() {
            try {
                FSUtils.appendStringToFile(objectFile, contentBuffer);
                contentBuffer.setLength(0);
            } catch (IOException e) {
                Log.w("dsf", e.getLocalizedMessage());
            }
        }

        public File getFile() {
            if (contentBuffer.length() > 0) {
                writeToFile();
            }
            return objectFile;
        }
    }
}
