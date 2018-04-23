package com.mapbox.react.ar.core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Object3D {
    public LinkedHashMap<String, Geometry> geometries;

    public Object3D() {
        geometries = new LinkedHashMap<>();
    }

    public void addGeometry(String name, Geometry geometry) {
        geometries.put(name, geometry);
    }
}
