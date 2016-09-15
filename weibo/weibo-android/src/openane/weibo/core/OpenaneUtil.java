package openane.weibo.core;

import com.adobe.fre.FREObject;

public class OpenaneUtil {
    public static String objectToString(FREObject obj) {
        try {
            return obj.getAsString();
        } catch (Exception e) {
            return null;
        }
    }
}
