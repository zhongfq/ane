package net.sourceforge.lame;

@SuppressWarnings("JniMissingFunction")
public class LameWrapper {
    static {
        System.loadLibrary("lame");
    }

    private long _id;

    public LameWrapper() {
        _id = LameWrapper.create();
    }

    public void update(byte[] buffer, int len) {
        if (_id != 0) {
            LameWrapper.update(_id, buffer, len);
        }
    }

    public byte[] buffer() {
        if (_id != 0) {
            return LameWrapper.buffer(_id);
        }

        return new byte[0];
    }

    public void dispose() {
        if (_id != 0) {
            LameWrapper.dispose(_id);
            _id = 0;
        }
    }

    private static native long create();
    private static native void update(long id, byte[] buffer, int len);
    private static native byte[] buffer(long id);
    private static native void dispose(long id);
}
