package com.youku.ribut.channel.sandbox;

import android.text.TextUtils;
import android.util.Base64;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.youku.ribut.api.AliRibutChannelInterface;
import com.youku.ribut.api.AliRibutManager;
import com.youku.ribut.channel.sandbox.bean.SandBoxReceivedBean;
import com.youku.ribut.utils.Constant;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.List;

public class SandBoxChannel implements AliRibutChannelInterface {
    @Override
    public void ributDidConnect() {
        getSandBoxFileList();
    }

    @Override
    public void ributDidFailConnect() {

    }

    @Override
    public void receiveData(JSONObject jsonData) {
        SandBoxReceivedBean sandBoxBean = JSON.parseObject(jsonData.toString(), SandBoxReceivedBean.class);
        if (sandBoxBean.event.equals(Constant.SANDBOX_QUERY_LIST_EVENT)) {
            getSandBoxFileList();
        }
        if (sandBoxBean.event.equals(Constant.SANDBOX_QUERY_SINGLE_FILE_EVENT)) {
            getSandBoxSingleFile(sandBoxBean.getFilePath());
        }
    }

    public void getSandBoxFileList() {
        List<File> list = SandBoxUtils.getRootFiles();

        JSONObject message = new JSONObject();

        JSONArray children = getDirJson(list);
        message.put("name", "root");
        message.put("children", children);
        message.put("toggle", true);

        formatDataToSend(message.toJSONString(), Constant.SANDBOX_QUERY_LIST_EVENT);
    }

    private JSONArray getDirJson(List<File> fileList) {
        JSONArray curChildren = new JSONArray();

        for (File file : fileList) {
            JSONObject item = new JSONObject();
            item.put("size", file.length());
            item.put("path", file.getAbsolutePath());
            item.put("name", file.getName());

            String type = file.isDirectory() ? "dir" : "file";
            item.put("type", type);
            if (type.equals("dir")) {
                JSONArray children = getDirJson(SandBoxUtils.getFiles(new File(file.getAbsolutePath())));
                item.put("children", children);
            }
            curChildren.add(item);
        }
        return curChildren;
    }


    //    {"channel":"sandbox","value":{"event":"yksc.event.ribut.querySandBoxSingleFileEvent","level":0,"name":"root"}}
    public void getSandBoxSingleFile(String filepath) {
        if (TextUtils.isEmpty(filepath) || filepath.equals("root")) {
            return;
        }
        File targetFile = new File(filepath);
        StringBuffer messageText = null;
        ByteBuffer messageByte = null;

        if (SandBoxUtils.isTextFile(targetFile.getName())) {
            messageText = new StringBuffer();
        } else {
            messageByte = ByteBuffer.allocateDirect((int) targetFile.length());
        }

        try {
            BufferedInputStream bufferedInputStream = new BufferedInputStream(new FileInputStream(targetFile));
            int tempChar;
            while ((tempChar = bufferedInputStream.read()) != -1) {
                if (messageText != null) {
                    messageText.append((char) tempChar);
                } else {
                    messageByte.put((byte) tempChar);
                }
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        String result = messageText != null ? messageText.toString() : Base64.encodeToString(messageByte.array(), Base64.DEFAULT);

        if (!TextUtils.isEmpty(result)) {
            formatDataToSend(result, Constant.SANDBOX_QUERY_SINGLE_FILE_EVENT, targetFile.getName());
        }

    }

    public void formatDataToSend(String message, String event, String filename) {
        JSONObject messageExternal = new JSONObject();
        messageExternal.put("message", message);
        messageExternal.put("event", event);

        if (event.equals(Constant.SANDBOX_QUERY_SINGLE_FILE_EVENT) && !TextUtils.isEmpty(filename)) {
            messageExternal.put("name", filename);
            if (SandBoxUtils.isTextFile(filename)) {
                messageExternal.put("utf8encode", true);
            } else {
                messageExternal.put("utf8encode", false);
            }
        }

        JSONObject channel = new JSONObject();
        channel.put("channel", "sandbox");
        channel.put("message", messageExternal);

        AliRibutManager.getInstance().sendMessage(channel.toJSONString());
    }

    public void formatDataToSend(String message, String event) {
        formatDataToSend(message, event, null);
    }
}
