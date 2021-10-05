package com.adbwifi.classes;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;

public class WriteSettingsPermission {

    private Context context;

    public WriteSettingsPermission(Context context){
        this.context=context;
    }

    public boolean isWritePermissionAllowed(){
        if (Settings.System.canWrite(context)) {
            return true;
        }else {
            Intent myIntent = new Intent(android.provider.Settings.ACTION_MANAGE_WRITE_SETTINGS);
            myIntent.setData(Uri.parse("package:" + context.getPackageName()));
            myIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(myIntent);

            return false;
        }
    }

}