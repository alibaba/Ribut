package com.youku.ribut.utils;

import android.content.Context;
import android.widget.Toast;

public class ToastUtils {
    public static void showToast(Context context, String msg) {
        try {
            Toast toast = Toast.makeText(context, msg, Toast.LENGTH_LONG);
            toast.show();
        } catch (Exception e) {

        }
    }
}
