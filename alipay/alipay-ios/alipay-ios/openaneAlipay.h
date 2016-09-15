//
// $id: openaneAlipay.h openane $
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

@interface AlipayConnector : NSObject
@property(readwrite, strong, nonatomic) NSString *appID;
@property(readwrite, strong, nonatomic) NSString *privateKey;
@property(readwrite, strong, nonatomic) NSString *publicKey;
@property(readonly, assign, nonatomic) FREContext context;

- (id)initWithContext:(FREContext) ctx;
@end

void openaneAlipayInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneAlipayFinalizer(void *extData);