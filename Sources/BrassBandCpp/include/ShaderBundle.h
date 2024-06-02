#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShaderBundle : NSObject

+ (nullable id<MTLLibrary>)defaultMetalLibraryWithDevice:(id<MTLDevice>)device NS_SWIFT_NAME(defaultMetalLibrary(device:));

@end

NS_ASSUME_NONNULL_END
