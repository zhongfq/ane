package openane.tencent.core;

import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import com.adobe.air.TencentActivityResultCallback;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.TencentStateChangeCallback;
import com.adobe.fre.FREContext;

import java.io.PrintWriter;
import java.io.StringWriter;

public abstract class OpenaneContext extends FREContext implements TencentActivityResultCallback,
        TencentStateChangeCallback {

    public OpenaneContext() {
        AndroidActivityWrapper wrapper = AndroidActivityWrapper.GetAndroidActivityWrapper();
        wrapper.addActivityResultListener(this);
        wrapper.addActivityStateChangeListner(this);
    }

    public void print(String msg) {
        dispatchStatusEventAsync("print", msg);
    }

    public void print(Throwable e) {
        StringWriter writer = new StringWriter();
        e.printStackTrace(new PrintWriter(writer));
        print(writer.toString());
    }

    public boolean checkNetwork() {
        ConnectivityManager cm = (ConnectivityManager) getActivity().getSystemService(
                Context.CONNECTIVITY_SERVICE);
        if (cm != null) {
            NetworkInfo[] infos = cm.getAllNetworkInfo();
            if (infos != null) {
                for (NetworkInfo ni : infos) {
                    if (ni.isConnected() && (ni.getType() == ConnectivityManager.TYPE_MOBILE
                            || ni.getType() == ConnectivityManager.TYPE_WIFI)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    @Override
    public void dispose() {
        AndroidActivityWrapper wrapper = AndroidActivityWrapper.GetAndroidActivityWrapper();
        wrapper.removeActivityResultListener(this);
        wrapper.removeActivityStateChangeListner(this);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
    }

    @Override
    public void onActivityStateChanged(AndroidActivityWrapper.ActivityState activityState) {
    }

    @Override
    public void onConfigurationChanged(Configuration configuration) {
    }
}
