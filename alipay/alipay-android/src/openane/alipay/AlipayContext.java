package openane.alipay;

import android.util.Log;
import com.adobe.fre.FREFunction;
import openane.alipay.core.OpenaneContext;

import java.util.HashMap;
import java.util.Map;

public class AlipayContext extends OpenaneContext {
    private static final String TAG = AlipayContext.class.getName();

    public String appID;
    public String publicKey;
    public String privateKey;

    @Override
    public Map<String, FREFunction> getFunctions() {
        Log.i(TAG, "getFunctions");

        HashMap<String, FREFunction> functionMap = new HashMap<>();
        functionMap.put("init", new AlipayFuncInit());
        functionMap.put("pay", new AlipayFuncPay());
        functionMap.put("payWithSignedInfo", new AlipayFuncPayWithSignedInfo());
        functionMap.put("handleOpenURL", new AlipayFuncHandleOpenURL());

        return functionMap;
    }
}
