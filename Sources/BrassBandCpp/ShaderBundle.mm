#import "ShaderBundle.h"

@implementation ShaderBundle

+ (id<MTLLibrary>)defaultMetalLibraryWithDevice:(id<MTLDevice>)device {
    return [device newDefaultLibraryWithBundle:SWIFTPM_MODULE_BUNDLE error:nil];
}

@end
