package openane.lame;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class LameExtension implements FREExtension {
    private static final String TAG = LameExtension.class.getName();

    @Override
    public FREContext createContext(String s) {
        Log.i(TAG, "createContext");
        return new LameContext();
    }

    @Override
    public void initialize() {
        Log.i(TAG, "initialize");
    }

    @Override
    public void dispose() {
        Log.i(TAG, "dispose");
    }
}
