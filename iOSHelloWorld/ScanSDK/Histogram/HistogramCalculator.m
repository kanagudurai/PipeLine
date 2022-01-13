//
//  MyClass.m
//  
//
//  Created by Melek Ramki on 2021-10-04.
//  Performs histogram equalization efficiently
//

#import <Foundation/Foundation.h>
#import "HistogramCalculator.h"

@implementation HistogramCalculator

+(void) calcHistogramForPixelBuffer:(CVPixelBufferRef)pixelBuffer
                           toBuffer:(float*)histogram
                           withSize:(int)size
                          forColors:(int)colors
                           minDepth:(float)minDepth
                           maxDepth:(float)maxDepth
                      binningFactor:(int)factor {
    memset(histogram, 0, size * sizeof(histogram[0]));
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    const uint8_t* baseAddress = (const uint8_t*)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    size_t numPoints = 0;
    
    for (size_t y = 0; y < height; ++y) {
        const Float32* data = (const Float32*)(baseAddress + y * stride);
        
        for (size_t x = 0; x < width; ++x, ++data) {
            Float32 depth = *data;
            if (!isnan(depth) && depth > minDepth && depth < maxDepth) {
                ushort binIndex = depth * factor;
                ++histogram[binIndex];
                ++numPoints;
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    for (int i = 1; i < size; ++i)
        histogram[i] += histogram[i-1];
    
    for (int i = 1; i < size; ++i)
        histogram[i] = colors * histogram[i] / numPoints;
    
    for (int i = 1; i < size; ++i)
        histogram[i] = colors - histogram[i];
}

@end
