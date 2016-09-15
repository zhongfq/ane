package openane.alipay;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class AlipayFuncInit implements FREFunction {
    private static final String TAG = AlipayFuncInit.class.getName();
    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        AlipayContext context = (AlipayContext) freContext;
        context.appID = AlipayUtil.objectToString(args[0]);
        context.publicKey = AlipayUtil.objectToString(args[1]);
        context.privateKey = AlipayUtil.objectToString(args[2]);
        Log.d(TAG, String.format("appID=%s, publicKey=%s, privateKey=%s",
                context.appID, context.publicKey, context.privateKey));
        return null;
    }
}
