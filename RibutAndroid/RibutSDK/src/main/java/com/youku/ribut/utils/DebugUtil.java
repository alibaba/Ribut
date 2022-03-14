package com.youku.ribut.utils;

import android.util.Log;

public class DebugUtil {

    private static final int MAX_LENGTH = 3900;

    /**
     * 分段打印较长的文本
     *
     * @param tag     标志
     * @param content 内容
     */
    public static void debugLarge(String tag, String content) {
        if (content.length() > MAX_LENGTH) {
            String part = content.substring(0, MAX_LENGTH);
            Log.i(tag, part);

            part = content.substring(MAX_LENGTH, content.length());
            if ((content.length() - MAX_LENGTH) > MAX_LENGTH) {
                debugLarge(tag, part);
            } else {
                Log.i(tag, part);
            }
        } else {
            Log.i(tag, content);
        }
    }
}
