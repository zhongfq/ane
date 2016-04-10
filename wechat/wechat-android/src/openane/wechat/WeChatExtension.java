package openane.wechat;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class WeChatExtension implements FREExtension {

    private static final String TAG = WeChatExtension.class.getName();

    @Override
    public void initialize() {
        Log.i(TAG, "initialize");
    }

    @Override
    public FREContext createContext(String s) {
        Log.i(TAG, "createContext");
        return new WeChatContext();
    }

    @Override
    public void dispose() {
        Log.i(TAG, "dispose");
    }
}
