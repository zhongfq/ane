package openane.alipay;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class AlipayExtension implements FREExtension {
    private static final String TAG = AlipayExtension.class.getName();

    @Override
    public FREContext createContext(String s) {
        Log.i(TAG, "createContext");
        return new AlipayContext();
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
