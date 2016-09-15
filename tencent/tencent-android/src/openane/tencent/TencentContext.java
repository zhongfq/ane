package openane.tencent;

import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import com.adobe.fre.FREFunction;
import com.tencent.connect.common.Constants;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;
import openane.tencent.core.OpenaneContext;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class TencentContext extends OpenaneContext implements IUiListener {
    private static final String TAG = TencentContext.class.getName();
    public Tencent oauth;

    @Override
    public Map<String, FREFunction> getFunctions() {
        HashMap<String, FREFunction> map = new HashMap<>();

        map.put("init", new TencentFuncInit());
        map.put("authorize", new TencentFuncAuthorize());

        return map;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult: requestCode=" + requestCode + ", resultCode=" + resultCode);
        if (requestCode == Integer.MAX_VALUE) {
            if (resultCode == 0) {
                String accessToken = data.getStringExtra("access_token");
                String openid = data.getStringExtra("openid");
                String expires = data.getStringExtra("expires_in");

                try {
                    JSONObject obj = new JSONObject();
                    obj.put(Constants.PARAM_ACCESS_TOKEN, accessToken);
                    obj.put(Constants.PARAM_OPEN_ID, openid);
                    obj.put(Constants.PARAM_EXPIRES_IN, expires);
                    onComplete(obj);
                } catch (Exception e) {
                    onError(new UiError(0, null, null));
                }
            } else if (resultCode == -1) {
                onCancel();
            } else {
                onError(new UiError(0, null, null));
            }
        } else if (requestCode == Constants.REQUEST_LOGIN) {
            Tencent.onActivityResultData(requestCode, resultCode, data, this);
        }
    }

    @Override
    public void onComplete(Object o) {
        try {
            JSONObject data = (JSONObject) o;
            String token = data.getString(Constants.PARAM_ACCESS_TOKEN);
            String expires = data.getString(Constants.PARAM_EXPIRES_IN);
            String openId = data.getString(Constants.PARAM_OPEN_ID);
            if (!TextUtils.isEmpty(token) && !TextUtils.isEmpty(expires)
                    && !TextUtils.isEmpty(openId)) {
                oauth.setAccessToken(token, expires);
                oauth.setOpenId(openId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        didAuthorize(0, (JSONObject) o);
    }

    @Override
    public void onError(UiError uiError) {
        didAuthorize(-2, null);
    }

    @Override
    public void onCancel() {
        didAuthorize(-1, null);
    }

    private void didAuthorize(int statusCode, JSONObject data) {
        data = data != null ? data : new JSONObject();
        try {
            data.put("status_code", statusCode);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        dispatchStatusEventAsync("authorize", data.toString());
    }
}
