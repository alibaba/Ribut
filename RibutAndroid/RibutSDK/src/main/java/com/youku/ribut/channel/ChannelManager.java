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
package com.youku.ribut.channel;

import com.youku.ribut.api.AliRibutChannelInterface;
import com.youku.ribut.channel.network.NetworkChannel;
import com.youku.ribut.channel.sandbox.SandBoxChannel;
import com.youku.ribut.utils.Constant;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class ChannelManager {
    /**
     * 存储所有自定义频道
     */
    private Map<String, AliRibutChannelInterface> mExtensionMap;
    /**
     * 存储默认频道
     */
    private Map<String, AliRibutChannelInterface> mDefaultMap;

    public ChannelManager() {
        mDefaultMap = new HashMap<>();
        mDefaultMap.put(Constant.CHANNEL_NETWORK, NetworkChannel.getInstance());
        mDefaultMap.put(Constant.CHANNEL_SANDBOX, new SandBoxChannel());
    }

    /**
     * 添加频道
     */
    public void putChannel(String channelName, AliRibutChannelInterface ributChannel) {
        if (null == mExtensionMap) {
            mExtensionMap = new HashMap<>();
        }
        mExtensionMap.put(channelName, ributChannel);
    }

    /**
     * 移除频道
     */
    public void removeChannel(String channelName) {
        mExtensionMap.remove(channelName);
    }

    /**
     * 清空已注册频道
     */
    public void clearChannel() {
        mExtensionMap.clear();
    }

    /**
     * 获取全部自定义频道信息
     */
    public Map<String, AliRibutChannelInterface> getExtensionMap() {
        return mExtensionMap;
    }

    /**
     * 获取全部频道信息
     */
    public Set<String> getAllChannelKey() {
        Set<String> channelKey = new HashSet<>();
        channelKey.addAll(getAllExtensionKey());
        channelKey.addAll(mDefaultMap.keySet());
        return channelKey;
    }

    /**
     * 获取全部频道名称
     */
    public Set<String> getAllExtensionKey() {
        if (mExtensionMap != null) {
            return mExtensionMap.keySet();
        } else {
            return new HashSet<>();
        }
    }

    /**
     * 获取指定频道
     */
    public AliRibutChannelInterface getChannel(String channel) {
        if (mExtensionMap.containsKey(channel))
            return mExtensionMap.get(channel);
        if (mDefaultMap.containsKey(channel))
            return mDefaultMap.get(channel);
        return null;
    }

    /**
     * 判断是否包含当前频道
     */
    public boolean containsKey(String channel) {
        if (null == mDefaultMap || null == mExtensionMap) {
            return false;
        }
        return mExtensionMap.containsKey(channel) || mDefaultMap.containsKey(channel);
    }
}
