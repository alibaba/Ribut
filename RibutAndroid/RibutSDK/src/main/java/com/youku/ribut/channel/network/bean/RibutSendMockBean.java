package com.youku.ribut.channel.network.bean;

import com.youku.ribut.core.bean.RibutSendBaseBean;

public class RibutSendMockBean extends RibutSendBaseBean {
    public RequestInfo message;

    public RibutSendMockBean() {
        channel = "network";
    }

    public RequestInfo getMessage() {
        return message;
    }

    public void setMessage(RequestInfo message) {
        this.message = message;
    }
}
