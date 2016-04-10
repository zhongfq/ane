package openane.tencent {
import flash.events.Event;

public class TencentEvent extends Event {
    public static const AUTHORIZATION_COMPLETE:String = "authorizationComplete";
    public static const AUTHORIZATION_CANCEL:String = "authorizationCancel";
    public static const AUTHORIZATION_FAIL:String = "authorizationFail";

    private var _data:Object;

    public function TencentEvent(type:String, data:Object) {
        super(type);

        _data = data;
    }

    public function get data():Object {
        return _data;
    }

    override public function clone():Event {
        return new TencentEvent(type, _data);
    }
}
}