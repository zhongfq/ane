package openane.tencent {
public class TencentAuthToken {
    private var _accessToken:String;
    private var _expiresTime:Number;
    private var _openid:String;

    public function TencentAuthToken(accessToken:String, openid:String, expiresTime:Number) {
        _accessToken = accessToken;
        _openid = openid;
        _expiresTime = expiresTime;
    }

    public function get accessToken():String {
        return _accessToken;
    }

    public function get expiresTime():Number {
        return _expiresTime;
    }

    public function get openid():String {
        return _openid;
    }

    public function toString():String {
        return JSON.stringify(this);
    }
}
}
