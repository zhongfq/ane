package openane.wechat {

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

[Event(name="purchaseSuccess", type="openane.wechat.WeChatEvent")]
[Event(name="purchaseCancel", type="openane.wechat.WeChatEvent")]
[Event(name="purchaseFail", type="openane.wechat.WeChatEvent")]
[Event(name="authorizationComplete", type="openane.wechat.WeChatEvent")]
[Event(name="authorizationCancel", type="openane.wechat.WeChatEvent")]
[Event(name="authorizationFail", type="openane.wechat.WeChatEvent")]
public class WeChat extends EventDispatcher {
    /** 成功 */
    private static const WXSUCCESS:int = 0;
    /** 普通错误类型 */
    private static const WXERRCODE_COMMON:int = -1;
    /** 用户点击取消并返回 */
    private static const WXERRCODE_USER_CANCEL:int = -2;
    /** 发送失败 */
    private static const WXERRCODE_SENT_FAIL:int = -3;
    /** 授权失败 */
    private static const WXERRCODE_AUTH_DENY:int = -4;
    /** 微信不支持 */
    private static const WXERRCODE_UNSUPPORT:int = -5;

    private static var _defaultInstance:WeChat;

    public static function get defaultInstance():WeChat {
        return _defaultInstance ||= new WeChat();
    }

    private var _context:ExtensionContext;
    private var _appSecret:String;
    private var _appid:String;
    private var _token:WeChatAuthToken;
    private var _urlScheme:String;

    public function WeChat() {
        if (_defaultInstance) {
            throw new Error(format("use %s.defaultInstance", getQualifiedClassName(WeChat)));
        }

        if (Capabilities.os.search(/Linux|iPhone/) >= 0) {
            _context = ExtensionContext.createExtensionContext("openane.wechat.WeChat", "");
            _context.addEventListener(StatusEvent.STATUS, statusHandler);
            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
        } else {
            print("unsupported platform '%s'", Capabilities.os);
        }
    }

    private function print(...args):void {
        trace("[WeChat] " + format.apply(null, args));
    }

    private function invokeHandler(event:InvokeEvent):void {
        var url:String = event.arguments.length > 0 ? event.arguments[0] : null;
        if (url && _urlScheme && url.indexOf(_urlScheme) >= 0) {
            _context.call("handleOpenURL", event.arguments[0]);
        }
    }

    public function get token():WeChatAuthToken {
        return _token;
    }

    public function init(appid:String, appSecret:String):void {
        if (_context) {
            if (appid && appSecret) {
                _urlScheme = format("%s://", appid);
                _appid = appid;
                _appSecret = appSecret;
                _context.call("init", appid, appSecret);
            } else {
                print("init error: appid=%s appSecret=%s", appid, appSecret);
            }
        }
    }

    public function isInstalled():Boolean {
        if (_context) {
            return _context.call("isInstalled");
        } else {
            return false;
        }
    }

    public function pay(partnerId:String, prepayId:String, nonceStr:String, timeStamp:String,
                        packageValue:String, sign:String):void {
        if (_context) {
            if (partnerId && prepayId && nonceStr && timeStamp && packageValue && sign) {
                _context.call("pay", partnerId, prepayId, nonceStr, timeStamp, packageValue, sign,
                        "");
            } else {
                print("arguments error: partnerId=%s, prepayId=%s, nonceStr=%s, timeStamp=%s, " +
                        "packageValue=%s, sign=%s",
                        partnerId, prepayId, nonceStr, timeStamp, packageValue, sign);
            }
        }
    }

    public function authorize(scope:String = WeChatAuthScope.SNAAPI_USERINFO,
                              state:String = null):void {
        if (_context) {
            _context.call("authorize", scope, state);
        }
    }

    private function statusHandler(event:StatusEvent):void {
        var data:Object;
        var errCode:int;
        var type:String;

        switch (event.code) {
            case "print":
                print("%s", event.level);
                break;
            case "pay":
                data = JSON.parse(event.level);
                errCode = data.errCode;

                if (errCode == WXSUCCESS) {
                    type = WeChatEvent.PURCHASE_SUCCESS;
                } else if (errCode == WXERRCODE_USER_CANCEL) {
                    type = WeChatEvent.PURCHASE_CANCEL;
                } else {
                    type = WeChatEvent.PURCHASE_FAIL;
                }

                dispatchEvent(new WeChatEvent(type, errCode));
                break;
            case "authorize":
                data = JSON.parse(event.level);
                if (data.errCode == WXSUCCESS) {
                    requestToken(data);
                } else if (data.errCode == WXERRCODE_USER_CANCEL) {
                    dispatchEvent(new WeChatEvent(WeChatEvent.AUTHORIZATION_CANCEL, errCode));
                } else {
                    dispatchEvent(new WeChatEvent(WeChatEvent.AUTHORIZATION_FAIL, errCode));
                }
                break;
        }
    }

    private function requestToken(data:Object):void {
        var url:String = format("https://api.weixin.qq.com/sns/oauth2/access_token" +
                "?appid=%s&secret=%s&code=%s&&grant_type=authorization_code",
                _appid, _appSecret, data.code);
        var loader:URLLoader = new URLLoader(new URLRequest(url));
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var token:Object = JSON.parse(event.target.data);
            _token = new WeChatAuthToken(token['openid'], token['unionid'], token['access_token'],
                    token['expires_int'], token['refresh_token']);
            requestUserInfo();
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
            dispatchEvent(new WeChatEvent(WeChatEvent.AUTHORIZATION_FAIL, WXERRCODE_AUTH_DENY));
        });
    }

    private function requestUserInfo():void {
        var url:String = format("https://api.weixin.qq.com/sns/userinfo" +
                "?access_token=%s&openid=%s", _token.accessToken, _token.openid);
        var loader:URLLoader = new URLLoader(new URLRequest(url));
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var info:Object = JSON.parse(event.target.data);
            var user:WeChatUser = new WeChatUser();
            user.openid = info['openid'];
            user.nickname = info['nickname'];
            user.sex = info['sex'];
            user.language = info['language'];
            user.city = info['city'];
            user.country = info['country'];
            user.province = info['province'];
            user.headimgurl = info['headimgurl'];
            user.privilege = info['privilege'];
            user.unionid = info['unionid'];
            dispatchEvent(new WeChatEvent(WeChatEvent.AUTHORIZATION_COMPLETE, user));
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
            dispatchEvent(new WeChatEvent(WeChatEvent.AUTHORIZATION_FAIL, WXERRCODE_AUTH_DENY));
        });
    }
}
}