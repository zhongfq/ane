package openane.wechat;

import android.app.Activity;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

public class WeChatFuncInit implements FREFunction {

    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        final WeChatContext context = (WeChatContext) freContext;
        final Activity activity = context.getActivity();
        try {
            String appID = args[0].getAsString();
            String appSecret = args[1].getAsString();

            WeChat.APP_ID = appID;
            WeChat.APP_SECRET = appSecret;

            context.print("init app id: " + WeChat.APP_ID);

            // register app id
            final IWXAPI wx = WXAPIFactory.createWXAPI(activity.getApplicationContext(), null);
            wx.registerApp(appID);
        } catch (Exception e) {
            context.print(e);
        }

        return null;
    }
}
