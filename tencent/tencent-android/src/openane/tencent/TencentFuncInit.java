package openane.tencent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.tencent.tauth.Tencent;

public class TencentFuncInit implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        final TencentContext context = (TencentContext) freContext;

        String appid = Util.objectToString(freObjects[0]);
        context.oauth = Tencent.createInstance(appid, context.getActivity());
        context.print("init tencent oauth: appid=" + appid);

        return null;
    }
}
