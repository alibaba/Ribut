/*
 * Copyright 1999-2021 Alibaba Group.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.youku.ribut.core.socket;

import static com.youku.ribut.core.socket.websocket.response.ErrorResponse.ERROR_NO_CONNECT;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.youku.ribut.api.AliRibutManager;
import com.youku.ribut.channel.ChannelManager;
import com.youku.ribut.core.bean.RibutReceivedBaseBean;
import com.youku.ribut.core.socket.websocket.SimpleListener;
import com.youku.ribut.core.socket.websocket.response.ErrorResponse;
import com.youku.ribut.utils.AppInfoUtils;
import com.youku.ribut.utils.LogUtil;
import com.youku.ribut.utils.ToastUtils;
import com.youku.ribut.utils.UTEventUtils;

public class AliSocketListener extends SimpleListener {
    private Context mContext;
    private long lastConnectedSuccess = 0;
    private ChannelManager mChannelManager;

    public AliSocketListener(Context context, ChannelManager channelManager) {
        mContext = context;
        mChannelManager = channelManager;
    }


    @Override
    public void onConnected() {
        super.onConnected();
        if (System.currentTimeMillis() - lastConnectedSuccess < 500) {
            LogUtil.LogI("短时间连接成功回调,忽略");
            return;
        }

        lastConnectedSuccess = System.currentTimeMillis();
        AppInfoUtils.init(mContext);

        initChannel();

        for (String s : mChannelManager.getAllChannelKey()) {
            if (mChannelManager.containsKey(s)) {
                mChannelManager.getChannel(s).ributDidConnect();
            }
        }

        LogUtil.LogI("onConnected success");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                UTEventUtils.ributConnectSuccess();
                ToastUtils.showToast(AppInfoUtils.getApplicationContext(), "连接成功");
            }
        });
    }

    private void initChannel() {
        //自定义channel添加
        JSONObject messageObject = new JSONObject();
        JSONArray channels = new JSONArray();
        for (String s : mChannelManager.getAllExtensionKey()) {
            channels.add(s);
        }
        messageObject.put("channels", channels);

        JSONObject json1 = new JSONObject();
        json1.put("channel", "Tool");
        json1.put("message", messageObject);
        LogUtil.LogI("sendChannels:" + json1.toJSONString());

        AliRibutManager.getInstance().sendMessage(json1.toJSONString());
    }

    @Override
    public void onDisconnect() {
        super.onDisconnect();
        lastConnectedSuccess = 0;
        for (String s : mChannelManager.getAllChannelKey()) {
            if (mChannelManager.containsKey(s)) {
                mChannelManager.getChannel(s).ributDidFailConnect();
            }
        }
        LogUtil.LogI("onDisconnect");
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                UTEventUtils.ributDisconnect();
            }
        });
    }

    @Override
    public void onSendDataError(final ErrorResponse errorResponse) {
        super.onSendDataError(errorResponse);
        LogUtil.LogI("onSendDAtaError,errorResponse = " + errorResponse);
        if (errorResponse.getErrorCode() == ERROR_NO_CONNECT) {
            //未连接
        }
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                UTEventUtils.ributConnectFail(errorResponse.getErrorCode() + "");
            }
        });
    }

    @Override
    public <T> void onMessage(String message, T data) {
        super.onMessage(message, data);
        RibutReceivedBaseBean receivedBaseBean = JSON.parseObject(message, RibutReceivedBaseBean.class);
        if (TextUtils.isEmpty(receivedBaseBean.channel)) {
            return;
        }
        LogUtil.LogI("onMessage,message = " + message);
        if (mChannelManager.containsKey(receivedBaseBean.channel)) {
            mChannelManager.getChannel(receivedBaseBean.channel).receiveData(receivedBaseBean.value);
        }
    }

    @Override
    public void onConnectFailed(Throwable e) {
        super.onConnectFailed(e);
        lastConnectedSuccess = 0;
        LogUtil.LogI("onConnectFailed,Throwable = " + e.getMessage());
    }
}
