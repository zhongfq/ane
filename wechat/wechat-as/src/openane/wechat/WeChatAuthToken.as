package openane.wechat {
public class WeChatAuthToken {
    private var _openid:String;
    private var _scope:String;
    private var _unionid:String;
    private var _accessToken:String;
    private var _expiresTime:Number;
    private var _refreshToken:String;

    public function WeChatAuthToken(openid:String, unionid:String, accessToken:String,
                                    expiresTime:Number, refreshToken:String) {
        _openid = openid;
        _unionid = unionid;
        _scope = scope;
        _accessToken = accessToken;
        _expiresTime = expiresTime;
        _refreshToken = refreshToken;
    }

    public function get openid():String {
        return _openid;
    }

    public function get unionid():String {
        return _unionid;
    }

    public function get scope():String {
        return _scope;
    }

    public function get accessToken():String {
        return _accessToken;
    }

    public function get expiresTime():Number {
        return _expiresTime;
    }

    public function get refreshToken():String {
        return _refreshToken;
    }

    public function toString():String {
        return JSON.stringify(this);
    }
}
}
