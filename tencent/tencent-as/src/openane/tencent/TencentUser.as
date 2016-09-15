package openane.tencent {
public class TencentUser {
    public var openid:String;
    public var msg:String;
    public var isLost:int;
    public var nickname:String;
    public var gender:String;
    public var province:String;
    public var city:String;
    public var figureurl:String;
    public var figureurl1:String;
    public var figureurl2:String;
    public var figureurlQQ1:String;
    public var figureurlQQ2:String;
    public var isYellowVIP:String;
    public var vip:String;
    public var yellowVIPLevel:String;
    public var level:String;
    public var isYellowYearVIP:String;

    public function toString():String {
        return JSON.stringify(this);
    }
}
}
