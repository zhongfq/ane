//
// $id: openaneAlipay.h openane $
//

#import <Foundation/Foundation.h>
#import "openane.h"

@interface AlipayConnector : Connector

@property(readwrite, strong, nonatomic) NSString *appID;
@property(readwrite, strong, nonatomic) NSString *privateKey;
@property(readwrite, strong, nonatomic) NSString *publicKey;

@end

#define DLOG(fmt, ...) OPENANE_LOG(@"openaneAlipay", fmt, ##__VA_ARGS__)

void openaneAlipayInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneAlipayFinalizer(void *extData);

void openaneAlipayContextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet);
void openaneAlipayContextFinalizer(FREContext ctx);
AlipayConnector* openaneAlipayContextNativeData(FREContext ctx);

ANE_FUNCTION(openaneAlipayFuncInit);
ANE_FUNCTION(openaneAlipayFuncPay);
ANE_FUNCTION(openaneAlipayFuncPayWithSignedInfo);
ANE_FUNCTION(openaneAlipayFuncHandleOpenURL);