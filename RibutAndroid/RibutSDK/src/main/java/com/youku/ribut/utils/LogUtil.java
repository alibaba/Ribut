package com.youku.ribut.utils;

import static com.youku.ribut.utils.Constant.Tag;

import android.util.Log;

public class LogUtil {
    public static void LogI(String key, String log) {
        Log.i(Tag + key, log);
    }

    public static void LogI(String log) {
        Log.i(Tag, log);
    }
}
