package com.mapbox.react.ar.core;

import android.graphics.Bitmap;
import android.os.Parcel;
import android.os.Parcelable;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.mapbox.react.ar.MapboxManager;

public class TerrainTile implements Parcelable {
    public String url;
    public int px;
    public int py;

    public int sampleSize = 1;

    public Bitmap bitmap;

    public TerrainTile() {
    }

    protected TerrainTile(Parcel in) {
        url = in.readString();
        px = in.readInt();
        py = in.readInt();
    }

    public String getFormattedURL() {
        return url.replace("{ACCESS_TOKEN}", MapboxManager.getInstance().getAccessToken());
    }

    public int getWidth() {
        return bitmap.getWidth();
    }

    public int getHeight() {
        return bitmap.getHeight();
    }

    public Integer[] getPixels() {
        Integer[] pixels = new Integer[getWidth() * getHeight()];

        for (int y = 0; y < getHeight(); y++) {
            for (int x = 0; x < getWidth(); x++) {
                pixels[y * getWidth() + x] = getPixel(x, y);
            }
        }

        return  pixels;
    }

    public int getPixel(int x, int y) {
        return bitmap.getPixel(x, y);
    }

    public void setBitmap(Bitmap bitmap, int sampleSize) {
        this.bitmap = bitmap;
        this.sampleSize = sampleSize;
    }

    public static final Creator<TerrainTile> CREATOR = new Creator<TerrainTile>() {
        @Override
        public TerrainTile createFromParcel(Parcel in) {
            return new TerrainTile(in);
        }

        @Override
        public TerrainTile[] newArray(int size) {
            return new TerrainTile[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(url);
        dest.writeInt(px);
        dest.writeInt(py);
    }

    public static TerrainTile[] fromReadableArray(ReadableArray array) {
        TerrainTile[] tiles = new TerrainTile[array.size()];

        for (int i = 0; i < array.size(); i++) {
            tiles[i] = TerrainTile.fromReadableMap(array.getMap(i));
        }

        return tiles;
    }

    public static TerrainTile fromReadableMap(ReadableMap map) {
        TerrainTile tile = new TerrainTile();
        tile.url = map.getString("url");
        tile.px = map.getInt("px");
        tile.py = map.getInt("py");
        return tile;
    }
}
