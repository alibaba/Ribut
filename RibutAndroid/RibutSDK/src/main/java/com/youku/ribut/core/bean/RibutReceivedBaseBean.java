package com.youku.ribut.core.bean;


import com.alibaba.fastjson.JSONObject;

import java.io.Serializable;

/**
 * @author: shisan.lms
 * @date: 2021-06-29
 * Description: 收到的Message信息
 */
public class RibutReceivedBaseBean implements Serializable {

    public String channel;

    public JSONObject value;

    public RibutReceivedBaseBean() {
    }
}
