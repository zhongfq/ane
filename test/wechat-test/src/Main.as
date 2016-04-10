package
{
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import openane.wechat.WeChat;
import openane.wechat.WeChatEvent;

public class Main extends Sprite
{
    public function Main()
    {
        var btn:Sprite = createButton("test pay", 100, 100, 120, 30);
        btn.addEventListener(MouseEvent.CLICK, clickHandler);
        addChild(btn);

        btn = createButton("test auth", 100, 200, 120, 30);
        btn.addEventListener(MouseEvent.CLICK, function(_:*):void {
            wechat.authorize("snsapi_userinfo", "xxxx");
        });
        addChild(btn);

        var wechat:WeChat = WeChat.defaultInstance;
        wechat.init("wx??????", "wxsecret");
        trace(wechat.isInstalled());
        wechat.addEventListener(WeChatEvent.PURCHASE_CANCEL, handler);
        wechat.addEventListener(WeChatEvent.PURCHASE_FAIL, handler);
        wechat.addEventListener(WeChatEvent.PURCHASE_SUCCESS, handler);
        wechat.addEventListener(WeChatEvent.AUTHORIZATION_CANCEL, handler);
        wechat.addEventListener(WeChatEvent.AUTHORIZATION_COMPLETE, handler);
        wechat.addEventListener(WeChatEvent.AUTHORIZATION_FAIL, handler);
    }

    protected function handler(event:WeChatEvent):void
    {
        trace(event.type, event.data);
    }

    private function clickHandler(event:MouseEvent):void
    {
        var obj:Object = JSON.parse('');
        WeChat.defaultInstance.pay(obj.partnerid,
                obj.prepayid,
                obj.noncestr,
                obj.timestamp,
                obj['package'],
                obj.sign
        );
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