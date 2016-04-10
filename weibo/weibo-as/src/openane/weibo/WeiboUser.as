package openane.weibo {
public class WeiboUser {
    public var id:String;
    public var screenName:String;
    public var name:String;
    public var province:String;
    public var city:String;
    public var location:String;
    public var description:String;
    public var url:String;
    public var profileImageURL:String;
    public var coverImagePhone:String;
    public var profileURL:String;
    public var gender:String;
    public var following:Boolean;
    public var avatarLarge:String;
    public var avatarHD:String;
    public var followMe:String;
    public var lang:String;

    public function toString():String {
        return JSON.stringify(this);
    }
}
}
