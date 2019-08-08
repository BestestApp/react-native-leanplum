package com.reactnativeleanplum;

import android.app.Application;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import android.os.Build;
import android.app.NotificationManager;
import android.app.NotificationChannel;

public class RNLeanplumPackage implements ReactPackage {
    private Application application;
    private Keys keys;

    public RNLeanplumPackage(Application app, Keys keys) {
        this.application = app;
        this.keys = keys;
    }

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

        modules.add(new RNLeanplum(reactContext, application, keys));
        modules.add(new RNLPInbox(reactContext, application));
        modules.add(new RNLPInboxMessage(reactContext, application));

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

