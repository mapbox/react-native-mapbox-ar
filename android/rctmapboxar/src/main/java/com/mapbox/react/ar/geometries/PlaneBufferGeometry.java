package com.mapbox.react.ar.geometries;

import com.mapbox.react.ar.core.BufferGeometry;

public class PlaneBufferGeometry extends BufferGeometry {
    public int width;
    public int height;
    public int widthSegments;
    public int heightSegments;

    public PlaneBufferGeometry(int width, int height, int widthSegments, int heightSegments) {
        super();
        this.width = width;
        this.height = height;
        this.widthSegments = widthSegments;
        this.heightSegments = heightSegments;
        this.init();
    }

    private void init() {
        // compute vertices, normals, indices and uvs
        int gridX = widthSegments;
        int gridY = heightSegments;

        int gridX1 = gridX + 1;
        int gridY1 = gridY + 1;

        float widthHalf = (float) width / 2.f;
        float heightHalf = (float) height / 2.f;

        float segmentWidth = (float) width / gridX;
        float segmentHeight = (float) height / gridY;

        // buffers
        this.createBuffer("index", gridX * gridY * 6);
        this.createBuffer("position", gridX1 * gridY1 * 3);
        this.createBuffer("normal", gridX1 * gridY1 * 3);
        this.createBuffer("uv", gridX1 * gridY1 * 2);

        // vertices, normals, uvs
        for (int iy = 0; iy < gridY1; iy++) {
            float y = (float) iy * segmentHeight - heightHalf;

            for (int ix = 0; ix < gridX1; ix++) {
                float x = (float) ix * segmentWidth - widthHalf;

                position.put(x);
                position.put(-y);
                position.put(0.f);

                normal.put(0.f);
                normal.put(0.f);
                normal.put(1.f);

                uv.put((float) ix / gridX);
                uv.put(1.f - ((float) iy / gridY));
            }
        }

        // indices
        for (int iy = 0; iy < gridY; iy++) {
            for (int ix = 0; ix < gridX; ix++) {
                int a = ix + gridX1 * iy;
                int b = ix + gridX1 * (iy + 1);
                int c = (ix + 1) + gridX1 * (iy + 1);
                int d = (ix + 1) + gridX1 * iy;

                index.put(a);
                index.put(b);
                index.put(d);

                index.put(b);
                index.put(c);
                index.put(d);
            }
        }
    }
}
