package com.youku.ribut.channel.orange;

import com.alibaba.fastjson.JSONObject;
import com.youku.ribut.api.AliRibutChannelInterface;
import com.youku.ribut.api.AliRibutManager;

public class DemoChannel implements AliRibutChannelInterface {
    private static final String eventName = "RIBUT_TOOL_CHANNEL_SELECTED_EVENT";

    @Override
    public void ributDidConnect() {
    }

    @Override
    public void ributDidFailConnect() {

    }

    @Override
    public void receiveData(JSONObject jsonData) {
        if (null != jsonData
                && null != jsonData.getString("event")
                && jsonData.getString("event").equals(eventName)) {

            AliRibutManager.getInstance().sendMessage(getJsonString());
        }
    }

    private String getJsonString() {
        return "{\n" +
                "  \"channel\": \"demo\",\n" +
                "  \"message\": {\n" +
                "    \"columns\": [\n" +
                "      {\n" +
                "        \"key\": \"column1\",\n" +
                "        \"title\": \"第1列标题\"\n" +
                "      },\n" +
                "      {\n" +
                "        \"key\": \"column2\",\n" +
                "        \"title\": \"第2列标题\"\n" +
                "      },\n" +
                "      {\n" +
                "        \"key\": \"column3\",\n" +
                "        \"title\": \"第3列标题\"\n" +
                "      },\n" +
                "      {\n" +
                "        \"key\": \"more\",\n" +
                "        \"title\": \"查看\"\n" +
                "      }\n" +
                "    ],\n" +
                "    \"dataSource\": [\n" +
                "      {\n" +
                "        \"column1\": \"第1列第1行内容\",\n" +
                "        \"column2\": \"第2列第1行内容\",\n" +
                "        \"column3\": \"第3列第1行内容\",\n" +
                "        \"content\": {\n" +
                "          \"更多1\": \"test1\",\n" +
                "          \"更多2\": \"test2\",\n" +
                "          \"更多3\": \"test3\"\n" +
                "        }\n" +
                "      },\n" +
                "      {\n" +
                "        \"column1\": \"第1列第2行内容\",\n" +
                "        \"column2\": \"第2列第2行内容\",\n" +
                "        \"column3\": \"第3列第2行内容\",\n" +
                "        \"content\": {\n" +
                "          \"更多1\": \"test1\",\n" +
                "          \"更多2\": \"test2\",\n" +
                "          \"更多3\": \"test3\"\n" +
                "        }\n" +
                "      }\n" +
                "    ]\n" +
                "  }\n" +
                "}";
    }
}
