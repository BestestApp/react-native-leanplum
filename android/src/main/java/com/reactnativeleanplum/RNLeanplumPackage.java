package com.reactnativeleanplum;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

public class RNLeanplumPackage implements ReactPackage {

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }

    private void initialiseChannels(ReactApplicationContext c){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "default";
            String description = "default channel to send message";
            String CHANNEL_ID="0";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            NotificationManager notificationManager = c.getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        initialiseChannels(reactContext);
        modules.add(new RNLeanplum(reactContext));
        modules.add(new RNLPInbox(reactContext));
        modules.add(new RNLPInboxMessage(reactContext));
        return modules;
    }

    public static class Keys {
        private String appId;
        private String devId;
        private String prodId;

        public Keys(String appId, String devId, String prodId){
            this.appId = appId;
            this.devId = devId;
            this.prodId = prodId;
        }

        String getAppId() {
            return appId;
        }

        String getDevId() {
            return devId;
        }

        String getProdId() {
            return prodId;
        }
    }
}

