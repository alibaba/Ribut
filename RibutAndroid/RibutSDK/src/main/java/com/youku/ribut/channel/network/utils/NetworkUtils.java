package com.youku.ribut.channel.network.utils;

import android.content.Context;

import com.youku.ribut.channel.network.NetworkChannel;

import java.io.File;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLSession;

import okhttp3.Cache;
import okhttp3.EventListener;
import okhttp3.OkHttpClient;

public class NetworkUtils {
    public static OkHttpClient getOkHttpClient(Context context) {
        OkHttpClient.Builder builder = new OkHttpClient.Builder();

        //缓存目录
        File externalCacheDir = context.getExternalCacheDir();
        if (externalCacheDir != null) {
            Cache okHttpCache = new Cache(new File(externalCacheDir,
                    "HttpCache"), 30 * 1024 * 1024);
            builder.cache(okHttpCache);
        }

        //连接超时时间,连接超时是在将TCP SOCKET 连接到目标主机时应用的，默认10s
        builder.connectTimeout(30, TimeUnit.SECONDS);
        //读取超时时间, 包括TCP SOCKET和Source 和Response的读取IO操作，默认10s
        builder.readTimeout(20, TimeUnit.SECONDS);
        //写入超时时间，主要指IO的写入操作，默认10s
        builder.writeTimeout(20, TimeUnit.SECONDS);
        //整个调用时期的超时时间，包括解析DNS、链接、写入请求体、服务端处理、以及读取响应结果
        builder.callTimeout(120, TimeUnit.SECONDS);

        //用于单个client监听所有解析事件的，可以用于解析耗时计算
        builder.eventListener(EventListener.NONE);

        //添加网络拦截器，网络拦截器可以操作重定向和失败重连的返回值，以及监控所有的网络数据
        builder.addInterceptor(NetworkChannel.getInstance());

        //在握手期间，如果URL的主机名和服务器的标识主机名不匹配，验证机制可以回调此接口的实现者，以确定是否应该允许此连接。
        //返回false表示不允许此链接，无脑return true 十分不安全
        builder.hostnameVerifier((hostname, session) -> true);
        OkHttpClient client = builder.build();

        return client;
    }
}
