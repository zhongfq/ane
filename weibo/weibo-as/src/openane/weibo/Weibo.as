package openane.weibo {

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.InvokeEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.utils.getQualifiedClassName;

[Event(name="authorizationComplete", type="openane.weibo.WeiboEvent")]
[Event(name="authorizationCancel", type="openane.weibo.WeiboEvent")]
[Event(name="authorizationFail", type="openane.weibo.WeiboEvent")]
public class Weibo extends EventDispatcher {
    private static const DEFAULT_REDIRECT_URL:String = "https://api.weibo.com/oauth2/default.html";
    private static const STATUS_CODE_OK:int = 0;
    private static const STATUS_CODE_CANCEL:int = -1;
    private static const STATUS_CODE_FAIL:int = -3;
    private static var _defaultInstance:Weibo;

    public static function get defaultInstance():Weibo {
        return _defaultInstance ||= new Weibo();
    }

    private var _context:ExtensionContext;
    private var _token:WeiboAuthToken;
    private var _urlScheme:String;

    public function Weibo() {
        if (_defaultInstance) {
            throw new Error(format("use %s.defaultInstance", getQualifiedClassName(Weibo)));
        }

        if (Capabilities.os.search(/Linux|iPhone/) >= 0) {
            _context = ExtensionContext.createExtensionContext("openane.weibo.Weibo", "");
            _context.addEventListener(StatusEvent.STATUS, statusHandler);
            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
        } else {
            print("unsupported platform '%s'", Capabilities.os);
        }
    }

    private function print(...args):void {
        trace("[Weibo] " + format.apply(null, args));
    }

    private function invokeHandler(event:InvokeEvent):void {
        var url:String = event.arguments.length > 0 ? event.arguments[0] : null;
        if (url && _urlScheme && url.indexOf(_urlScheme) >= 0) {
            _context.call("handleOpenURL", event.arguments[0]);
        }
    }

    private function statusHandler(event:StatusEvent):void {
        switch (event.code) {
            case "print":
                print("%s", event.level);
                break;
            case "authorize":
                var info:Object = JSON.parse(event.level);
                var status:int = info['status_code'];
                if (status == STATUS_CODE_OK) {
                    _token = new WeiboAuthToken(info['uid'], info['access_token'],
                            info['expires_in'], info['refresh_token']);
                    requestUserInfo();
                } else if (status == STATUS_CODE_CANCEL) {
                    dispatchEvent(new WeiboEvent(WeiboEvent.AUTHORIZATION_CANCEL));
                } else {
                    dispatchEvent(new WeiboEvent(WeiboEvent.AUTHORIZATION_FAIL));
                }
                break;
        }
    }

    public function get token():WeiboAuthToken {
        return _token;
    }

    public function init(appKey:String, scope:String = WeiboAuthScope.ALL,
                         redirectURL:String = DEFAULT_REDIRECT_URL):void {
        if (_context) {
            if (appKey && redirectURL != null && scope != null) {
                _urlScheme = format("wb%s://", appKey);
                _context.call("init", appKey, redirectURL, scope);
            } else {
                print("arguments error: appKey=%s, scope=%s, redirectURL=%s",
                        appKey, scope, redirectURL);
            }
        }
    }

    public function authorize():void {
        if (_context) {
            _context.call("authorize");
        }
    }

    private function requestUserInfo():void {
        var url:String = format("https://api.weibo.com/2/users/show.json" +
                "?access_token=%s&uid=%s", _token.accessToken, _token.uid);
        var loader:URLLoader = new URLLoader(new URLRequest(url));
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var info:Object = JSON.parse(event.target.data);
            var user:WeiboUser = new WeiboUser();
            user.id = String(info["id"]);
            user.screenName = info["screen_name"];
            user.name = info["name"];
            user.province = info["province"];
            user.city = info["city"];
            user.location = info["location"];
            user.description = info["description"];
            user.url = info["url"];
            user.profileImageURL = info["profile_image_url"];
            user.coverImagePhone = info["cover_image_phone"];
            user.profileURL = info["profile_url"];
            user.gender = info["gender"];
            user.following = info["following"];
            user.avatarLarge = info["avatar_large"];
            user.avatarHD = info["avatar_hd"];
            user.followMe = info["follow_me"];
            user.lang = info["lang"];
            dispatchEvent(new WeiboEvent(WeiboEvent.AUTHORIZATION_COMPLETE, user));
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
            dispatchEvent(new WeiboEvent(WeiboEvent.AUTHORIZATION_FAIL));
        });
    }
}
}
