package com.mapbox.react.ar.core;

import com.mapbox.react.ar.math.Face3;
import com.mapbox.react.ar.math.Vector2;
import com.mapbox.react.ar.math.Vector3;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public abstract class Geometry {
    public Vector3[] vertices;

    public List<Face3> faces;
    public List<List<Vector2>> faceVertexUvs;

    public Geometry() {
        faces = new ArrayList<>();
        faceVertexUvs = new ArrayList<>();
    }

    public void computeVertexNormals() {
        Vector3[] localVertices = new Vector3[vertices.length];

        for (int i = 0; i < vertices.length; i++) {
            localVertices[i] = new Vector3();
        }

        Vector3 vA;
        Vector3 vB;
        Vector3 vC;

        Vector3 localA;
        Vector3 localB;
        Vector3 localC;

        Vector3 cb = new Vector3();
        Vector3 ab = new Vector3();

        for (int i = 0; i < faces.size(); i++) {
            Face3 face = faces.get(i);

            vA = vertices[face.a];
            vB = vertices[face.b];
            vC = vertices[face.c];

            cb.subVector(vC, vB);
            ab.subVector(vA, vB);
            cb.cross(ab);


            localVertices[face.a].add(cb);
            localVertices[face.b].add(cb);
            localVertices[face.c].add(cb);

            localA = localVertices[face.a];
            localA.normalize();

            localB = localVertices[face.b];
            localB.normalize();

            localC = localVertices[face.c];
            localC.normalize();

            face.vertexNormals[0].copy(localA);
            face.vertexNormals[1].copy(localB);
            face.vertexNormals[2].copy(localC);
        }
    }

    public void computeFaceNormals() {
        Vector3 cb = new Vector3();
        Vector3 ab = new Vector3();

        for (int i = 0; i < faces.size(); i++) {
            Face3 face = faces.get(i);

            Vector3 vA = vertices[face.a];
            Vector3 vB = vertices[face.b];
            Vector3 vC = vertices[face.c];

            cb.subVector(vC, vB);
            ab.subVector(vA, vB);
            cb.cross(ab);
            cb.normalize();
            face.normal.copy(cb);
        }
    }

    public void addFace(int a, int b, int c, Vector3[] vertexNormals, Vector2[] faceVertexUvs) {
        Face3 face = new Face3(a, b, c, vertexNormals);
        faces.add(face);

        if (faceVertexUvs != null) {
            this.faceVertexUvs.add(new ArrayList<>(Arrays.asList(faceVertexUvs)));
        }
    }

    public BufferGeometry toBufferGeometry() {
        BufferGeometry bufferGeometry = new BufferGeometry();

        bufferGeometry.createBuffer("position", faces.size() * 9);
        bufferGeometry.createBuffer("normal", faces.size() * 9);
        bufferGeometry.createBuffer("uv", faces.size() * 6);

        for (int i = 0; i < faces.size(); i++) {
            Face3 face = faces.get(i);

            Vector3 vA = vertices[face.a];
            bufferGeometry.position.put(vA);

            Vector3 vB = vertices[face.b];
            bufferGeometry.position.put(vB);

            Vector3 vC = vertices[face.c];
            bufferGeometry.position.put(vC);

            Vector3 vN = face.vertexNormals[0];
            bufferGeometry.normal.put(vN);

            vN = face.vertexNormals[1];
            bufferGeometry.normal.put(vN);

            vN = face.vertexNormals[2];
            bufferGeometry.normal.put(vN);

            List<Vector2> vertexUvs = faceVertexUvs.get(i);
            for (Vector2 vertexUv : vertexUvs) {
                bufferGeometry.uv.put(vertexUv);
            }
        }

        return bufferGeometry;
    }

    protected void fromBufferGeometry(BufferGeometry bufferGeometry) {
        BufferGeometry.IntBuffer indices = bufferGeometry.index;
        BufferGeometry.FloatBuffer positions = bufferGeometry.position;
        BufferGeometry.FloatBuffer normals = bufferGeometry.normal;
        BufferGeometry.FloatBuffer uvs = bufferGeometry.uv;

        int i = 0;
        int j = 0;

        Vector3[] tempNormals = new Vector3[normals.size() / 3];
        Vector2[] tempUvs = new Vector2[uvs.size() / 2];
        vertices = new Vector3[positions.size() / 3];

        int vOffset = 0;
        int nOffset = 0;
        int uOffset = 0;

        while (i < positions.size()) {
            vertices[vOffset++] = new Vector3(positions.get(i), positions.get(i + 1), positions.get(i + 2));

            if (normals.size() > 0) {
                tempNormals[nOffset++] = new Vector3(normals.get(i), normals.get(i + 1), normals.get(i + 2));
            }

            if (uvs.size() > 0) {
                tempUvs[uOffset++] = new Vector2(uvs.get(j), uvs.get(j + 1));
            }

            i += 3;
            j += 2;
        }

        for (int f = 0; f < indices.size(); f += 3) {
            int a = indices.get(f);
            int b = indices.get(f + 1);
            int c = indices.get(f + 2);

            Vector3[] vertexNormals = null;
            if (normals.size() > 0) {
                vertexNormals = new Vector3[3];
                vertexNormals[0] = tempNormals[a].clone();
                vertexNormals[1] = tempNormals[b].clone();
                vertexNormals[2] = tempNormals[c].clone();
            }

            Vector2[] localFaceVertexUvs = null;
            if (uvs.size() > 0) {
                localFaceVertexUvs = new Vector2[3];
                localFaceVertexUvs[0] = tempUvs[a].clone();
                localFaceVertexUvs[1] = tempUvs[b].clone();
                localFaceVertexUvs[2] = tempUvs[c].clone();
            }

            addFace(a, b, c, vertexNormals, localFaceVertexUvs);
        }

        this.computeFaceNormals();
    }
}
