package com.mapbox.react.ar.core;

import java.util.LinkedHashMap;

public class Object3D {
    public String name;
    public LinkedHashMap<String, Geometry> geometries;

    public Object3D(String name) {
        this.name = name;
        this.geometries = new LinkedHashMap<>();
    }

    public void addGeometry(String name, Geometry geometry) {
        geometries.put(name, geometry);
    }
}
