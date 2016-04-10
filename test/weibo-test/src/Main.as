package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import openane.weibo.Weibo;
import openane.weibo.WeiboEvent;

public class Main extends Sprite {
    public function Main() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        var btn:Sprite = createButton("authorize", 100, 100, 120, 30);
        btn.addEventListener(MouseEvent.CLICK, clickHandler);
        addChild(btn);

        Weibo.defaultInstance.init("1849722642");
        Weibo.defaultInstance.addEventListener(WeiboEvent.AUTHORIZATION_CANCEL, cancelHandler);
        Weibo.defaultInstance.addEventListener(WeiboEvent.AUTHORIZATION_COMPLETE, completeHandler);
        Weibo.defaultInstance.addEventListener(WeiboEvent.AUTHORIZATION_FAIL, errorHandler);
    }

    private function createButton(label:String, x:int, y:int, w:int, h:int):Sprite {
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

    private function clickHandler(event:MouseEvent):void {
        trace("authorize");
        Weibo.defaultInstance.authorize();
    }

    private function cancelHandler(event:WeiboEvent):void {
        trace(event);
    }

    private function completeHandler(event:WeiboEvent):void {
        trace("complete", event.data);
    }

    private function errorHandler(event:WeiboEvent):void {
        trace(event);
    }
}
}
