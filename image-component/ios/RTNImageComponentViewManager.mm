#import <React/RCTLog.h>
#import <React/RCTUIManager.h>
#import <React/RCTViewManager.h>

@interface RTNImageComponentViewManager : RCTViewManager
@end

@implementation RTNImageComponentViewManager

RCT_EXPORT_MODULE(RTNImageComponent)

RCT_EXPORT_VIEW_PROPERTY(image, UIImage *)

@end
