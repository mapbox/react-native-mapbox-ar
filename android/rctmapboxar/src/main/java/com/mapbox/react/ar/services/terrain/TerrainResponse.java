package com.mapbox.react.ar.services.terrain;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.HashMap;

public class TerrainResponse implements Parcelable {
    public HashMap<String, Object> data;

    public TerrainResponse(HashMap<String, Object> data) {
        this.data = data;
    }

    @SuppressWarnings("unchecked")
    protected TerrainResponse(Parcel in) {
        data = in.readHashMap(HashMap.class.getClassLoader());
    }

    public static final Creator<TerrainResponse> CREATOR = new Creator<TerrainResponse>() {
        @Override
        public TerrainResponse createFromParcel(Parcel in) {
            return new TerrainResponse(in);
        }

        @Override
        public TerrainResponse[] newArray(int size) {
            return new TerrainResponse[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeMap(data);
    }
}
