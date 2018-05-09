package com.mapbox.react.ar.core;

import android.content.Context;
import android.util.Log;

import com.mapbox.react.ar.math.Face3;
import com.mapbox.react.ar.math.Matrix3;
import com.mapbox.react.ar.math.Matrix4;
import com.mapbox.react.ar.math.Vector2;
import com.mapbox.react.ar.math.Vector3;
import com.mapbox.react.ar.utils.ListUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class ObjectFileFactory {
    private static Matrix4 WORLD_MATRIX = new Matrix4();
    private static Matrix3 NORMAL_WORLD_MATRIX = Matrix3.getNormalMatrix(WORLD_MATRIX);

    public static File makeFile(Context context, Object3D object3D) throws IOException {
        ObjectFileWriter writer = new ObjectFileWriter(context);

        writer.appendData("o " + object3D.name + "\n");

        int indexVert = 0;
        int indexNorm = 0;
        int indexUv = 0;

        String[] line = new String[3];
        line[2] = "\n";

        Vector3 vector3 = new Vector3();
        Vector2 vector2 = new Vector2();

        for (Map.Entry<String, Geometry> item : object3D.geometries.entrySet()) {
            BufferGeometry bufferGeometry = item.getValue().toBufferGeometry();

            int curVert = 0;
            int curNorm = 0;
            int curUv = 0;

            line[0] = "v ";
            for (int i = 0; i < bufferGeometry.position.size(); i += 3) {
                vector3.x = bufferGeometry.position.get(i);
                vector3.y = bufferGeometry.position.get(i + 1);
                vector3.z = bufferGeometry.position.get(i + 2);

                // convert from model space to world space
                vector3.applyMatrix4(WORLD_MATRIX);

                line[1] = vector3.toString();
                writer.appendData(line);

                curVert++;
            }

            line[0] = "vn ";
            for (int i = 0; i < bufferGeometry.normal.size(); i += 3) {
                vector3.x = bufferGeometry.normal.get(i);
                vector3.y = bufferGeometry.normal.get(i + 1);
                vector3.z = bufferGeometry.normal.get(i + 2);

                // convert from model space to world space
                vector3.applyMatrix3(NORMAL_WORLD_MATRIX);

                line[1] = vector3.toString();
                writer.appendData(line);

                curNorm++;
            }


            line[0] = "vt ";
            for (int i = 0; i < bufferGeometry.uv.size(); i += 2) {
                vector2.x = bufferGeometry.uv.get(i);
                vector2.y = bufferGeometry.uv.get(i + 1);
                line[1] = vector2.toString();
                writer.appendData(line);

                curUv++;
            }

            String faceStrFormat = "%d/%d/%d";
            List<String> face = new ArrayList<>();

            line[0] = "f ";
            for (int i = 0; i < bufferGeometry.position.size() / 3; i += 3) {
                for (int m = 0; m < 3; m++) {
                    int j = i + m + 1;
                    face.add(String.format(Locale.ENGLISH, faceStrFormat, indexVert + j, indexUv + j, indexNorm + j));
                }
                String faceStr = ListUtils.join(face, " ");
                line[1] = faceStr;
                writer.appendData(line);
                face.clear();
            }

            indexVert += curVert;
            indexNorm += curNorm;
            indexUv += curUv;

            writer.appendData("\n");
        }

        return writer.getFile();
    }
}
