package openane.wechat;

import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import openane.openane.OpenaneUtil;
import org.json.JSONObject;

public class WeChatFuncAuthorize implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        final WeChatContext context = (WeChatContext) freContext;
        final SendAuth.Req req = new SendAuth.Req();
        req.scope = OpenaneUtil.objectToString(freObjects[0]);
        req.state = OpenaneUtil.objectToString(freObjects[1]);

        WeChat.notifyRespose = new AuthorizeHandler(context, req);
        IWXAPI api = WXAPIFactory.createWXAPI(context.getActivity(), WeChat.APP_ID);
        api.sendReq(req);

        context.print("authorize: scope=" + req.scope);

        return null;
    }

    private static class AuthorizeHandler extends Handler {
        private WeChatContext _context;
        private BaseReq _req;

        public AuthorizeHandler(WeChatContext context, BaseReq req) {
            _context = context;
            _req = req;
        }

        @Override
        public void handleMessage(Message msg) {
            BaseResp baseResp = (BaseResp) msg.obj;
            if (baseResp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
                SendAuth.Resp authResp = (SendAuth.Resp) baseResp;
                try {
                    JSONObject data = new JSONObject();
                    data.put("errCode", authResp.errCode);
                    data.put("code", authResp.code);
                    data.put("state", authResp.state);
                    data.put("lang", authResp.lang);
                    data.put("country", authResp.country);
                    _context.dispatchStatusEventAsync("authorize", data.toString());
                } catch (Exception e) {
                    e.printStackTrace();
                    _context.dispatchStatusEventAsync("authorize", "{}");
                }
            } else {
                _context.dispatchStatusEventAsync("print", "unhandle type: " + baseResp.getType());
            }
        }
    }
}
