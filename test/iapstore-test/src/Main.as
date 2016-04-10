package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import openane.iapstore.IAPStore;
import openane.iapstore.IAPStoreProductEvent;
import openane.iapstore.IAPStoreTransactionEvent;

public class Main extends Sprite {

    private var _iapstore:IAPStore = IAPStore.defaultInstance;

    public function Main() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        var ids:Vector.<String> = new Vector.<String>();
        ids.push("id", "test");
        trace("can make payment: ", _iapstore.canMakePayments());
        _iapstore.requestProducts(ids);
        _iapstore.addEventListener(IAPStoreProductEvent.PRODUCT_DETAILS_FAIL, detailsFail);
        _iapstore.addEventListener(IAPStoreProductEvent.PRODUCT_DETAILS_INVALID, detailsInvalid);
        _iapstore.addEventListener(IAPStoreProductEvent.PRODUCT_DETAILS_SUCCESS, detailSuccess);
        _iapstore.addEventListener(IAPStoreTransactionEvent.FINISH_TRANSACTION_SUCCESS, finishTransaction);
        _iapstore.addEventListener(IAPStoreTransactionEvent.PURCHASE_TRANSACTION_CANCEL, purchaseCancel);
        _iapstore.addEventListener(IAPStoreTransactionEvent.PURCHASE_TRANSACTION_FAIL, purchaseFail);
        _iapstore.addEventListener(IAPStoreTransactionEvent.PURCHASE_TRANSACTION_SUCCESS, purchaseSuccess);
        _iapstore.addEventListener(IAPStoreTransactionEvent.RESTORE_TRANSACTION_COMPLETE, restoreComplete);
        _iapstore.addEventListener(IAPStoreTransactionEvent.RESTORE_TRANSACTION_FAIL, restoreFail);
        _iapstore.addEventListener(IAPStoreTransactionEvent.RESTORE_TRANSACTION_SUCCESS, restoreSuccess);

        createButton("pay", 100, 100, 120, 30).addEventListener(MouseEvent.CLICK, function(_:*):void {
            //_iapstore.purchase("id");
        });

        createButton("restore", 100, 200, 120, 30).addEventListener(MouseEvent.CLICK, function(_:*):void {
            _iapstore.restoreCompletedTransactions();
        });

        createButton("finish", 100, 300, 120, 30).addEventListener(MouseEvent.CLICK, function(_:*):void {
            //_iapstore.finishTransaction("id");
        });

        createButton("pending", 100, 400, 120, 30).addEventListener(MouseEvent.CLICK, function(_:*):void {
            trace(_iapstore.pendingTransactions);
        });
    }

    private function detailsFail(event:IAPStoreProductEvent):void {
        trace(event.type, event.error);
    }

    private function detailsInvalid(event:IAPStoreProductEvent):void {
        trace(event.type, event.invalidIdentifiers);
    }

    private function detailSuccess(event:IAPStoreProductEvent):void {
        trace(event.type, event.products);
    }

    private function finishTransaction(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
    }

    private function purchaseCancel(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
    }

    private function purchaseFail(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
    }

    private function purchaseSuccess(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
    }

    private function restoreComplete(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
    }

    private function restoreFail(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
    }

    private function restoreSuccess(event:IAPStoreTransactionEvent):void {
        trace(event.type, event.transactions);
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

        addChild(btn);

        return btn;
    }
}
}
