package com.youku.ribut.utils;

import android.content.Context;

/**
 * @author: shisan.lms
 * @date: 2021-06-28
 * Description:
 */
public class AppInfoUtils {
    private static Context CONTEXT;

    public static void init(Context context) {
        if (context != null) {
            CONTEXT = context.getApplicationContext();
        }
    }

    public static Context getApplicationContext() {
        return CONTEXT;
    }
}
