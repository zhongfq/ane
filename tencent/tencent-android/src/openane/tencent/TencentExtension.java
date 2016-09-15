package openane.tencent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class TencentExtension implements FREExtension {
    @Override
    public void initialize() {
    }

    @Override
    public FREContext createContext(String s) {
        return new TencentContext();
    }

    @Override
    public void dispose() {

    }
}
