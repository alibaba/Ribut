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
package com.youku.ribut.api;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

import com.youku.ribut.channel.ChannelManager;
import com.youku.ribut.core.socket.AliSocketListener;
import com.youku.ribut.core.socket.websocket.WebSocketHandler;
import com.youku.ribut.core.socket.websocket.WebSocketManager;
import com.youku.ribut.core.socket.websocket.WebSocketSetting;
import com.youku.ribut.utils.ConnectUtils;
import com.youku.ribut.utils.LogUtil;
import com.youku.ribut.utils.ToastUtils;
import com.youku.ribut.utils.UTEventUtils;

/**
 * Ribut overall management, responsible for overall connection,
 * disconnection, channel management, data distribution and other functions
 */
public class AliRibutManager {
    public static AliRibutManager instance;

    private WebSocketManager mManager;
    private ChannelManager mChannelManager;
    private Context mContext;
    private AliSocketListener mSocketListener;
    private long mLastTime = 0;

    private AliRibutManager() {
        if (null == mChannelManager) {
            mChannelManager = new ChannelManager();
        }
    }

    /**
     * Get AliRibutManager through singleton mode
     *
     * @return AliRibutManager
     */
    public static AliRibutManager getInstance() {
        if (null == instance) {
            instance = new AliRibutManager();
        }
        return instance;
    }

    /**
     * Establish a connection with ribut
     *
     * @param url     Ribut's IP address
     * @param context application context
     */
    public void connectWithUrl(String url, Context context) {
        mContext = context;
        Uri uri = Uri.parse(url);
        String queryParameter = uri.getQueryParameter("url");
        queryParameter = Uri.decode(queryParameter);
        if (mManager != null && mManager.isConnect() && !queryParameter.equals(mManager.getSetting().getConnectUrl())) {
            ToastUtils.showToast(context, "设备已连接其它PC端,请杀进程后重试");
            LogUtil.LogI("设备已连接其它PC端,请杀进程后重试");
            return;
        }
        LogUtil.LogI("url = " + url);
        initWebSocket(queryParameter);
        ConnectUtils.saveLastConnectUrl(url, mContext);
        UTEventUtils.ributOpen();
    }

    /**
     * Automatically reconnect ribut, you need to have established a connection before
     *
     * @param context application context
     */
    public void autoConnect(Context context) {
        String url = ConnectUtils.getLastConnectUrl(context);
        if (!TextUtils.isEmpty(url)) {
            LogUtil.LogI("开始重连,url = " + url);
            AliRibutManager.getInstance().connectWithUrl(url, context);
        }
    }

    /**
     * Register a custom channel
     *
     * @param channelName  Your channel name
     * @param ributChannel Your custom channel
     */
    public void registerChannel(String channelName, AliRibutChannelInterface ributChannel) {
        mChannelManager.putChannel(channelName, ributChannel);
    }

    /**
     * Send message to ribut
     *
     * @param content Message content
     */
    public void sendMessage(String content) {
        if (!TextUtils.isEmpty(content) && mManager != null && mManager.isConnect()) {
            mManager.send(content);
        }
    }

    /**
     * Disconnect from ribut
     */
    public void closeConnect() {
        if (null != mManager) {
            mManager.disConnect();
            mManager.destroy();
        }
    }

    /**
     * Initialize the socket connection
     *
     * @param url ribut ip
     */
    private void initWebSocket(final String url) {
        if (TextUtils.isEmpty(url)) {
            return;
        }
        if (System.currentTimeMillis() - mLastTime < 500) {
            LogUtil.LogI("短时间多次请求,已忽略");
            return;
        }
        mLastTime = System.currentTimeMillis();

        startSocketService(url);
    }

    /**
     * Start the socket service
     *
     * @param url ribut ip
     */
    private void startSocketService(String url) {
        try {
            WebSocketSetting setting = new WebSocketSetting();
            setting.setConnectUrl(url);
            mManager = WebSocketHandler.getDefault();
            if (null == mManager) {
                mManager = WebSocketHandler.init(setting);
            }
            mSocketListener = new AliSocketListener(mContext, mChannelManager);
            mManager.addListener(mSocketListener);
            LogUtil.LogI("WebSocketManager start");
            mManager.start();
        } catch (Exception e) {
            LogUtil.LogI("WebSocketManager start error , " + e.getMessage());
        }
    }
}
