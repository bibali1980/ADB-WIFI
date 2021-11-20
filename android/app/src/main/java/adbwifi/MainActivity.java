
package com.adbwifi;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.adbwifi.classes.MyService;
import com.adbwifi.classes.WriteSettingsPermission;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity{
    private static final String CHANNEL = "com.adbwifi/adbwifichannel";
    private Intent serviceIntent;

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        serviceIntent = new Intent(MainActivity.this, MyService.class);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if(call.method.equals("startService")){
                    startService(serviceIntent);
                }else if(call.method.equals("stopService")){
                    stopService(serviceIntent);
                }else if(call.method.equals("isWriteSettingsAllowed")){
                    final List<String> list = new ArrayList<>();
                    WriteSettingsPermission writeSettingsPermission = new WriteSettingsPermission(getApplicationContext());
                    if(writeSettingsPermission.isWritePermissionAllowed()){
                        list.add("true");
                    }else{
                        list.add("false");
                    }
                    result.success(list);
                }
              }
            }
        );
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

}
