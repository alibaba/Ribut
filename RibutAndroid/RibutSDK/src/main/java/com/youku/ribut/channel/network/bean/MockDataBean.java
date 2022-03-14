package com.youku.ribut.channel.network.bean;

import com.alibaba.fastjson.JSONObject;
import com.youku.ribut.core.bean.ReceivedBaseValueDTO;

public class MockDataBean extends ReceivedBaseValueDTO {
    private String deleteAllEvent = "yksc.event.ribut.DeleteAllMockMtopEvent";
    private String mockEvent = "yksc.event.ribut.mockMtopEvent";

    public String apiName;
    public Boolean enableMock;
    public JSONObject json;

    public MockDataBean() {
    }

    public boolean isMockEvent() {
        if (null != event) {
            return event.equals(mockEvent);
        }
        return false;
    }

    public boolean isDeleteAllEvent() {
        if (null != event) {
            return event.equals(deleteAllEvent);
        }
        return false;
    }

    public boolean enableMock() {
        if (null != enableMock) {
            return enableMock;
        } else {
            return false;
        }
    }

    public String getApiName() {
        if (null != apiName) {
            return apiName;
        } else {
            return "";
        }
    }

    public String getMockData() {
        if (null != json) {
            return json.toJSONString();
        } else {
            return "";
        }
    }
}
