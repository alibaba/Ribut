package com.youku.ribut.network;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.fastjson.JSON;
import com.youku.ribut.channel.network.utils.NetworkUtils;
import com.youku.ribut.demo.R;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.HttpUrl;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class NetworkActivity extends AppCompatActivity {
    private static final String TAG = "NetworkActivity";
    private RecyclerView recyclerView;
    private Button refresh;
    private TextView city;
    private TextView date;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_network);
        initView();
        getNetworkData();
    }

    private void initView() {
        recyclerView = findViewById(R.id.recycler_view);
        refresh = findViewById(R.id.refresh);
        city = findViewById(R.id.city);
        date = findViewById(R.id.date);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        refresh.setOnClickListener(view -> getNetworkData());
    }

    private void getNetworkData() {
        HttpUrl.Builder builder = null;
        HttpUrl httpUrl = HttpUrl.parse("http://t.weather.sojson.com/api/weather/city/101010300");
        if (httpUrl != null) {
            builder = httpUrl.newBuilder();
        }
        if (builder == null) {
            return;
        }
        Request request = new Request.Builder()
                .url(httpUrl)
                .addHeader("Date", getDateFormat())
                .get()
                .build();
        OkHttpClient client = NetworkUtils.getOkHttpClient(this);
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                e.printStackTrace();
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                //第四步，解析响应结果
                ResponseBody body = response.body();
                if (body != null) {
                    String json = body.string();
                    Log.d(TAG, json);
                    new Handler(Looper.getMainLooper()).post(() -> {
                        NetworkDataBean dataBean = JSON.parseObject(json, NetworkDataBean.class);
                        recyclerView.setAdapter(new NetworkAdapter(NetworkActivity.this, dataBean));
                        city.setText(dataBean.getCityInfo().getCity());
                        date.setText(dataBean.getDate());
                    });
                }
            }
        });
    }

    private String getDateFormat() {
        Date d = new Date(System.currentTimeMillis());
        DateFormat format = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.ENGLISH);
        format.setTimeZone(TimeZone.getTimeZone("GMT"));
        return format.format(d);
    }
}