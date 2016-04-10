package openane.iapstore {
import flash.events.Event;

public class IAPStoreProductEvent extends Event {
    public static const PRODUCT_DETAILS_SUCCESS:String = "productDetailsSuccess";
    public static const PRODUCT_DETAILS_INVALID:String = "productDetailsInvalid";
    public static const PRODUCT_DETAILS_FAIL:String = "productDetailsFail";

    private var _products:Vector.<IAPStoreProduct> = null;
    private var _invalidIdentifiers:Vector.<String> = null;
    private var _error:String = null;

    public function IAPStoreProductEvent(type:String, products:Vector.<IAPStoreProduct> = null,
                                         invalidIdentifiers:Vector.<String> = null,
                                         error:String = null) {
        super(type, bubbles, cancelable);

        _products = products;
        _invalidIdentifiers = invalidIdentifiers;
        _error = error;
    }

    public function get products():Vector.<IAPStoreProduct> {
        return _products;
    }

    public function get invalidIdentifiers():Vector.<String> {
        return _invalidIdentifiers;
    }

    public function get error():String {
        return _error;
    }

    public override function clone():Event {
        return new IAPStoreProductEvent(type, _products, _invalidIdentifiers, _error);
    }
}
}

