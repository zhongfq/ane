package openane.wechat {
public class WeChatUser {
    public var openid:String;
    public var nickname:String;
    public var sex:int;
    public var language:String;
    public var city:String;
    public var province:String;
    public var country:String;
    public var headimgurl:String;
    public var privilege:String;
    public var unionid:String;

    public function toString():String {
        return JSON.stringify(this);
    }
}
}
