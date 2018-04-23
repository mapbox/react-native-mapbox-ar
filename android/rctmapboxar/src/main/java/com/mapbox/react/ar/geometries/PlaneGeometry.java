package com.mapbox.react.ar.geometries;

import com.mapbox.react.ar.core.Geometry;

public class PlaneGeometry extends Geometry {
    public int width;
    public int height;
    public int widthSegments;
    public int heightSegments;

    public PlaneGeometry(int width, int height, int widthSegments, int heightSegments) {
        super();

        this.width = width;
        this.height = height;
        this.widthSegments = widthSegments;
        this.heightSegments = heightSegments;

        this.fromBufferGeometry(new PlaneBufferGeometry(width, height, widthSegments, heightSegments));
    }
}
