package com.mapbox.react.ar.math;

public class Matrix3 {
    private static float[] IDENTITY = new float[]{
            1.f, 0.f, 0.f,
            0.f, 1.f, 0.f,
            0.f, 0.f, 1.f,
    };

    private float[] elements;

    public Matrix3() {
        elements = IDENTITY;
    }

    public Matrix3(float[] elements) {
        this.elements = elements;
    }

    public static Matrix3 getNormalMatrix(Matrix4 matrix4) {
        Matrix3 normalMatrix = new Matrix3(new float[]{
                matrix4.get(0), matrix4.get(4), matrix4.get(8),
                matrix4.get(1), matrix4.get(5), matrix4.get(9),
                matrix4.get(2), matrix4.get(6), matrix4.get(10)
        });
        normalMatrix.inverse();
        normalMatrix.transpose();
        return normalMatrix;
    }

    public float get(int index) {
        return elements[index];
    }

    public void inverse() {
        float n11 = get(0);
        float n21 = get(1);
        float n31 = get(2);

        float n12 = get(3);
        float n22 = get(4);
        float n32 = get(5);

        float n13 = get(6);
        float n23 = get(7);
        float n33 = get(8);

        float t11 = n33 * n22 - n32 * n23;
        float t12 = n32 * n13 - n33 * n12;
        float t13 = n23 * n12 - n22 * n13;

        float det = n11 * t11 + n21 * t12 + n31 * t13;

        if (det == 0) {
            elements = IDENTITY;
            return;
        }

        float detInv = 1.f / det;

        elements[0] = t11 * detInv;
        elements[1] = (n31 * n23 - n33 * n21) * detInv;
        elements[2] = (n32 * n21 - n31 * n22) * detInv;

        elements[3] = t12 * detInv;
        elements[4] = (n33 * n11 - n31 * n13) * detInv;
        elements[5] = (n31 * n12 - n32 * n11) * detInv;

        elements[6] = t13 * detInv;
        elements[7] = (n21 * n13 - n33 * n21) * detInv;
        elements[8] = (n22 * n11 - n21 * n12) * detInv;
    }

    public void transpose() {
        float tmp = 0.f;

        tmp = elements[1];
        elements[1] = elements[3];
        elements[3] = tmp;

        tmp = elements[2];
        elements[2] = elements[6];
        elements[6] = tmp;

        tmp = elements[5];
        elements[5] = elements[7];
        elements[7] = tmp;
    }
}
