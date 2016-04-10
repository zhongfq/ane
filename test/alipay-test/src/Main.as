package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import openane.alipay.Alipay;
import openane.alipay.AlipayEvent;
import openane.alipay.AlipayOrder;

public class Main extends Sprite {
    private var _alipay:Alipay;

    public function Main()
    {
        var btn:Sprite = createButton("pay", 100, 100, 120, 30);
        btn.addEventListener(MouseEvent.CLICK, function(_:*):void {
            var order:AlipayOrder = new AlipayOrder();
            order.productID = int(new Date().getTime() / 1000).toString();
            order.productName = "测试";
            order.productDescription = "这是一个测试商品";
            order.productPrice = "0.01";
            order.partner = "";
            order.seller = "";
            order.notifyURL = "http://notify.msp.hk/notify.htm";
            _alipay.pay(order);
        });
        addChild(btn);

        btn = createButton("payWithSignedInfo", 100, 200, 120, 30);
        btn.addEventListener(MouseEvent.CLICK, function(_:*):void {
            _alipay.payWithSignedInfo('');
        });
        addChild(btn);

        _alipay = new Alipay();

        _alipay.init("app key", "public key", "private key")

        _alipay.addEventListener(AlipayEvent.PURCHASE_CANCEL, handler);
        _alipay.addEventListener(AlipayEvent.PURCHASE_FAIL, handler);
        _alipay.addEventListener(AlipayEvent.PURCHASE_SUCCESS, handler);
        _alipay.addEventListener(AlipayEvent.PURCHASE_SIGNED_INFO_COMPLETE, handler);
    }

    protected function handler(event:AlipayEvent):void
    {
        trace(event.type, event.verified, event.resultStatus, event.result);
    }

    private function statusHandler(event:StatusEvent):void
    {
        trace(event.level, event.code);
    }

    private function createButton(label:String, x:int, y:int, w:int, h:int):Sprite
    {
        var btn:Sprite = new Sprite();
        btn.mouseChildren = false;
        btn.x = x;
        btn.y = y;

        btn.graphics.beginFill(0xCCCCCC);
        btn.graphics.drawRect(0, 0, w, h);
        btn.graphics.endFill();

        var tf:TextField = new TextField();
        tf.text = label;
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.x = (w - tf.textWidth) / 2;
        tf.y = (h - tf.textHeight) / 2;
        btn.addChild(tf);

        return btn;
    }
}
}
