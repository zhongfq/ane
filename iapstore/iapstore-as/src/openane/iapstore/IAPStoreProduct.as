package openane.iapstore {

public class IAPStoreProduct {
    private var _title:String = null;
    private var _description:String = null;
    private var _identifier:String = null;
    private var _priceLocale:String = null;
    private var _price:Number = 0;

    public function IAPStoreProduct(title:String, description:String, identifier:String,
                                    priceLocale:String, price:Number) {
        _title = title;
        _description = description;
        _identifier = identifier;
        _priceLocale = priceLocale;
        _price = price;
    }

    public function get title():String {
        return _title;
    }

    public function get description():String {
        return _description;
    }

    public function get identifier():String {
        return _identifier;
    }

    public function get priceLocale():String {
        return _priceLocale;
    }

    public function get price():Number {
        return _price;
    }

    public function toString():String {
        return JSON.stringify(this);
    }
}
}

