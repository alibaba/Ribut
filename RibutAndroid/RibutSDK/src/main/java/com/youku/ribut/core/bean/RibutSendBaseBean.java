package com.youku.ribut.core.bean;

import java.io.Serializable;

public class RibutSendBaseBean implements Serializable {
    public String channel;

    public RibutSendBaseBean() {
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }
}
