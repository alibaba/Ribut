package com.youku.ribut.network;

import com.alibaba.fastjson.annotation.JSONField;

import java.io.Serializable;
import java.util.List;

@lombok.NoArgsConstructor
@lombok.Data
public class NetworkDataBean implements Serializable {
    @JSONField(name = "message")
    private String message;
    @JSONField(name = "status")
    private Integer status;
    @JSONField(name = "date")
    private String date;
    @JSONField(name = "time")
    private String time;
    @JSONField(name = "cityInfo")
    private CityInfoDTO cityInfo;
    @JSONField(name = "data")
    private DataDTO data;

    @lombok.NoArgsConstructor
    @lombok.Data
    public static class CityInfoDTO {
        @JSONField(name = "city")
        private String city;
        @JSONField(name = "citykey")
        private String citykey;
        @JSONField(name = "parent")
        private String parent;
        @JSONField(name = "updateTime")
        private String updateTime;
    }

    @lombok.NoArgsConstructor
    @lombok.Data
    public static class DataDTO {
        @JSONField(name = "shidu")
        private String shidu;
        @JSONField(name = "pm25")
        private Double pm25;
        @JSONField(name = "pm10")
        private Double pm10;
        @JSONField(name = "quality")
        private String quality;
        @JSONField(name = "wendu")
        private String wendu;
        @JSONField(name = "ganmao")
        private String ganmao;
        @JSONField(name = "forecast")
        private List<ForecastDTO> forecast;
        @JSONField(name = "yesterday")
        private DataDTO.YesterdayDTO yesterday;

        @lombok.NoArgsConstructor
        @lombok.Data
        public static class YesterdayDTO {
            @JSONField(name = "date")
            private String date;
            @JSONField(name = "high")
            private String high;
            @JSONField(name = "low")
            private String low;
            @JSONField(name = "ymd")
            private String ymd;
            @JSONField(name = "week")
            private String week;
            @JSONField(name = "sunrise")
            private String sunrise;
            @JSONField(name = "sunset")
            private String sunset;
            @JSONField(name = "aqi")
            private Integer aqi;
            @JSONField(name = "fx")
            private String fx;
            @JSONField(name = "fl")
            private String fl;
            @JSONField(name = "type")
            private String type;
            @JSONField(name = "notice")
            private String notice;
        }

        @lombok.NoArgsConstructor
        @lombok.Data
        public static class ForecastDTO {
            @JSONField(name = "date")
            private String date;
            @JSONField(name = "high")
            private String high;
            @JSONField(name = "low")
            private String low;
            @JSONField(name = "ymd")
            private String ymd;
            @JSONField(name = "week")
            private String week;
            @JSONField(name = "sunrise")
            private String sunrise;
            @JSONField(name = "sunset")
            private String sunset;
            @JSONField(name = "aqi")
            private Integer aqi;
            @JSONField(name = "fx")
            private String fx;
            @JSONField(name = "fl")
            private String fl;
            @JSONField(name = "type")
            private String type;
            @JSONField(name = "notice")
            private String notice;
        }
    }
}
