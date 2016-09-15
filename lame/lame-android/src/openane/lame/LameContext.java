package openane.lame;

import android.util.Log;
import com.adobe.fre.FREFunction;
import net.sourceforge.lame.LameWrapper;
import openane.lame.core.OpenaneContext;

import java.util.HashMap;
import java.util.Map;

public class LameContext extends OpenaneContext {
    private static final String TAG = LameContext.class.getName();

    LameWrapper lame = new LameWrapper();

    @Override
    public Map<String, FREFunction> getFunctions() {
        Log.i(TAG, "getFunctions");

        HashMap<String, FREFunction> map = new HashMap<>();
        map.put("update", new LameFuncUpdate());
        map.put("dispose", new LameFuncDispose());
        map.put("buffer", new LameFuncBuffer());

        return map;
    }

    @Override
    public void dispose() {
        super.dispose();
        lame.dispose();
    }
}
