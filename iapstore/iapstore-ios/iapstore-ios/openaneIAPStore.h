//
// $id: openaneIAPStore.h openane $
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FlashRuntimeExtensions.h"

@interface IAPStoreConnector : NSObject<SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>

@property(readonly, assign, nonatomic) FREContext context;

- (id)initWithContext:(FREContext) ctx;

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

void openaneIAPStoreInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneIAPStoreFinalizer(void *extData);