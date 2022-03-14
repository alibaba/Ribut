package com.youku.ribut.utils;


import java.util.HashMap;

public class UTEventUtils {
    private static final int EVENT_ID = 19999;
    private static final String PAGE_NAME = "ribut_service";
    private static final String RIBUT_OPEN = "ribut_open";
    private static final String RIBUT_CONNECT_SUCCESS = "ribut_connectSuccess";
    private static final String RIBUT_CONNECT_FAIL = "ribut_connectFail";
    private static final String RIBUT_DISCONNECT = "ribut_disconnect";

    public static void ributOpen() {
        ributUTEvent(RIBUT_OPEN, null);
    }

    public static void ributConnectSuccess() {
        LogUtil.LogI("ribut Connect success");
        ributUTEvent(RIBUT_CONNECT_SUCCESS, null);
    }

    public static void ributConnectFail(String errorCode) {
        HashMap args = new HashMap();
        args.put("errorCode", errorCode);
        ributUTEvent(RIBUT_CONNECT_FAIL, args);
    }

    public static void ributDisconnect() {
        ributUTEvent(RIBUT_DISCONNECT, null);
    }

    private static void ributUTEvent(String ributType, HashMap args) {
        try {
            if (null == args) {
                args = new HashMap();
            }
            LogUtil.LogI("ributType = " + ributType);
        } catch (Exception e) {
            LogUtil.LogI("ributTypeException = " + e.toString());
            e.printStackTrace();
        }
    }
}
