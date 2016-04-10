package openane.iapstore {
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;
import flash.utils.getQualifiedClassName;

[Event(name="purchaseTransactionSuccess", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="purchaseTransactionFail", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="purchaseTransactionCancel", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="restoreTransactionSuccess", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="restoreTransactionFail", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="restoreTransactionComplete", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="finishTransactionSuccess", type="openane.iapstore.IAPStoreTransactionEvent")]
[Event(name="productDetailsSuccess", type="openane.iapstore.IAPStoreProductEvent")]
[Event(name="productDetailsInvalid", type="openane.iapstore.IAPStoreProductEvent")]
[Event(name="productDetailsFail", type="openane.iapstore.IAPStoreProductEvent")]
public class IAPStore extends EventDispatcher {
    private static var _defaultInstance:IAPStore;

    public static function get defaultInstance():IAPStore {
        return _defaultInstance ||= new IAPStore();
    }

    private var _context:ExtensionContext;

    public function IAPStore() {
        if (_defaultInstance) {
            throw new Error(format("use %s.defaultInstance", getQualifiedClassName(IAPStore)));
        }

        if (Capabilities.os.search(/iPhone/) >= 0) {
            _context = ExtensionContext.createExtensionContext("openane.iapstore.IAPStore", "");
            _context.addEventListener(StatusEvent.STATUS, statusHandler);
        }
    }

    private function statusHandler(event:StatusEvent):void {
        var type:String;
        var transactions:Vector.<IAPStoreTransaction>;
        switch (event.code) {
            case "print":
                print("%s", event.level);
                break;
            case "productDetailsSuccess":
                type = IAPStoreProductEvent.PRODUCT_DETAILS_SUCCESS;
                dispatchEvent(new IAPStoreProductEvent(type, stringToProducts(event.level)));
                break;
            case "productDetailsInvalid":
                type = IAPStoreProductEvent.PRODUCT_DETAILS_INVALID;
                dispatchEvent(new IAPStoreProductEvent(type, null,
                        stringToInvalidProducts(event.level)));
                break;
            case "productDetailsFail":
                type = IAPStoreProductEvent.PRODUCT_DETAILS_FAIL;
                dispatchEvent(new IAPStoreProductEvent(type, null, null, event.level));
                break;
            case "finishTransaction":
                type = IAPStoreTransactionEvent.FINISH_TRANSACTION_SUCCESS;
                transactions = stringToTransactions(event.level);
                dispatchEvent(new IAPStoreTransactionEvent(type, transactions));
                break;
            case "purchaseTransactionSuccess":
                type = IAPStoreTransactionEvent.PURCHASE_TRANSACTION_SUCCESS;
                transactions = stringToTransactions(event.level);
                dispatchEvent(new IAPStoreTransactionEvent(type, transactions));
                break;
            case "purchaseTransactionCancel":
                type = IAPStoreTransactionEvent.PURCHASE_TRANSACTION_CANCEL;
                transactions = stringToTransactions(event.level);
                dispatchEvent(new IAPStoreTransactionEvent(type, transactions));
                break;
            case "purchaseTransactionFail":
                type = IAPStoreTransactionEvent.PURCHASE_TRANSACTION_FAIL;
                transactions = stringToTransactions(event.level);
                dispatchEvent(new IAPStoreTransactionEvent(type, transactions));
                break;
            case "restoreTransactionSuccess":
                type = IAPStoreTransactionEvent.RESTORE_TRANSACTION_SUCCESS;
                transactions = stringToTransactions(event.level);
                dispatchEvent(new IAPStoreTransactionEvent(type, transactions));
                break;
            case "restoreTransactionComplete":
                type = IAPStoreTransactionEvent.RESTORE_TRANSACTION_COMPLETE;
                dispatchEvent(new IAPStoreTransactionEvent(type));
                break;
            case "restoreTransactionFail":
                type = IAPStoreTransactionEvent.RESTORE_TRANSACTION_FAIL;
                dispatchEvent(new IAPStoreTransactionEvent(type, null, event.level));
                break;
        }
    }

    private function print(...args):void {
        trace("[IAPStore] " + format.apply(null, args));
    }

    public function canMakePayments():Boolean {
        if (!_context) {
            return false;
        } else {
            return _context.call("canMakePayments");
        }
    }

    public function requestProducts(pids:Vector.<String>):void {
        if (_context) {
            _context.call("requestProducts", pids.join(","));
        }
    }

    public function purchase(product:IAPStoreProduct, quantity:int = 1):void {
        if (_context) {
            _context.call("purchase", product.identifier, quantity);
        }
    }

    public function finishTransaction(transaction:IAPStoreTransaction):void {
        if (_context) {
            _context.call("finishTransaction", transaction.identifier);
        }
    }

    public function restoreCompletedTransactions():void {
        if (_context) {
            _context.call("restoreCompletedTransactions");
        }
    }

    public function get pendingTransactions():Vector.<IAPStoreTransaction> {
        if (_context) {
            var data:String = _context.call("pendingTransactions") as String;
            return data ? stringToTransactions(data) : null;
        } else {
            return null;
        }
    }

    private function stringToProducts(data:String):Vector.<IAPStoreProduct> {
        var products:Vector.<IAPStoreProduct> = new Vector.<IAPStoreProduct>();

        for each (var value:Object in (JSON.parse(data) as Array)) {
            products.push(new IAPStoreProduct(value['title'], value['description'],
                    value['identifier'], value['priceLocale'], value['price']));
        }

        return products;
    }

    private function stringToInvalidProducts(data:String):Vector.<String> {
        var products:Vector.<String> = new Vector.<String>();

        for each (var id:String in data.split(",")) {
            products.push(id);
        }

        return products;
    }

    private function stringToTransactions(data:String):Vector.<IAPStoreTransaction> {
        var transactions:Vector.<IAPStoreTransaction> = new Vector.<IAPStoreTransaction>();

        for each (var value:Object in (JSON.parse(data) as Array)) {
            transactions.push(objectToTransaction(value));
        }

        return transactions;
    }

    private function objectToTransaction(data:Object):IAPStoreTransaction {
        if (data) {
            return new IAPStoreTransaction(data['productIdentifier'], data['productQuantity'],
                    data['identifier'], new Date(data['date'] * 1000), data['receipt'],
                    data['error'], objectToTransaction(data['originalTransaction']));
        } else {
            return null;
        }
    }
}
}
