package openane.alipay {

import flash.events.Event;

public class AlipayEvent extends Event {
    public static const PURCHASE_SUCCESS:String = "purchaseSuccess";
    public static const PURCHASE_CANCEL:String = "purchaseCancel";
    public static const PURCHASE_FAIL:String = "purchaseFail";
    public static const PURCHASE_SIGNED_INFO_COMPLETE:String = "purchaseSignedInfoComplete";

    private var _resultStatus:String;
    private var _result:String;
    private var _verified:Boolean;

    public function AlipayEvent(type:String, verified:Boolean, resultStatus:String,
                                result:String) {
        super(type);

        _verified = verified;
        _resultStatus = resultStatus;
        _result = result;
    }

    public function get resultStatus():String {
        return _resultStatus;
    }

    public function get result():String {
        return _result;
    }

    public function get verified():Boolean {
        return _verified;
    }

    override public function clone():Event {
        return new AlipayEvent(type, _verified, _result, _resultStatus);
    }
}
}