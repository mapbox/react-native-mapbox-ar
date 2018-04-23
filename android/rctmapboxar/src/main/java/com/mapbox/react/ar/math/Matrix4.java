package com.mapbox.react.ar.math;

public class Matrix4 {
    private float[] elements;

    public Matrix4() {
        elements = new float[]{
                1.f, 0.f, 0.f, 0.f,
                0.f, 1.f, 0.f, 0.f,
                0.f, 0.f, 1.f, 0.f,
                0.f, 0.f, 0.f, 1.f
        };
    }

    public float get(int index) {
        return elements[index];
    }
}
