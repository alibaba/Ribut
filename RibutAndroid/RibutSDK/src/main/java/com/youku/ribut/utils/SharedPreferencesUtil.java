package com.youku.ribut.utils;

import android.content.Context;
import android.content.SharedPreferences;

public class SharedPreferencesUtil {

    public static final String mTAG = "test";
    // 创建一个写入器
    private static SharedPreferences mPreferences;
    private static SharedPreferences.Editor mEditor;
    private static SharedPreferencesUtil mSharedPreferencesUtil;

    // 构造方法
    public SharedPreferencesUtil(Context context) {
        mPreferences = context.getSharedPreferences(mTAG, Context.MODE_PRIVATE);
        mEditor = mPreferences.edit();
    }

    // 单例模式
    public static SharedPreferencesUtil getInstance(Context context) {
        if (mSharedPreferencesUtil == null) {
            mSharedPreferencesUtil = new SharedPreferencesUtil(context);
        }
        return mSharedPreferencesUtil;
    }

    // 存入数据
    public void putSP(String key, String value) {
        mEditor.putString(key, value);
        mEditor.commit();
    }

    // 获取数据
    public String getSP(String key) {
        return mPreferences.getString(key, "");
    }

    // 移除数据
    public void removeSP(String key) {
        mEditor.remove(key);
        mEditor.commit();
    }
}
