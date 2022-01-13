//
//  MyClass.h
//  
//
//  Created by Melek Ramki on 2021-10-04.
//  Performs histogram equalization efficiently
//

#ifndef DepthToJETConverter_h
#define DepthToJETConverter_h


#import <CoreVideo/CoreVideo.h>

@interface HistogramCalculator : NSObject

+ (void) calcHistogramForPixelBuffer:(CVPixelBufferRef)pixelBuffer
                            toBuffer:(float*)histogram
                            withSize:(int)size
                           forColors:(int)colors
                            minDepth:(float)minDepth
                            maxDepth:(float)maxDepth
                       binningFactor:(int)factor;

@end

#endif /* DepthToJETConverter_h */
