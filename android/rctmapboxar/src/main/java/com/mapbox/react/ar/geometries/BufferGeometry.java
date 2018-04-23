package com.mapbox.react.ar.geometries;

public class BufferGeometry {
    public IntBuffer index;

    public FloatBuffer position;
    public FloatBuffer normal;
    public FloatBuffer uv;

    public void createBuffer(String name, int capacity) {
        switch (name) {
            case "index":
                index = new IntBuffer(capacity);
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

    public static class FloatBuffer {
        float[] buffer;
        private int offset;

        private FloatBuffer(int capacity) {
            this.buffer = new float[capacity];
        }

        public void put(float value) {
            buffer[offset++] = value;
        }

        public float get(int position) {
            return buffer[position];
        }

        public int size() {
            return buffer.length;
        }
    }

    public static class IntBuffer {
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
