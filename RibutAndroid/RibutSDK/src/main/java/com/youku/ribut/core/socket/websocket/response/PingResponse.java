package com.youku.ribut.core.socket.websocket.response;

import com.youku.ribut.core.socket.java_websocket.framing.Framedata;
import com.youku.ribut.core.socket.websocket.dispatcher.IResponseDispatcher;
import com.youku.ribut.core.socket.websocket.dispatcher.ResponseDelivery;

/**
 * 接收到 Ping 数据
 *
 * Created by ZhangKe on 2019/3/28.
 */
public class PingResponse implements Response<Framedata> {

    private Framedata framedata;

    PingResponse() {
    }

    @Override
    public Framedata getResponseData() {
        return framedata;
    }

    @Override
    public void setResponseData(Framedata responseData) {
        this.framedata = responseData;
    }

    @Override
    public void onResponse(IResponseDispatcher dispatcher, ResponseDelivery delivery) {
        dispatcher.onPing(framedata, delivery);
    }

    @Override
    public void release() {
        framedata = null;
        ResponseFactory.releasePingResponse(this);
    }

    @Override
    public String toString() {
        return String.format("[@PingResponse%s->Framedata:%s]",
                hashCode(),
                framedata == null ?
                        "null" :
                        framedata.toString());
    }
}
