package com.youku.ribut.channel.orange.bean;

import com.alibaba.fastjson.JSONObject;
import com.youku.ribut.core.bean.RibutSendBaseBean;

import java.io.Serializable;

public class RibutSendOrangeBean extends RibutSendBaseBean {
    public MessageBean message;

    public RibutSendOrangeBean() {
        channel = "WindVane";
    }

    public static class MessageBean implements Serializable {
        public JSONObject request;
        public JSONObject response;
    }
}
