package openane.weibo {
public class WeiboAuthToken {
    private var _uid:String;
    private var _accessToken:String;
    private var _expiresTime:Number;
    private var _refreshToken:String;

    public function WeiboAuthToken(uid:String, accessToken:String, expiresTime:Number,
                                   refreshToken:String) {
        _uid = uid;
        _accessToken = accessToken;
        _expiresTime = expiresTime;
        _refreshToken = refreshToken;
    }

    public function get uid():String {
        return _uid;
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
