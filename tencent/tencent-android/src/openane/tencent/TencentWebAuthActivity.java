package openane.tencent;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.LinearLayout;

public class TencentWebAuthActivity extends Activity {

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout layout = new LinearLayout(this);
        layout.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setBackgroundColor(0xFFFFFFFF);
        setContentView(layout);

        Button button = new Button(this);
        button.setText("  关闭");
        button.setScaleX(1.3f);
        button.setScaleY(1.3f);
        button.setLayoutParams(new LayoutParams(LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT));
        button.setBackgroundColor(0x00FFFFFF);
        layout.addView(button);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        String url = "https://openmobile.qq.com/oauth2.0/m_authorize" +
                "?status_userip=" + getIntent().getStringExtra("scope") +
                "&scope=" +
                "&redirect_uri=tencent%3A%2F%2Ftauth.qq.com%2F" +
                "&response_type=token" +
                "&client_id=" + getIntent().getStringExtra("appid");

        final Intent result = new Intent();

        WebView web = new WebView(this);
        web.clearCache(true);
        web.getSettings().setJavaScriptEnabled(true);
        web.getSettings().setSupportZoom(true);
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.contains("openid=")) {
                    result.putExtra("openid", extract(url, "openid="));
                }

                if (url.startsWith("tencent://")) {
                    if (url.contains("access_token=") && url.contains("expires_in")) {
                        result.putExtra("access_token", extract(url, "access_token="));
                        result.putExtra("expires_in", extract(url, "expires_in="));
                        result.putExtra("pay_token", extract(url, "pay_token="));
                        setResult(0, result);
                        finish();
                    } else {
                        setResult(-2);
                        finish();
                    }
                    return false;
                } else {
                    view.loadUrl(url);
                    return true;
                }
            }
        });
        web.loadUrl(url);
        layout.addView(web);
    }

    private String extract(String str, String key) {
        int start = str.indexOf(key);
        if (start >= 0) {
            int end = str.indexOf("&", start + key.length());
            return str.substring(start + key.length(), end > 0 ? end : str.length());
        } else {
            return null;
        }
    }

    @Override
    public void onBackPressed() {
        setResult(-1);
        finish();
    }
}
