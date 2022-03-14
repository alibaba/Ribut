package com.youku.ribut;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

import com.huawei.hms.hmsscankit.ScanUtil;
import com.huawei.hms.ml.scan.HmsScan;
import com.huawei.hms.ml.scan.HmsScanAnalyzerOptions;
import com.youku.ribut.api.AliRibutManager;
import com.youku.ribut.channel.orange.DemoChannel;
import com.youku.ribut.network.NetworkActivity;
import com.youku.ribut.demo.R;

public class MainActivity extends AppCompatActivity {
    private static final int CAMERA_REQ_CODE = 54566;
    private static final int REQUEST_CODE_SCAN = 54568;
    private static final int PERMISSIONS_LENGTH = 2;

    private Button scanButton;
    private Button connectButton;
    private Button reconnectButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initViewById();
    }

    private void initViewById() {
        scanButton = findViewById(R.id.ribut_scan_button);
        connectButton = findViewById(R.id.ribut_connect_button);
        reconnectButton = findViewById(R.id.ribut_reconnect);
        scanButton.setOnClickListener(view -> {
            // CAMERA_REQ_CODE为用户自定义，用于接收权限校验结果的请求码。
            if (Build.VERSION.SDK_INT >= 23) {
                MainActivity.this.requestPermissions(new String[]{Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE}, CAMERA_REQ_CODE);
            }
        });

        connectButton.setOnClickListener(view -> {
            Intent intent = new Intent(MainActivity.this, NetworkActivity.class);
            startActivity(intent);
        });

        reconnectButton.setOnClickListener(view ->
                AliRibutManager.getInstance().autoConnect(MainActivity.this));
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        // 判断“requestCode”是否为申请权限时设置请求码CAMERA_REQ_CODE，然后校验权限开启状态。
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == CAMERA_REQ_CODE && grantResults.length == PERMISSIONS_LENGTH
                && grantResults[0] == PackageManager.PERMISSION_GRANTED
                && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
            // 调用扫码接口，构建扫码能力。
            ScanUtil.startScan(MainActivity.this, REQUEST_CODE_SCAN, new HmsScanAnalyzerOptions.Creator().setHmsScanTypes(HmsScan.ALL_SCAN_TYPE).create());
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 当扫码页面结束后，处理扫码结果。
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK || data == null) {
            return;
        }
        // 从onActivityResult返回data中，用ScanUtil.RESULT作为key值取到HmsScan返回值。
        if (requestCode == REQUEST_CODE_SCAN) {
            Object obj = data.getParcelableExtra(ScanUtil.RESULT);
            if (obj instanceof HmsScan) {
                AliRibutManager.getInstance().registerChannel("demo", new DemoChannel());
                AliRibutManager.getInstance().connectWithUrl(((HmsScan) obj).getOriginalValue(), MainActivity.this);
                return;
            }
        }
    }

}