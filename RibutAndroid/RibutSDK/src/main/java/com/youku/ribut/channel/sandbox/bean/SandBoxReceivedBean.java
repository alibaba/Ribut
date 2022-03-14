package com.youku.ribut.channel.sandbox.bean;

import com.youku.ribut.core.bean.ReceivedBaseValueDTO;

/**
 * @author: shisan.lms
 * @date: 2021-06-29
 * Description:
 */
public class SandBoxReceivedBean extends ReceivedBaseValueDTO {

    public String level;
    public String name;
    public String path;

    public SandBoxReceivedBean() {
    }

    public String getFilePath() {
        return path;
    }
}
