package openane.iapstore {
import flash.events.Event;

public class IAPStoreTransactionEvent extends Event {
    public static const PURCHASE_TRANSACTION_SUCCESS:String = "purchaseTransactionSuccess";
    public static const PURCHASE_TRANSACTION_FAIL:String = "purchaseTransactionFail";
    public static const PURCHASE_TRANSACTION_CANCEL:String = "purchaseTransactionCancel";
    public static const RESTORE_TRANSACTION_SUCCESS:String = "restoreTransactionSuccess";
    public static const RESTORE_TRANSACTION_FAIL:String = "restoreTransactionFail";
    public static const RESTORE_TRANSACTION_COMPLETE:String = "restoreTransactionComplete";
    public static const FINISH_TRANSACTION_SUCCESS:String = "finishTransactionSuccess";

    private var _transactions:Vector.<IAPStoreTransaction> = null;
    private var _error:String = null;

    public function IAPStoreTransactionEvent(type:String,
                                             transactions:Vector.<IAPStoreTransaction> = null,
                                             error:String = null) {
        super(type, bubbles, cancelable);

        _transactions = transactions;
        _error = error;
    }

    public function get transactions():Vector.<IAPStoreTransaction> {
        return _transactions;
    }

    public function get error():String {
        return _error;
    }

    public override function clone():Event {
        return new IAPStoreTransactionEvent(type, _transactions, _error);
    }
}
}

