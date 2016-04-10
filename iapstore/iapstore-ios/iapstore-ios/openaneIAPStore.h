//
// $id: openaneIAPStore.h openane $
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "openane.h"

@interface IAPStoreConnector : Connector<SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>

@property(readwrite, strong, nonatomic) NSArray<SKProduct *> *products;

// SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;

// SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;

// SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request;
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;

@end

#define DLOG(fmt, ...) OPENANE_LOG(@"openaneIAPStore", fmt, ##__VA_ARGS__)

void openaneIAPStoreInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneIAPStoreFinalizer(void *extData);

void openaneIAPStoreContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet);
void openaneIAPStoreContextFinalizer(FREContext ctx);
IAPStoreConnector *openaneIAPStoreContextNativeData(FREContext ctx);

NSDictionary *openaneTransactionToDictionary(SKPaymentTransaction *transaction);
NSString *openaneTransactionsToString(NSArray<SKPaymentTransaction *> *transactions);
NSString *openaneProductsToString(NSArray<SKProduct *> *products);

ANE_FUNCTION(openaneIAPStoreFuncCanMakePayments);
ANE_FUNCTION(openaneIAPStoreFuncRequestProducts);
ANE_FUNCTION(openaneIAPStoreFuncPurchase);
ANE_FUNCTION(openaneIAPStoreFuncFinishTransaction);
ANE_FUNCTION(openaneIAPStoreFuncRestoreCompletedTransactions);
ANE_FUNCTION(openaneIAPStoreFuncPendingTransactions);