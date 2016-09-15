package openane.wechat {
import flash.events.Event;

public class WeChatEvent extends Event {
    public static const PURCHASE_SUCCESS:String = "purchaseSuccess";
    public static const PURCHASE_CANCEL:String = "purchaseCancel";
    public static const PURCHASE_FAIL:String = "purchaseFail";
    public static const AUTHORIZATION_COMPLETE:String = "authorizationComplete";
    public static const AUTHORIZATION_CANCEL:String = "authorizationCancel";
    public static const AUTHORIZATION_FAIL:String = "authorizationFail";

    private var _data:Object;

    public function WeChatEvent(type:String, data:Object) {
        super(type);

        _data = data;
    }

    public function get data():Object {
        return _data;
    }

    override public function clone():Event {
        return new WeChatEvent(type, _data);
    }
}
}