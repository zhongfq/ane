package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import openane.tencent.Tencent;
import openane.tencent.TencentEvent;

public class Main extends Sprite {
    public function Main() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        var btn:Sprite = createButton("authorize", 100, 100, 120, 30);
        btn.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
            tencent.authorize();
        });
        addChild(btn);

        var tencent:Tencent = Tencent.defaultInstance;
        tencent.init("??????");
        tencent.addEventListener(TencentEvent.AUTHORIZATION_CANCEL, handler);
        tencent.addEventListener(TencentEvent.AUTHORIZATION_FAIL, handler);
        tencent.addEventListener(TencentEvent.AUTHORIZATION_COMPLETE, handler);
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

    private function handler(event:TencentEvent):void {
        trace(event.type, event.data);
    }
}
}
