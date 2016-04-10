package openane.weibo;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class WeiboFuncInit implements FREFunction {
    private static final String TAG = WeiboFuncInit.class.getName();
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        WeiboContext context = (WeiboContext) freContext;
        try {
            String appKey = freObjects[0].getAsString();
            String redirectUrl = freObjects[1].getAsString();
            String scope = freObjects[2].getAsString();

            Log.d(TAG, "appKey=" + appKey + " redirectUrl=" + redirectUrl + " scope=" + scope);
            context.init(appKey, redirectUrl, scope);

            return FREObject.newObject(true);
        } catch (Exception e) {
            e.printStackTrace();
            context.print(e);
        }
        return null;
    }
}
