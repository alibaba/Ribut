package com.youku.ribut.utils;

import android.content.Context;

import java.text.SimpleDateFormat;
import java.util.Date;

public class ConnectUtils {
    private static final String RIBUT_TAG = "ribut_";

    public static String getLastConnectUrl(Context context) {
        try {
            return SharedPreferencesUtil.getInstance(context).getSP(getUrlKey());
        } catch (Exception e) {
            return "";
        }
    }

    private static String getUrlKey() {
        return RIBUT_TAG + getData();
    }

    public static void saveLastConnectUrl(String url, Context context) {
        SharedPreferencesUtil.getInstance(context).putSP(getUrlKey(), url);
    }

    private static String getData() {
        long l = System.currentTimeMillis();
        Date date = new Date(l);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd");
        return dateFormat.format(date);
    }
}
