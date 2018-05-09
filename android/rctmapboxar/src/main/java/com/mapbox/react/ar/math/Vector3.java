package com.mapbox.react.ar.math;

import java.util.Locale;

public class Vector3 {
    public float x;
    public float y;
    public float z;

    public Vector3() {
        this(0.f, 0.f, 0.f);
    }

    public Vector3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public void copy(Vector3 vector) {
        x = vector.x;
        y = vector.y;
        z = vector.z;
    }

    public Vector3 clone() {
        return new Vector3(x, y, z);
    }

    public void subVector(Vector3 a, Vector3 b) {
        x = a.x - b.x;
        y = a.y - b.y;
        z = a.z - b.z;
    }

    public void cross(Vector3 vector) {
        float newX = y * vector.z - z * vector.y;
        float newY = z * vector.x - x * vector.z;
        float newZ = x * vector.y - y * vector.x;

        x = newX;
        y = newY;
        z = newZ;
    }

    public void add(Vector3 vector) {
        x += vector.x;
        y += vector.y;
        z += vector.z;
    }

    public float length() {
        return (float) Math.sqrt(x * x + y * y + z * z);
    }

    public void normalize() {
        float len = length();
        float scalar = len > 0.f ? 1.f / len : 0.f;

        x *= scalar;
        y *= scalar;
        z *= scalar;
    }

    public void applyMatrix3(Matrix3 matrix) {
        float x = this.x;
        float y = this.y;
        float z = this.z;

        this.x = matrix.get(0) * x + matrix.get(3) * y + matrix.get(6) * z;
        this.y = matrix.get(1) * x + matrix.get(4) * y + matrix.get(7) * z;
        this.z = matrix.get(2) * x + matrix.get(5) * y + matrix.get(8) * z;
    }

    public void applyMatrix4(Matrix4 matrix) {
        float x = this.x;
        float y = this.y;
        float z = this.z;
        float w = 1.f / (matrix.get(3) * x + matrix.get(7) * y + matrix.get(11) * z + matrix.get(15));

        this.x = (matrix.get(0) * x + matrix.get(4) * y + matrix.get(8) * z + matrix.get(12)) * w;
        this.y = (matrix.get(1) * x + matrix.get(5) * y + matrix.get(9) * z + matrix.get(13)) * w;
        this.z = (matrix.get(2) * x + matrix.get(6) * y + matrix.get(10) * z + matrix.get(14)) * w;
    }

    public String toString() {
        return String.format(Locale.ENGLISH, "%f %f %f", x, y, z);
    }
}
