package openane.wechat;

import android.util.Log;
import com.adobe.fre.FREFunction;
import openane.wechat.core.OpenaneContext;

import java.util.HashMap;
import java.util.Map;

public class WeChatContext extends OpenaneContext {

    private static final String TAG = WeChatContext.class.getName();

    @Override
    public Map<String, FREFunction> getFunctions() {
        Log.i(TAG, "getFunctions");

        HashMap<String, FREFunction> functionMap = new HashMap<>();
        functionMap.put("init", new WeChatFuncInit());
        functionMap.put("pay", new WeChatFuncPay());
        functionMap.put("isInstalled", new WeChatFuncIsInstalled());
        functionMap.put("authorize", new WeChatFuncAuthorize());
        functionMap.put("handleOpenURL", new WeChatFuncHandleOpenURL());

        return functionMap;
    }
}
