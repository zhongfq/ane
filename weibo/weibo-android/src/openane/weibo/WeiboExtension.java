package openane.weibo;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class WeiboExtension implements FREExtension {
    private static final String TAG = WeiboExtension.class.getName();

    @Override
    public void initialize() {
    }

    @Override
    public FREContext createContext(String s) {
        Log.d(TAG, "create context: " + s);
        return new WeiboContext();
    }

    @Override
    public void dispose() {

    }
}
