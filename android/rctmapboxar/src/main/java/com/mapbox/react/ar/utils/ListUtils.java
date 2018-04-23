package com.mapbox.react.ar.utils;

import java.util.List;

public class ListUtils {
    public static String join(List<String> list, String delimiter) {
        StringBuilder builder = new StringBuilder();

        for (int i = 0; i < list.size(); i++) {
            String item = list.get(i);

            if (i == list.size() - 1) {
                builder.append(item);
            } else {
                builder.append(item + delimiter);
            }
        }

        return builder.toString();
    }
}
