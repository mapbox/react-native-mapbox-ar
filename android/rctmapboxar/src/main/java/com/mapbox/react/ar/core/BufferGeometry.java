package com.mapbox.react.ar.core;

import com.mapbox.react.ar.math.Vector2;
import com.mapbox.react.ar.math.Vector3;

public class BufferGeometry {
    public IntBuffer index;

    public FloatBuffer position;
    public FloatBuffer normal;
    public FloatBuffer uv;

    public void createBuffer(String name, int capacity) {
        switch (name) {
            case "index":
                index = new IntBuffer(capacity);
                break;
            case "position":
                position = new FloatBuffer(capacity);
                break;
            case "normal":
                normal = new FloatBuffer(capacity);
                break;
            case "uv":
                uv = new FloatBuffer(capacity);
                break;
        }
    }

    public static final class FloatBuffer {
        float[] buffer;
        private int offset;

        private FloatBuffer(int capacity) {
            this.buffer = new float[capacity];
        }

        public void put(float value) {
            buffer[offset++] = value;
        }

        public void put(Vector3 vector3) {
            put(vector3.x);
            put(vector3.y);
            put(vector3.z);
        }

        public void put(Vector2 vector2) {
            put(vector2.x);
            put(vector2.y);
        }

        public float get(int position) {
            return buffer[position];
        }

        public int size() {
            return buffer.length;
        }
    }

    public static final class IntBuffer {
        int[] buffer;
        private int offset;

        private IntBuffer(int capacity) {
            this.buffer = new int[capacity];
        }

        public void put(int value) {
            buffer[offset++] = value;
        }

        public int get(int position) {
            return buffer[position];
        }

        public int size() {
            return buffer.length;
        }
    }
}
