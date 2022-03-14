package com.youku.ribut.channel.network.constans;

import java.util.ArrayList;
import java.util.List;

public class MtopGateways {

    //线上
    public final static String YOUKU_OFFICIAL = "acs.youku.com";
    //预发
    public final static String YOUKU_PRE = "pre-acs.youku.com";
    //日常
    public final static String YOUKU_DAILY = "daily-acs.youku.com";

    public final static String CDN_REQUEST = "ykimg.alicdn.com";

    public static List<String> sValidMtopGateway = new ArrayList<>();
    public static List<String> sBlackMtopList = new ArrayList<>();


    public static boolean isInValidMtopGateway(final String url) {
        for (String mtopGateway : sValidMtopGateway) {
            if (url.equals(mtopGateway)) {
                return true;
            }
        }
        return false;
    }

    public static void initList() {
        sValidMtopGateway.add(YOUKU_PRE);
        sValidMtopGateway.add(YOUKU_OFFICIAL);
        sValidMtopGateway.add(YOUKU_DAILY);
        sValidMtopGateway.add(CDN_REQUEST);

        sBlackMtopList.add("mtop.taobao.etest.walletmqtask.resultsubmit");
    }

    public static boolean isBlackMtopList(String mtop) {
        for (String blackMtop : sBlackMtopList) {
            if (blackMtop.equals(mtop)) {
                return true;
            }
        }
        return false;
    }
}
