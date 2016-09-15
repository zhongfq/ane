package openane.tencent;

import android.content.Intent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class TencentFuncAuthorize implements FREFunction {
    @Override
    public FREObject call(FREContext freContext, FREObject[] freObjects) {
        final TencentContext context = (TencentContext)freContext;

        if (context.oauth != null)
        {
            String scope = Util.objectToString(freObjects[0]);

            if (context.oauth.isSupportSSOLogin(context.getActivity())) {
                context.oauth.login(context.getActivity(), scope, context);
                context.print("authorized by sso");
            } else {
                Intent intent = new Intent(context.getActivity(), TencentWebAuthActivity.class);
                intent.putExtra("appid", context.oauth.getAppId());
                intent.putExtra("scope", scope);
                context.getActivity().startActivityForResult(intent, Integer.MAX_VALUE);
                context.print("authorized by web view");
            }
        }
        else
        {
            context.print("sdk not initialized");
        }

        return null;
    }
}
