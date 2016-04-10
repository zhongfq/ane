package openane.iapstore {

public class IAPStoreTransaction {
    private var _productIdentifier:String;
    private var _productQuantity:int;
    private var _identifier:String;
    private var _date:Date;
    private var _receipt:String;
    private var _error:String;
    private var _originalTransaction:IAPStoreTransaction;

    public function IAPStoreTransaction(productIdentifier:String, productQuantity:int,
                                        identifier:String, date:Date, receipt:String, error:String,
                                        originalTransaction:IAPStoreTransaction = null) {
        _productIdentifier = productIdentifier;
        _productQuantity = productQuantity;
        _identifier = identifier;
        _date = date;
        _receipt = receipt;
        _error = error;
        _originalTransaction = originalTransaction;
    }

    public function get productIdentifier():String {
        return _productIdentifier;
    }

    public function get productQuantity():int {
        return _productQuantity;
    }

    public function get identifier():String {
        return _identifier;
    }

    public function get date():Date {
        return _date;
    }

    public function get receipt():String {
        return _receipt;
    }

    public function get error():String {
        return _error;
    }

    public function get originalTransaction():IAPStoreTransaction {
        return _originalTransaction;
    }

    public function toString():String {
        return JSON.stringify(this);
    }
}
}

