package com.youku.ribut.channel.network.utils;

import android.text.TextUtils;

public class StringUtil {
    public static int str2Int(String s, int defaultValue) {
        if (TextUtils.isEmpty(s)) {
            return defaultValue;
        } else {
            try {
                return Integer.parseInt(s);
            } catch (Exception var3) {
                return defaultValue;
            }
        }
    }
}

