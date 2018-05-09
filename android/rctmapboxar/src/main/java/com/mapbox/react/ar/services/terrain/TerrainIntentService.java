package com.mapbox.react.ar.services.terrain;

import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcelable;
import android.os.ResultReceiver;
import android.support.annotation.Nullable;

import com.mapbox.react.ar.MapboxManager;
import com.mapbox.react.ar.core.Object3D;
import com.mapbox.react.ar.core.TerrainTile;
import com.mapbox.react.ar.math.Vector3;
import com.mapbox.react.ar.utils.GeoUtils;
import com.mapbox.react.ar.geometries.PlaneGeometry;
import com.mapbox.react.ar.utils.BitmapUtils;
import com.mapbox.react.ar.utils.FSUtils;
import com.mapbox.react.ar.core.ObjectFileFactory;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

public class TerrainIntentService extends IntentService {
    public static final String EXTRA_RECEIVER = "terrainReceiver";
    public static final String EXTRA_ZOOM = "zoom";
    public static final String EXTRA_TILES = "tiles";
    public static final String EXTRA_SATELLITE_TILE = "satellite-tile";
    public static final String EXTRA_WIDTH = "width";
    public static final String EXTRA_HEIGHT = "height";
    public static final String EXTRA_HEIGHT_MODIFIER = "height-modifier";
    public static final String EXTRA_SAMPLE_SIZE = "sample-size";

    public TerrainIntentService() {
       super(TerrainIntentService.class.getSimpleName());
    }

    public TerrainIntentService(String name) {
        super(name);
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        if (intent == null) {
            return;
        }

        ResultReceiver resultReceiver = intent.getParcelableExtra(EXTRA_RECEIVER);
        if (resultReceiver == null) {
            return;
        }

        Context context = getApplicationContext();

        int width = intent.getIntExtra(EXTRA_WIDTH, 0);
        int height = intent.getIntExtra(EXTRA_HEIGHT, 0);
        int sampleSize = intent.getIntExtra(EXTRA_SAMPLE_SIZE, 6);
        float zoom = intent.getFloatExtra(EXTRA_ZOOM, 0.f);
        float heightModifier = intent.getFloatExtra(EXTRA_HEIGHT_MODIFIER, 1.f);

        String satelliteURI = intent.getStringExtra(EXTRA_SATELLITE_TILE);

        Parcelable[] parcelables = intent.getParcelableArrayExtra(EXTRA_TILES);
        TerrainTile[] tiles = Arrays.copyOf(parcelables, parcelables.length, TerrainTile[].class);

        BitmapFactory.Options rgbOptions = new BitmapFactory.Options();
        rgbOptions.inSampleSize = sampleSize;

        float minElevation = Float.MAX_VALUE;
        float maxElevation = Float.MIN_VALUE;

        // merge all rgb tiles into one bitmap, from initial x,y pixel values
        Bitmap terrainBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(terrainBitmap);
        for (int i = 0; i < tiles.length; i++) {
            TerrainTile tile = tiles[i];
            Bitmap bitmap = BitmapUtils.getBitmapFromURL(tile.getFormattedURL(), rgbOptions);
            tile.setBitmap(bitmap, sampleSize);
            canvas.drawBitmap(tile.bitmap, tile.px / sampleSize, tile.py / sampleSize, null);
        }

        // create geometry
        int cols = terrainBitmap.getWidth() / sampleSize;
        int rows = terrainBitmap.getHeight() / sampleSize;
        PlaneGeometry geometry = new PlaneGeometry(cols, rows, cols - 1, rows - 1);

        // place elevation into 1d array indexed by y * width + x
        float[] elevation = new float[geometry.vertices.length];
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                int pixelIndex = r * cols + c;
                float curElevation = GeoUtils.getElevation(terrainBitmap.getPixel(c, r));
                elevation[pixelIndex] = curElevation;
            }
        }

        // distort geometry with elevation along z-axis
        for (int i = 0; i < geometry.vertices.length; i++) {
            float curElevation = elevation[i];
            geometry.vertices[i].z = (float) GeoUtils.scaleElevation(curElevation, zoom, heightModifier / sampleSize);

            if (curElevation < minElevation) {
                minElevation = curElevation;
            }

            if (curElevation > maxElevation) {
                maxElevation = curElevation;
            }
        }

        Object3D elevation3D = new Object3D("terrain");
        geometry.computeVertexNormals();
        elevation3D.addGeometry("elevation", geometry);

        // generate walls for terrain geometry
        Object3D wall3D = new Object3D("sides");
        PlaneGeometry wallGeometry = createWalls(geometry, minElevation, maxElevation, zoom, heightModifier / sampleSize);
        wall3D.addGeometry("wall", wallGeometry);

        // create object file, add file uri to bundle and return result
        Bundle bundledResults = new Bundle();
        File objFile, wallFile;

        try {
            objFile = ObjectFileFactory.makeFile(context, elevation3D);
            wallFile = ObjectFileFactory.makeFile(context, wall3D);
        } catch (IOException e) {
            bundledResults.putString(TerrainResultReceiver.RESULT_NAME, e.getLocalizedMessage());
            resultReceiver.send(TerrainResultReceiver.RESULT_ERROR, bundledResults);
            return;
        }

        HashMap<String, Object> data = new HashMap<>();
        data.put("objFileURI", Uri.fromFile(objFile).toString());
        data.put("wallFileURI", Uri.fromFile(wallFile).toString());

        File satelliteFile = createSatelliteTileFile(satelliteURI);
        if (satelliteFile != null) {
            data.put("satelliteFileURI", Uri.fromFile(satelliteFile).toString());
        }

        TerrainResponse response = new TerrainResponse(data);

        bundledResults.putParcelable(TerrainResultReceiver.RESULT_NAME, response);
        resultReceiver.send(TerrainResultReceiver.RESULT_OK, bundledResults);
    }

    private PlaneGeometry createWalls(PlaneGeometry geometry, float minElevation, float maxElevation, double zoom, double heightModifier) {
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
        PlaneGeometry wallGeometry = new PlaneGeometry(wallLength, 2, wallLength - 1, 1);
        float wallBottom = minElevation - (maxElevation - minElevation) / 10.f;
        float scaledWallBottom = (float) GeoUtils.scaleElevation(wallBottom, zoom, heightModifier);

        for (int i = 0; i < indices.size(); i++) {
            int index = indices.get(i);
            Vector3 vertex = geometry.vertices[index];

            wallGeometry.vertices[i].x = vertex.x;
            wallGeometry.vertices[i + wallLength].x = vertex.x;

            wallGeometry.vertices[i].y = vertex.y;
            wallGeometry.vertices[i + wallLength].y = vertex.y;

            wallGeometry.vertices[i].z = vertex.z;
            wallGeometry.vertices[i + wallLength].z = scaledWallBottom;
        }

        return wallGeometry;
    }

    private File createSatelliteTileFile(String satelliteURI) {
        String formattedURI = satelliteURI.replace("{ACCESS_TOKEN}", MapboxManager.getInstance().getAccessToken());
        Bitmap bitmap = BitmapUtils.getBitmapFromURL(formattedURI, null);
        return FSUtils.createTempImageFile(getApplicationContext(), bitmap);
    }
}
