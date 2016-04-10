//
// $id: openaneIAPStore.h openane $
//

#import "openaneIAPStore.h"

@implementation IAPStoreConnector

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    NSString *str = openaneTransactionsToString(transactions);
    const char *code = nil;
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                code = "purchaseTransactionSuccess";
                break;
            case SKPaymentTransactionStateRestored:
                code = "restoreTransactionSuccess";
                break;
            case SKPaymentTransactionStateFailed:
                code = transaction.error.code == SKErrorPaymentCancelled ? "purchaseTransactionCancel" : "purchaseTransactionFail";
                break;
            default:
                break;
        }
        break;
    }
    
    if (code != nil)
    {
        FREDispatchStatusEventAsync(self.context, FRESTR(code), FRESTR([str UTF8String]));
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    @autoreleasepool {
        FREDispatchStatusEventAsync(self.context,
                                    FRESTR("finishTransactionSuccess"),
                                    FRESTR([openaneTransactionsToString(transactions) UTF8String]));
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    @autoreleasepool {
        NSString *errstr = [[error localizedDescription] stringByAppendingFormat:@":%ld", (long)error.code];
        FREDispatchStatusEventAsync(self.context, FRESTR("restoreTransactionFail"), FRESTR([errstr UTF8String]));
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    FREDispatchStatusEventAsync(self.context, FRESTR("restoreTransactionComplete"), FRESTR(""));
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    @autoreleasepool {
        if (response.products.count > 0)
        {
            self.products = response.products;
            FREDispatchStatusEventAsync(self.context,
                                        FRESTR("productDetailsSuccess"),
                                        FRESTR([openaneProductsToString(response.products) UTF8String]));
        }
        
        if (response.invalidProductIdentifiers.count > 0)
        {
            FREDispatchStatusEventAsync(self.context,
                                        FRESTR("productDetailsInvalid"),
                                        FRESTR([openaneObjectToJSONString(response.invalidProductIdentifiers) UTF8String]));
        }
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    @autoreleasepool {
        NSString *errstr = [[error localizedDescription] stringByAppendingFormat:@":%ld", (long)error.code];
        FREDispatchStatusEventAsync(self.context, FRESTR("productDetailsFail"), FRESTR([errstr UTF8String]));

    }
}

@end

void openaneIAPStoreInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet)
{
    *extDataToSet = nil;
    *ctxInitializerToSet = &openaneIAPStoreContextInitializer;
    *ctxFinalizerToSet = &openaneIAPStoreContextFinalizer;
}

void openaneIAPStoreFinalizer(void *extData)
{
}

void openaneIAPStoreContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet)
{
    @autoreleasepool {
        static FRENamedFunction funcs[] =
        {
            MAP_FUNCTION("canMakePayments", openaneIAPStoreFuncCanMakePayments, nil),
            MAP_FUNCTION("requestProducts", openaneIAPStoreFuncRequestProducts, nil),
            MAP_FUNCTION("purchase", openaneIAPStoreFuncPurchase, nil),
            MAP_FUNCTION("finishTransaction", openaneIAPStoreFuncFinishTransaction, nil),
            MAP_FUNCTION("restoreCompletedTransactions", openaneIAPStoreFuncRestoreCompletedTransactions, nil),
            MAP_FUNCTION("pendingTransactions", openaneIAPStoreFuncPendingTransactions, nil),
        };
        
        *numFunctionsToSet = sizeof(funcs) / sizeof(FRENamedFunction);
        *functionsToSet = funcs;
        
        IAPStoreConnector *connector = [[IAPStoreConnector alloc] initWithContext:ctx];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:connector];
        FRESetContextNativeData(ctx, (void *)CFBridgingRetain(connector));
    }
}

void openaneIAPStoreContextFinalizer(FREContext ctx)
{
    @autoreleasepool {
        IAPStoreConnector* connector = openaneIAPStoreContextNativeData(ctx);
        if (connector != nil)
        {
            [[SKPaymentQueue defaultQueue] removeTransactionObserver:connector];
            CFBridgingRelease((__bridge CFTypeRef)connector);
            FRESetContextNativeData(ctx, nil);
        }
    }
}

IAPStoreConnector *openaneIAPStoreContextNativeData(FREContext ctx)
{
    void *ptr = nil;
    if (FREGetContextNativeData(ctx, &ptr) == FRE_OK)
    {
        return (__bridge IAPStoreConnector *)ptr;
    }
    else
    {
        FREPrint("native data is nil");
        return nil;
    }
}

NSDictionary *openaneTransactionToDictionary(SKPaymentTransaction *transaction)
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:transaction.payment.productIdentifier forKey:@"productIdentifier"];
    [dict setValue:[NSNumber numberWithInteger:transaction.payment.quantity] forKey:@"productQuantity"];
    [dict setValue:transaction.transactionIdentifier forKey:@"identifier"];
    
    if (transaction.transactionState == SKPaymentTransactionStatePurchased ||
        transaction.transactionState == SKPaymentTransactionStateRestored)
    {
        [dict setValue:[NSNumber numberWithDouble:transaction.transactionDate.timeIntervalSince1970] forKey:@"date"];
        [dict setValue:[[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSASCIIStringEncoding] forKey:@"receipt"];
    }
    
    if(transaction.transactionState == SKPaymentTransactionStateFailed)
    {
        NSString *error = [[transaction.error localizedDescription] stringByAppendingFormat:@":%ld", (long)transaction.error.code];
        [dict setValue:error forKey:@"error"];
    }
    
    if(transaction.transactionState == SKPaymentTransactionStateRestored &&
       transaction.originalTransaction.transactionState != SKPaymentTransactionStatePurchasing)
    {
        [dict setValue:openaneTransactionToDictionary(transaction.originalTransaction) forKey:@"originalTransaction"];
    }
    
    return dict;
}

NSString *openaneTransactionsToString(NSArray<SKPaymentTransaction *> *transactions)
{
    NSMutableArray<NSDictionary *> *values = [[NSMutableArray alloc] init];
    
    for (SKPaymentTransaction *t in transactions)
    {
        [values addObject:openaneTransactionToDictionary(t)];
    }
    
    return openaneObjectToJSONString(values);
}

NSString *openaneProductsToString(NSArray<SKProduct *> *products)
{
    NSMutableArray<NSDictionary *> *values = [[NSMutableArray alloc] init];
    
    for (SKProduct *p in products)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:p.localizedTitle forKey:@"title"];
        [dict setValue:p.localizedDescription forKey:@"description"];
        [dict setValue:p.productIdentifier forKey:@"identifier"];
        [dict setValue:p.priceLocale.localeIdentifier forKey:@"priceLocale"];
        [dict setValue:p.price forKey:@"price"];
        [values addObject:dict];
    }
    
    return openaneObjectToJSONString(values);
}

ANE_FUNCTION(openaneIAPStoreFuncCanMakePayments)
{
    @autoreleasepool {
        FREObject available = nil;
        FRENewObjectFromBool([SKPaymentQueue canMakePayments], &available);
        return available;
    }
}

ANE_FUNCTION(openaneIAPStoreFuncRequestProducts)
{
    @autoreleasepool {
        IAPStoreConnector *connector = openaneIAPStoreContextNativeData(ctx);
        NSString *idsstr = openaneObjectToString(argv[0]);
        NSMutableSet *ids = [NSMutableSet setWithArray:[idsstr componentsSeparatedByString:@","]];
        
        SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:ids];
        req.delegate = connector;
        [req start];

        NSString *msg = [NSString stringWithFormat:@"request products: %@", idsstr];
        FREPrint([msg UTF8String]);
        return nil;
    }
}

ANE_FUNCTION(openaneIAPStoreFuncPurchase)
{
    @autoreleasepool {
        IAPStoreConnector *connector = openaneIAPStoreContextNativeData(ctx);
        NSString *pid = openaneObjectToString(argv[0]);
        NSNumber *quantify = openaneObjectToNumber(argv[1]);
        SKProduct *product = nil;
        
        if (connector.products != nil)
        {
            for (SKProduct *p in connector.products)
            {
                if ([p.productIdentifier isEqualToString:pid])
                {
                    product = p;
                    break;
                }
            }
        }
        
        if (product != nil)
        {
            NSString *msg = [NSString stringWithFormat:@"purchase product: pid=%@ quantity=%@", pid, quantify];
            FREPrint([msg UTF8String]);
            
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
            payment.quantity = MAX(1, [quantify integerValue]);
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        else
        {
            NSString *msg = [NSString stringWithFormat:@"can't find product: %@", pid];
            FREPrint([msg UTF8String]);
        }
        
        return nil;
    }
}

ANE_FUNCTION(openaneIAPStoreFuncFinishTransaction)
{
    @autoreleasepool {
        IAPStoreConnector *connector = openaneIAPStoreContextNativeData(ctx);
        UNUSED(connector);
        NSString *tid = openaneObjectToString(argv[0]);
        NSString *msg = [NSString stringWithFormat:@"try to finish transaction: %@", tid];
        FREPrint([msg UTF8String]);
        for (SKPaymentTransaction *t in [SKPaymentQueue defaultQueue].transactions)
        {
            FREPrint([t.transactionIdentifier UTF8String]);
            if ([t.transactionIdentifier isEqualToString:tid])
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:t];
            }
            else if (t.originalTransaction && [t.originalTransaction.transactionIdentifier isEqualToString:tid])
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:t.originalTransaction];
            }
        }
        return nil;
    }
}

ANE_FUNCTION(openaneIAPStoreFuncRestoreCompletedTransactions)
{
    @autoreleasepool {
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        return nil;
    }
}

ANE_FUNCTION(openaneIAPStoreFuncPendingTransactions)
{
    @autoreleasepool {
        NSMutableArray<SKPaymentTransaction *> *transactions = [[NSMutableArray alloc] init];
        for (SKPaymentTransaction *t in [SKPaymentQueue defaultQueue].transactions)
        {
            if (t.transactionState != SKPaymentTransactionStatePurchasing)
            {
                [transactions addObject:t];
            }
        }
        
        if (transactions.count > 0)
        {
            NSString *str = openaneTransactionsToString(transactions);
            FREObject value = nil;
            FRENewObjectFromUTF8((uint32_t)str.length, FRESTR([str UTF8String]), &value);
            return value;
        }
        else
        {
            return nil;
        }
    }
}