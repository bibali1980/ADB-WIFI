package com.adbwifi.classes;

import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;
import android.provider.Settings;
import android.widget.Toast;

import android.net.Uri;

import com.adbwifi.MainActivity;
import com.adbwifi.R;

import java.io.IOException;

public class MyService extends Service{

    @Override
    public IBinder onBind(Intent arg0) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopForeground(true);
        boolean IsKeepScreenOnStarted = PreferenceHandler.getSingleton().getBooleanValue(PreferenceHandler.IsKeepScreenOnStarted, true);
        if(IsKeepScreenOnStarted){
            Settings.System.putInt(getApplicationContext().getContentResolver(), Settings.System.SCREEN_OFF_TIMEOUT, Integer.valueOf(PreferenceHandler.getSingleton().getValue(PreferenceHandler.OriginalTime,"30000")));
            PreferenceHandler.getSingleton().setBooleanValue(PreferenceHandler.IsKeepScreenOnStarted, false);
        }
        //Toast.makeText(getApplicationContext(), "STOPPED", Toast.LENGTH_LONG).show();
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);

        try{

            Context context = getApplicationContext();

            PreferenceHandler.getSingleton().setContext(context);

            boolean isSwitched = PreferenceHandler.getSingleton().getBooleanValue(PreferenceHandler.IsSwitched, false);
            if(isSwitched){
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (Settings.System.canWrite(context)) {
                        PreferenceHandler.getSingleton().setValue(PreferenceHandler.OriginalTime, String.valueOf(Settings.System.getInt(context.getContentResolver(), Settings.System.SCREEN_OFF_TIMEOUT)));
                        Settings.System.putInt(context.getContentResolver(), Settings.System.SCREEN_OFF_TIMEOUT, 86400000);
                        PreferenceHandler.getSingleton().setBooleanValue(PreferenceHandler.IsKeepScreenOnStarted, true);
                    }else {

                        WriteSettingsPermission writeSettingsPermission = new WriteSettingsPermission(context);
                        if(writeSettingsPermission.isWritePermissionAllowed()){
                            PreferenceHandler.getSingleton().setValue(PreferenceHandler.OriginalTime, String.valueOf(Settings.System.getInt(context.getContentResolver(), Settings.System.SCREEN_OFF_TIMEOUT)));
                            Settings.System.putInt(context.getContentResolver(), Settings.System.SCREEN_OFF_TIMEOUT, 86400000);
                            PreferenceHandler.getSingleton().setBooleanValue(PreferenceHandler.IsKeepScreenOnStarted, true);
                        }
                    }
                }
            }

            PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
            PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyApp::MyWakelockTag");
            wakeLock.acquire(10000);

            String notification_channel_id = "adbwifi_channel_id";
            String channelName = "ADB Wifi";

            NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

            Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), R.mipmap.ic_launcher);

            Intent notificationClickIntent = new Intent(context, MainActivity.class);
            notificationClickIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, notificationClickIntent, PendingIntent.FLAG_UPDATE_CURRENT);

            Notification.Builder builder = null;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                    builder = (
                            new Notification.Builder(context)
                                    .setDefaults(Notification.DEFAULT_ALL)
                                    .setPriority(Notification.PRIORITY_HIGH)
                                    .setContentIntent(pendingIntent)
                                    .setSmallIcon(R.mipmap.ic_launcher)
                                    .setLargeIcon(largeIcon)
                                    .setOngoing(false));
                }
            }

            builder.setContentTitle("ADB Wifi Active");
            builder.setContentText("\"adb connect "+PreferenceHandler.getSingleton().getValue(PreferenceHandler.InternalIP, "")+":5555\"");


            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            {
                NotificationChannel channel = new NotificationChannel(
                        notification_channel_id,
                        channelName,
                        NotificationManager.IMPORTANCE_HIGH);

                builder.setChannelId(notification_channel_id);
                notificationManager.createNotificationChannel(channel);
            }

            Notification note = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
                note = builder.build();
            }

            startForeground(1555, note);

            //Toast.makeText(getApplicationContext(), "STARTED", Toast.LENGTH_LONG).show();
        }catch (Exception ex){
            Toast.makeText(getApplicationContext(), "ERROR: "+ex.getMessage(), Toast.LENGTH_LONG).show();
        }

        return Service.START_STICKY;
    }

}

