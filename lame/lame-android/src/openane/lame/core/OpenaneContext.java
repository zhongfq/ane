package openane.lame.core;

import android.content.Intent;
import android.content.res.Configuration;
import android.util.Log;
import com.adobe.air.LameActivityResultCallback;
import com.adobe.air.LameStateChangeCallback;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.fre.FREContext;

import java.io.PrintWriter;
import java.io.StringWriter;

public abstract class OpenaneContext extends FREContext implements LameActivityResultCallback,
        LameStateChangeCallback {

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

    @Override
    public void dispose() {
        Log.i(this.getClass().getName(), "dispose");
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
