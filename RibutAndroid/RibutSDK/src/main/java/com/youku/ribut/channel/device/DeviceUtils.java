package com.youku.ribut.channel.device;

public class DeviceUtils {
    
    public static String getDeviceMessage() {
        return "{\n" +
                "  \"channel\":\"device\",\n" +
                "  \"message\":{\n" +
                "    \"device\":\"" + getDeviceName() + "\"\n" +
                "  }\n" +
                "}";
    }

    public static String getDeviceName() {
        try {
            return android.os.Build.BRAND;
        } catch (Exception e) {
            return "";
        }
    }
}
