package openane.weibo;

import android.content.Intent;
import com.adobe.fre.FREFunction;
import com.sina.weibo.sdk.auth.AuthInfo;
import com.sina.weibo.sdk.auth.Oauth2AccessToken;
import com.sina.weibo.sdk.auth.WeiboAuthListener;
import com.sina.weibo.sdk.auth.sso.SsoHandler;
import openane.weibo.core.OpenaneContext;

import java.util.HashMap;
import java.util.Map;

public class WeiboContext extends OpenaneContext {
    private static final String TAG = WeiboContext.class.getName();

    private Oauth2AccessToken _accessToken;
    private SsoHandler _ssoHandler;

    @Override
    public Map<String, FREFunction> getFunctions() {
        HashMap<String, FREFunction> map = new HashMap<>();
        map.put("init", new WeiboFuncInit());
        map.put("authorize", new WeiboFuncAuthorize());
        map.put("handleOpenURL", new WeiboFuncHandleOpenURL());
        return map;
    }

    public void init(String appKey, String redirectUrl, String scope) {
        _ssoHandler = new SsoHandler(getActivity(), new AuthInfo(getActivity(), appKey,
                redirectUrl, scope));
    }

    public void authorize(WeiboAuthListener listener) {
        _ssoHandler.authorize(listener);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (_ssoHandler != null)
            _ssoHandler.authorizeCallBack(requestCode, resultCode, data);
    }

    public Oauth2AccessToken getAccessToken() {
        return _accessToken;
    }

    public void setAccessToken(Oauth2AccessToken accessToken) {
        _accessToken = accessToken;
    }
}
