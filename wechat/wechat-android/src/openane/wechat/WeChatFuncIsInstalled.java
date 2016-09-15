package openane.wechat;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

public class WeChatFuncIsInstalled implements FREFunction {

    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        WeChatContext context = (WeChatContext) freContext;
        IWXAPI api = WXAPIFactory.createWXAPI(context.getActivity(), WeChat.APP_ID);

        try {
            return FREObject.newObject(api.isWXAppInstalled());
        } catch (FREWrongThreadException e) {
            context.print(e);
        }

        return null;
    }
}
