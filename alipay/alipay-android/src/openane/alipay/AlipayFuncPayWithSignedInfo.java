package openane.alipay;

import android.app.Activity;
import android.os.Message;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.alipay.sdk.app.PayTask;

public class AlipayFuncPayWithSignedInfo implements FREFunction {

    @Override
    public FREObject call(FREContext freContext, FREObject[] args) {
        AlipayContext context = (AlipayContext) freContext;

        final String signedInfo = AlipayUtil.objectToString(args[0]);
        final Activity activity = context.getActivity();
        final AlipayPayHandler handler = new AlipayPayHandler(context);

        context.print("payWithSignedInfo: " + signedInfo);

        new Thread(new Runnable() {
            @Override
            public void run() {
                PayTask payTask = new PayTask(activity);
                String result = payTask.pay(signedInfo);

                // send result to alipay context
                Message msg = new Message();
                msg.what = AlipayPayHandler.PAY_WITH_SIGNED_INFO;
                msg.obj = result;
                handler.sendMessage(msg);
            }
        }).start();

        return null;
    }
}
