package com.mapbox.react.ar.services.terrian;

import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.ResultReceiver;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.WritableMap;
import com.mapbox.react.ar.MapboxManager;
import com.mapbox.react.ar.core.Object3D;
import com.mapbox.react.ar.math.Vector3;
import com.mapbox.react.ar.utils.GeoUtils;
import com.mapbox.react.ar.geometries.PlaneGeometry;
import com.mapbox.react.ar.utils.BitmapUtils;
import com.mapbox.react.ar.utils.FSUtils;
import com.mapbox.react.ar.utils.ObjFileExporter;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class TerrainIntentService extends IntentService {
    public static final String RGB_URL = "https://api.mapbox.com/v4/mapbox.terrain-rgb/%s/%s/%s.pngraw?access_token=%s";
    public static final String SATELLITE_URL = "https://api.mapbox.com/v4/mapbox.satellite/%s/%s/%s@2x.pngraw?access_token=%s";

    public TerrainIntentService() {
       super(TerrainIntentService.class.getSimpleName());
    }

    public TerrainIntentService(String name) {
        super(name);
    }

    public interface TerrianIntentResultReceiver {
        void onSuccess(WritableMap writableMap);
        void onError(String error);
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        Context context = getApplicationContext();

        ResultReceiver resultReceiver = (ResultReceiver) intent.getParcelableExtra(TerrainResultReceiver.EXTRA_NAME);
        if (resultReceiver == null) {
            return;
        }

        Object3D object3D = new Object3D();

        final String accessToken  = MapboxManager.getInstance().getAccessToken();
        Integer xT = intent.getIntExtra("x", 44);
        Integer yT = intent.getIntExtra("y", 98);
        Integer zT = intent.getIntExtra("z", 8);

        String rgbTileURL = String.format(RGB_URL, zT.toString(), xT.toString(), yT.toString(), accessToken);
        String satelliteTileURL = String.format(SATELLITE_URL, zT.toString(), xT.toString(), yT.toString(), accessToken);

        // reduce bitmap to 1/4 the size to conserve memory
        BitmapFactory.Options rgbOptions = new BitmapFactory.Options();
        rgbOptions.inSampleSize = 4;

        Bitmap rgbBitmap = BitmapUtils.getBitmapFromURL(rgbTileURL, rgbOptions);
        Bitmap satelliteBitmap = BitmapUtils.getBitmapFromURL(satelliteTileURL, null);

        int tileWidth = rgbBitmap.getWidth();
        int tileHeight = rgbBitmap.getHeight();
        PlaneGeometry geometry = new PlaneGeometry(tileWidth, tileHeight, tileWidth - 1, tileHeight - 1);

        float maxElevation = Float.MIN_VALUE;
        float minElevation = Float.MAX_VALUE;
        float[] elevation = new float[tileWidth * tileHeight];

        for (int y = 0; y < tileHeight; y++) {
            for (int x = 0; x < tileWidth; x++) {
                int pixel = rgbBitmap.getPixel(x, y);

                int R = Color.red(pixel);
                int G = Color.green(pixel);
                int B = Color.blue(pixel);

                // get elevation height from vector tile
                float curElevation = ((R * 256 * 256 + G * 256 + B) / 10) - 10000;
                elevation[y * tileWidth + x] = (float) GeoUtils.scaleElevation(curElevation, zT);

                if (curElevation < minElevation) {
                    minElevation = curElevation;
                }

                if (curElevation > maxElevation) {
                    maxElevation = curElevation;
                }
            }
        }

        for (int i = 0; i < geometry.vertices.length; i++) {
            geometry.vertices[i].z = elevation[i];
        }

        geometry.computeVertexNormals();
        object3D.addGeometry("elevations", geometry);

        PlaneGeometry wallGeometry = createWalls(geometry, minElevation, maxElevation, zT);
        object3D.addGeometry("walls", wallGeometry);

        Bundle bundledResults = new Bundle();
        File objFile = null;
        File tileFile = null;

        try {
            objFile = ObjFileExporter.createFile(context, "terrain", object3D);
            tileFile = FSUtils.createTempImageFile(context, satelliteBitmap);
        } catch (IOException e) {
            bundledResults.putString(TerrainResultReceiver.RESULT_NAME, e.getLocalizedMessage());
            resultReceiver.send(TerrainResultReceiver.RESULT_ERROR, bundledResults);
            return;
        }

        HashMap<String, String> data = new HashMap<>();
        data.put("objFileURI", Uri.fromFile(objFile).toString());
        data.put("tileFileURI", Uri.fromFile(tileFile).toString());
        TerrainResponse response = new TerrainResponse(data);

        bundledResults.putParcelable(TerrainResultReceiver.RESULT_NAME, response);
        resultReceiver.send(TerrainResultReceiver.RESULT_OK, bundledResults);
    }

    private PlaneGeometry createWalls(PlaneGeometry geometry, float minElevation, float maxElevation, int zoomLevel) {
        List<Integer> indices = new ArrayList<>();

        // north
        for (int i = 0; i < geometry.width - 1; i++) {
            indices.add(i);
        }

        // east
        for (int i = 1; i < geometry.height; i++) {
            indices.add(i * geometry.width - 1);
        }

        // south
        for (int i = 0; i < geometry.width - 1; i++) {
            indices.add(geometry.height * geometry.width - i - 1);
        }

        // west
        for (int i = 1; i < geometry.height; i++) {
            indices.add(geometry.height * geometry.width - i * geometry.width);
        }

        indices.add(0);
        Collections.reverse(indices);

        int wallLength = indices.size();
        PlaneGeometry wallGeometry = new PlaneGeometry(wallLength, 128, wallLength - 1, 1);
        float wallBottom = minElevation - (maxElevation - minElevation) / 10.f;

        for (int i = 0; i < indices.size(); i++) {
            int index = indices.get(i);
            Vector3 vertex = geometry.vertices[index];

            wallGeometry.vertices[i].x = vertex.x;
            wallGeometry.vertices[i + wallLength].x = vertex.x;

            wallGeometry.vertices[i].y = vertex.y;
            wallGeometry.vertices[i + wallLength].y = vertex.y;

            wallGeometry.vertices[i].z = vertex.z;
            wallGeometry.vertices[i + wallLength].z = (float) GeoUtils.scaleElevation(wallBottom, zoomLevel);
        }

        return wallGeometry;
    }
}
