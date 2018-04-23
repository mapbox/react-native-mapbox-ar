package com.mapbox.react.ar.math;

public class Face3 {
    public int a;
    public int b;
    public int c;

    public Vector3 normal;
    public Vector3[] vertexNormals;

    public Face3(int a, int b, int c, Vector3[] vertexNormals) {
        this.a = a;
        this.b = b;
        this.c = c;
        this.normal = new Vector3();
        this.vertexNormals = vertexNormals;
    }
}
