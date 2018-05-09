package com.mapbox.react.ar.math;

import java.util.Locale;

public class Vector2 {
    public float x;
    public float y;

    public Vector2() {
        this(0.f, 0.f);
    }

    public Vector2(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public Vector2 clone() {
        return new Vector2(x, y);
    }

    public String toString() {
        return String.format(Locale.ENGLISH, "%f %f", x, y);
    }
}
