package com.youku.ribut.channel.network;

import static com.alibaba.fastjson.util.IOUtils.UTF8;

import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.youku.ribut.api.AliRibutChannelInterface;
import com.youku.ribut.api.AliRibutManager;
import com.youku.ribut.channel.device.DeviceUtils;
import com.youku.ribut.channel.network.bean.MockDataBean;
import com.youku.ribut.channel.network.bean.RequestInfo;
import com.youku.ribut.channel.network.bean.RibutSendMockBean;
import com.youku.ribut.channel.network.constans.MtopGateways;
import com.youku.ribut.utils.LogUtil;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.UnsupportedCharsetException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Headers;
import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.Protocol;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import okio.Buffer;
import okio.BufferedSource;

public class NetworkChannel implements AliRibutChannelInterface, Interceptor {
    private String TAG = NetworkChannel.class.getSimpleName();
    private static NetworkChannel networkChannel;
    private Map<String, String> mockDataMap = new HashMap<>();
    private boolean isRegister = false;

    public static NetworkChannel getInstance() {
        if (null == networkChannel) {
            networkChannel = new NetworkChannel();
        }
        return networkChannel;
    }

    private NetworkChannel() {
        MtopGateways.initList();
    }

    @Override
    public void ributDidConnect() {
        registerInterceptor();
        AliRibutManager.getInstance().sendMessage(DeviceUtils.getDeviceMessage());
    }

    @Override
    public void ributDidFailConnect() {
        unRegisterInterceptor();
    }

    @Override
    public void receiveData(JSONObject jsonData) {
        if (null != jsonData) {
            MockDataBean mockDataBean = JSON.parseObject(jsonData.toJSONString(), MockDataBean.class);
            if (null != mockDataBean) {
                if (mockDataBean.isMockEvent()) {
                    update(mockDataBean);
                } else if (mockDataBean.isDeleteAllEvent()) {
                    deleteAllMockData();
                }
            }
        }
    }

    private void registerInterceptor() {
        isRegister = true;
    }


    private void unRegisterInterceptor() {
        isRegister = false;
    }

    private String getMockData(String apiName) {
        String mockData = "";
        if (mockDataMap != null) {
            mockData = mockDataMap.get(apiName);
        }
        return TextUtils.isEmpty(mockData) ? "" : mockData;
    }

    private synchronized void update(MockDataBean mockDataBean) {
        if (mockDataBean != null) {
            if (mockDataBean.enableMock()) {
                mockDataMap.put(mockDataBean.getApiName(), mockDataBean.getMockData());
            } else {
                mockDataMap.remove(mockDataBean.getApiName());
            }
        }
    }

    private synchronized void deleteAllMockData() {
        if (null != mockDataMap) {
            mockDataMap.clear();
        }
    }

    @Override
    public Response intercept(Chain chain) {
        Request request = chain.request();
        Response proceed = null;
        try {
            proceed = chain.proceed(request);
        } catch (IOException e) {
            e.printStackTrace();
        }
        LogUtil.LogI("_netChannel", "isRegister = " + isRegister);
        if (isRegister) {
            AliRibutManager.getInstance().sendMessage(getRibutInterceptString(request, proceed));
            String mockData = getMockData(request.url().toString());
            if (!TextUtils.isEmpty(mockData)) {
                return new Response.Builder()
                        .protocol(Protocol.HTTP_1_0)
                        .code(200)
                        .request(request)
                        .message("ok")
                        .body(ResponseBody.create(MediaType.get("application/json;charset=UTF-8"), mockData))
                        .build();
            }
        }
        return proceed;
    }

    private String getRibutInterceptString(Request request, Response proceed) {
        RibutSendMockBean bean = new RibutSendMockBean();
        RequestInfo info = new RequestInfo();
        bean.setMessage(info);
        info.apiName = request.url().toString();
        info.headers = new JSONObject();
        Headers headers = request.headers();
        for (String name : headers.names()) {
            info.headers.put(name, headers.get(name));
        }
        info.bizParameters = new JSONObject();
        info.bizParameters.put("自定义参数", "当前无自定义参数");
        info.body = JSON.parseObject(getResponseBody(proceed.body()));
        return JSON.toJSONString(bean);
    }

    private String getResponseBody(ResponseBody responseBody) {
        try {
            BufferedSource source = responseBody.source();
            source.request(Long.MAX_VALUE);
            Buffer buffer = source.buffer();

            Charset charset = UTF8;
            MediaType contentType = responseBody.contentType();
            if (contentType != null) {
                try {
                    charset = contentType.charset(UTF8);
                } catch (UnsupportedCharsetException e) {
                    e.printStackTrace();
                }
            }

            if (responseBody.contentLength() != 0) {
                String result = buffer.clone().readString(charset);
                return result;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
