package openane.wechat;

import android.os.Handler;
import android.os.Message;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.modelpay.PayResp;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import org.json.JSONObject;

public class WeChatFuncPay implements FREFunction {

    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        final WeChatContext context = (WeChatContext) freContext;

        try {
            final PayReq req = new PayReq();
            req.appId = WeChat.APP_ID;
            req.partnerId = args[0].getAsString();
            req.prepayId = args[1].getAsString();
            req.nonceStr = args[2].getAsString();
            req.timeStamp = args[3].getAsString();
            req.packageValue = args[4].getAsString();
            req.sign = args[5].getAsString();
            req.extData = args[6].getAsString();

            if (req.extData.length() == 0)
                req.extData = null;

            context.print("pay: appId=" + req.appId + "&" +
                    "partnerId=" + req.partnerId + "&" +
                    "prepayId=" + req.prepayId + "&" +
                    "nonceStr=" + req.nonceStr + "&" +
                    "timeStamp=" + req.timeStamp + "&" +
                    "packageValue=" + req.packageValue + "&" +
                    "sign=" + req.sign);

            WeChat.notifyPayResponse = new PayHandler(context, req);
            IWXAPI api = WXAPIFactory.createWXAPI(context.getActivity(), WeChat.APP_ID);
            api.sendReq(req);
        } catch (Exception e) {
            context.print(e);
        }

        return null;
    }

    private static class PayHandler extends Handler {

        private WeChatContext _context;
        private PayReq _req;

        public PayHandler(WeChatContext context, PayReq req) {
            _context = context;
            _req = req;
        }

        @Override
        public void handleMessage(Message msg) {
            PayResp resp = (PayResp) msg.obj;
            try {
                JSONObject data = new JSONObject();
                data.put("errCode", resp.errCode);
                data.put("returnKey", resp.returnKey);
                _context.dispatchStatusEventAsync("pay", data.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}