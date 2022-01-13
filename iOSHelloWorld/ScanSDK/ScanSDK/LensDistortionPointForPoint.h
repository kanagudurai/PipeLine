//
//  DistortionCorrection.h
//  ScanSDK
//
//  Created by Melek Ramki on 2021-11-08.
//  Copyright © 2021 Podform3D. All rights reserved.
//

#ifndef lensDistortionPointForPoint_h
#define lensDistortionPointForPoint_h

#import <CoreGraphics/CGGeometry.h>

CGPoint lensDistortionPointForPoint(CGPoint point, NSData *lookupTable, CGPoint opticalCenter, CGSize imageSize);

#endif /* LensDistortionPointForPoint_h */
