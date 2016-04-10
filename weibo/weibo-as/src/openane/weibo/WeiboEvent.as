package openane.weibo {

import flash.events.Event;

public class WeiboEvent extends Event {
    public static const AUTHORIZATION_COMPLETE:String = "authorizationComplete";
    public static const AUTHORIZATION_CANCEL:String = "authorizationCancel";
    public static const AUTHORIZATION_FAIL:String = "authorizationFail";

    private var _data:Object;

    public function WeiboEvent(type:String, data:Object = null) {
        super(type, bubbles, cancelable);

        _data = data;
    }

    public function get data():Object {
        return _data;
    }

    override public function clone():Event {
        return new WeiboEvent(type);
    }
}
}
