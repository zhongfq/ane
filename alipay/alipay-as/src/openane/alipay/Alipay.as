package openane.alipay {

import flash.desktop.NativeApplication;
import flash.events.EventDispatcher;
import flash.events.InvokeEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;
import flash.utils.getQualifiedClassName;

[Event(name="purchaseSuccess", type="openane.alipay.AlipayEvent")]
[Event(name="purchaseCancel", type="openane.alipay.AlipayEvent")]
[Event(name="purchaseFail", type="openane.alipay.AlipayEvent")]
[Event(name="purchaseSignedInfoComplete", type="openane.alipay.AlipayEvent")]
public class Alipay extends EventDispatcher {
    private static var _defaultInstance:Alipay;

    public static function get defaultInstance():Alipay {
        return _defaultInstance ||= new Alipay();
    }

    private var _context:ExtensionContext;
    private var _urlScheme:String;

    public function Alipay() {
        if (_defaultInstance) {
            throw new Error(format("use %s.defaultInstance", getQualifiedClassName(Alipay)));
        }

        if (Capabilities.os.search(/Linux|iPhone/) >= 0) {
            _context = ExtensionContext.createExtensionContext("openane.alipay.Alipay", "");
            _context.addEventListener(StatusEvent.STATUS, statusHandler);
            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
        } else {
            print("unsupported platform '%s'", Capabilities.os);
        }
    }

    private function print(...args):void {
        trace("[Alipay] " + format.apply(null, args));
    }

    private function invokeHandler(event:InvokeEvent):void {
        var url:String = event.arguments.length > 0 ? event.arguments[0] : null;
        if (url && _urlScheme && url.indexOf(_urlScheme) >= 0) {
            _context.call("handleOpenURL", event.arguments[0]);
        }
    }

    private function statusHandler(event:StatusEvent):void {
        switch (event.code) {
            case "print":
                print("%s", event.level);
                break;
            case "pay":
            case "payWithSignedInfo":
                var info:Object = JSON.parse(event.level);
                var type:String;
                var verifyStatus:Boolean = info.verifyStatus == "true";

                if ((info.resultStatus == "9000" || info.resultStatus == "8000")
                        && (verifyStatus || event.code == "payWithSignedInfo")) {
                    type = event.code == "payWithSignedInfo" ?
                            AlipayEvent.PURCHASE_SIGNED_INFO_COMPLETE :
                            AlipayEvent.PURCHASE_SUCCESS;
                } else if (info.resultStatus == "6001") {
                    type = AlipayEvent.PURCHASE_CANCEL;
                } else {
                    type = AlipayEvent.PURCHASE_FAIL;
                }

                dispatchEvent(new AlipayEvent(type, verifyStatus, info.resultStatus, info.result));
                break;
        }
    }

    private function trim(content:String, prefix:String, suffix:String):String {
        return content.substring(content.indexOf(prefix) + prefix.length,
                content.lastIndexOf(suffix));
    }

    public function init(appKey:String, publicKey:String = null, privateKey:String = null):void {
        if (_context) {
            if (appKey) {
                _urlScheme = format("al%s://", appKey);
                _context.call("init", appKey, publicKey, privateKey);
            } else {
                print("arguments error: appKey=%s", appKey);
            }
        }
    }

    public function pay(order:AlipayOrder):void {
        if (_context) {
            if (order) {
                _context.call("pay", order.toString());
            } else {
                print("arguments error: info=%s", order);
            }
        }
    }

    public function payWithSignedInfo(signedInfo:String):void {
        if (_context) {
            if (signedInfo) {
                _context.call("payWithSignedInfo", signedInfo);
            } else {
                print("arguments error: signedInfo=%s", signedInfo);
            }
        }
    }
}
}