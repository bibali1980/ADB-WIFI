package com.adbwifi.classes;

import android.content.Context;
import android.content.SharedPreferences;

public class PreferenceHandler {

    public static String PREFIX = "flutter.";

    public static String IsSwitched = "IsSwitched";
    public static String IsKeepScreenOnStarted = "IsKeepScreenOnStarted";
    public static String InternalIP = "InternalIP";
    public static String OriginalTime = "OriginalTime";

    private Context context;

    private static PreferenceHandler preferenceHandler;

    private String MY_PREFS_NAME = "FlutterSharedPreferences";

    public static PreferenceHandler getSingleton() {
        if (preferenceHandler == null) {
            preferenceHandler = new PreferenceHandler();
        }
        return preferenceHandler;
    }

    public void setContext(Context context){
        this.context = context;
    }

    public String getValue(String key, String defaultValue)
    {
        SharedPreferences prefs = context.getSharedPreferences(MY_PREFS_NAME, Context.MODE_PRIVATE);
        return prefs.getString(PREFIX + key, defaultValue);
    }

    public void setValue(String key, String value)
    {
        SharedPreferences.Editor editor = context.getSharedPreferences(MY_PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putString(key, value);
        editor.commit();
    }

    public Boolean getBooleanValue(String key, Boolean defaultValue)
    {
        SharedPreferences prefs = context.getSharedPreferences(MY_PREFS_NAME, Context.MODE_PRIVATE);
        return prefs.getBoolean(PREFIX + key, defaultValue);
    }

    public void setBooleanValue(String key, Boolean value)
    {
        SharedPreferences.Editor editor = context.getSharedPreferences(MY_PREFS_NAME, Context.MODE_PRIVATE).edit();
        editor.putBoolean(key, value);
        editor.commit();
    }
}
