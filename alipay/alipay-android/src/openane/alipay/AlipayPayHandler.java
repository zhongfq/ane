package openane.alipay;

import android.os.Handler;
import android.os.Message;

public class AlipayPayHandler extends Handler {
    public static final int PAY = 1;
    public static final int PAY_WITH_SIGNED_INFO = 2;

    private AlipayContext _context;

    public AlipayPayHandler(AlipayContext context) {
        _context = context;
    }

    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
            case PAY: {
                AlipayResult result = new AlipayResult((String) msg.obj);
                boolean ok = AlipayUtil.verifyResult(result, _context.publicKey);
                _context.dispatchStatusEventAsync("pay", AlipayUtil.appendVerifyStatus(result, ok));
                break;
            }
            case PAY_WITH_SIGNED_INFO: {
                AlipayResult result = new AlipayResult((String) msg.obj);
                _context.dispatchStatusEventAsync("payWithSignedInfo",
                        AlipayUtil.appendVerifyStatus(result, false));
                break;
            }
        }
    }
}
