//
// $id: openaneLame.h openane $
//

#import <Foundation/Foundation.h>

#import "FlashRuntimeExtensions.h"
#import "lamewrapper.h"

@interface LameConnector : NSObject
@property(readwrite, assign, nonatomic) lamewrapper *lame;
@property(readonly, assign, nonatomic) FREContext context;

- (id)initWithContext:(FREContext) ctx;
@end

#ifdef __cplusplus
extern "C" {
#endif

void openaneLameInitializer(void **extDataToSet, FREContextInitializer *ctxInitializerToSet, FREContextFinalizer *ctxFinalizerToSet);
void openaneLameFinalizer(void *extData);

#ifdef __cplusplus
}
#endif
