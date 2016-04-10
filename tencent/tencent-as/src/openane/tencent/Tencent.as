package openane.tencent {
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

[Event(name="authorizationComplete", type="openane.tencent.TencentEvent")]
[Event(name="authorizationCancel", type="openane.tencent.TencentEvent")]
[Event(name="authorizationFail", type="openane.tencent.TencentEvent")]
public class Tencent extends EventDispatcher {
    private static const STATUS_CODE_OK:int = 0;
    private static const STATUS_CODE_CANCEL:int = -1;
    private static const STATUS_CODE_FAIL:int = -2;

    private static var _defaultInstance:Tencent;

    public static function get defaultInstance():Tencent {
        return _defaultInstance ||= new Tencent();
    }

    private var _context:ExtensionContext;
    private var _urlScheme:String;
    private var _appid:String;
    private var _token:TencentAuthToken;

    public function Tencent() {
        if (_defaultInstance) {
            throw new Error(format("use %s.defaultInstance", getQualifiedClassName(Tencent)));
        }

        if (Capabilities.os.search(/Linux|iPhone/) >= 0) {
            _context = ExtensionContext.createExtensionContext("openane.tencent.Tencent", "");
            _context.addEventListener(StatusEvent.STATUS, statusHandler);
            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
        } else {
            print("unsupported platform '%s'", Capabilities.os);
        }
    }

    private function print(...args):void {
        trace("[Tencent] " + format.apply(null, args));
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
                    _token = new TencentAuthToken(info['access_token'], info['openid'],
                            info['expires_in']);
                    requestUserInfo();
                } else if (status == STATUS_CODE_CANCEL) {
                    dispatchEvent(new TencentEvent(TencentEvent.AUTHORIZATION_CANCEL, null));
                } else {
                    dispatchEvent(new TencentEvent(TencentEvent.AUTHORIZATION_FAIL, null));
                }
        }
    }

    public function get token():TencentAuthToken {
        return _token;
    }

    public function init(appid:String):void {
        if (_context) {
            if (appid) {
                _appid = appid;
                _urlScheme = format("tencent%s://", appid);
                _context.call("init", appid);
            } else {
                print("init error: appid=%s", appid);
            }
        }
    }

    public function authorize(scope:String = TencentAuthScope.DEFAULT):void {
        if (_context) {
            _context.call("authorize", scope || TencentAuthScope.DEFAULT);
        }
    }

    private function requestUserInfo():void {
        var url:String = format('https://graph.qq.com/user/get_simple_userinfo' +
                '?access_token=%s&oauth_consumer_key=%s&openid=%s',
                _token.accessToken, _appid, _token.openid);
        var loader:URLLoader = new URLLoader(new URLRequest(url));
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var info:Object = JSON.parse(event.target.data);
            var user:TencentUser = new TencentUser();
            user.openid = _token.openid;
            user.msg = info['msg'];
            user.isLost = info['is_lost'];
            user.nickname = info['nickname'];
            user.gender = info['gender'];
            user.province = info['province'];
            user.city = info['city'];
            user.figureurl = info['figureurl'];
            user.figureurl1 = info['figureurl_1'];
            user.figureurl2 = info['figureurl_2'];
            user.figureurlQQ1 = info['figureurl_qq_1'];
            user.figureurlQQ2 = info['figureurl_qq_2'];
            user.isYellowVIP = info['is_yellow_vip'];
            user.vip = info['vip'];
            user.yellowVIPLevel = info['yellow_vip_level'];
            user.level = info['level'];
            user.isYellowYearVIP = info['is_yellow_year_vip'];
            dispatchEvent(new TencentEvent(TencentEvent.AUTHORIZATION_COMPLETE, user));
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
            dispatchEvent(new TencentEvent(TencentEvent.AUTHORIZATION_FAIL, null));
        });
    }
}
}
