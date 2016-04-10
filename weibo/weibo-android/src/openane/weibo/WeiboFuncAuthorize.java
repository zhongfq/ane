package openane.weibo;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.sina.weibo.sdk.auth.Oauth2AccessToken;
import com.sina.weibo.sdk.auth.WeiboAuthListener;
import com.sina.weibo.sdk.exception.WeiboException;

import org.json.JSONException;
import org.json.JSONObject;

public class WeiboFuncAuthorize implements FREFunction {
    private static final String TAG = WeiboFuncAuthorize.class.getName();

    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        final WeiboContext context = (WeiboContext) freContext;
        final Activity activity = context.getActivity();

        context.authorize(new WeiboAuthListener() {
            @Override
            public void onComplete(Bundle bundle) {
                Log.d(TAG, "authorize complete");

                Oauth2AccessToken token = Oauth2AccessToken.parseAccessToken(bundle);
                context.setAccessToken(token);
                context.dispatchStatusEventAsync("authorize", toJsonString(0, token));
            }

            @Override
            public void onCancel() {
                Log.d(TAG, "authorize cancelled");

                Toast.makeText(activity, "授权操作取消", Toast.LENGTH_LONG).show();
                context.dispatchStatusEventAsync("authorize", toJsonString(-1, null));
            }

            @Override
            public void onWeiboException(WeiboException e) {
                Log.d(TAG, "authorize exception");
                e.printStackTrace();

                Toast.makeText(activity, "授权操作异常", Toast.LENGTH_LONG).show();
                context.dispatchStatusEventAsync("authorize", toJsonString(-3, null));
            }

            private String toJsonString(int status, Oauth2AccessToken token) {
                JSONObject obj = new JSONObject();
                try {
                    obj.put("status_code", status);
                    if (token != null) {
                        obj.put("uid", token.getUid());
                        obj.put("access_token", token.getToken());
                        obj.put("expires_in", token.getExpiresTime());
                        obj.put("refresh_token", token.getRefreshToken());
                    }
                } catch (JSONException e) {
                    return "{\"status_code\":-3}";
                }
                return obj.toString();
            }
        });

        return null;
    }
}
