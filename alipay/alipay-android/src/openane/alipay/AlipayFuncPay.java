package openane.alipay;

import android.app.Activity;
import android.os.Message;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.alipay.sdk.app.PayTask;

public class AlipayFuncPay implements FREFunction {

    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        AlipayContext context = (AlipayContext) freContext;

        if (context.privateKey == null) {
            context.print("private key is null or empty");
        } else {
            String info = AlipayUtil.objectToString(args[0]);
            String sign = RSA.sign(info, context.privateKey);
            if (sign == null) {
                context.print("pay: sign error");
            } else {
                final String signedInfo = info + "&sign=\"" + sign + "\"&sign_type=\"RSA\"";
                context.print("pay: " + signedInfo);

                final Activity activity = context.getActivity();
                final AlipayPayHandler handler = new AlipayPayHandler(context);
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        PayTask payTask = new PayTask(activity);
                        String result = payTask.pay(signedInfo);

                        // send result to alipay context
                        Message msg = new Message();
                        msg.what = AlipayPayHandler.PAY;
                        msg.obj = result;
                        handler.sendMessage(msg);
                    }
                }).start();
            }
        }

        return null;
    }
}
