package com.youku.ribut.channel.network.bean;

import android.text.TextUtils;
import android.util.Log;

import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.annotation.JSONField;
import com.youku.ribut.utils.DebugUtil;

import java.io.Serializable;

public class RequestInfo implements Serializable {
    private String tag = "RequestInfo";
    public String apiName;
    public JSONObject headers;
    public JSONObject body;
    public JSONObject bizParameters;

    @JSONField(serialize = false)
    public String originalParams;
    @JSONField(serialize = false)
    public int id;
    @JSONField(serialize = false)
    public String httpUrl; // 完整URL
    @JSONField(serialize = false)
    public String mtopWithPrefix;
    @JSONField(serialize = false)
    public String activityName = "unknown";
    @JSONField(serialize = false)
    public long startTime;
    @JSONField(serialize = false)
    public long endTime;
    @JSONField(serialize = false)
    public int rt;

    public RequestInfo() {
    }

    public void outputLog() {
        Log.i(tag, "============================a new mtop rquest start =============================");
        Log.i(tag, "id = " + id);
        Log.i(tag, "httoUrl = " + httpUrl);
        Log.i(tag, "mtopWithPrefix = " + mtopWithPrefix);
        Log.i(tag, "activityName = " + activityName);
        Log.i(tag, "startTime = " + startTime);
        Log.i(tag, "endTime = " + endTime);
        Log.i(tag, "apiName = " + apiName);
        Log.i(tag, "headers = " + headers);
        Log.i(tag, "bizParameters = " + bizParameters);
        Log.i(tag, "originalParams = " + originalParams);
        DebugUtil.debugLarge(tag + "_resp", body.toString());
        Log.i(tag, "============================a new mtop rquest end =============================\n\n\n");
    }

    public String getApiName() {
        if (TextUtils.isEmpty(apiName)) {
            return "";
        }
        return apiName;
    }
}
