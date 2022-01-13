//
//  ObjectiveC-SDK.h
//  MesherSDK
//
//  Created by Eesha on 2021-10-13.
//


#import <Foundation/Foundation.h>


@interface WrapperSDK : NSObject

+(NSDictionary *) decimateWithInPoint:(float *)inPoint withInNormal:(float *)inNormal withColor:(uint8_t *)inColor withLen:(int)inPointLen withInVexelSize:(float)in_voxel_size;

+(NSDictionary *)computeNormalsWithInPoint:(float *)inPoint withLen:(int)inPointLen withInKnn:(int)inKnn;

+(NSDictionary *)meshWithInPoint:(float *)inPoint  withInNormal:(float *)inNormal withLen:(int)inPointLen withInOpeningDistance:(float)inOpeningDistance withInDepth:(int)inDepth withNbThread:(int)nbThread;

+(NSDictionary *)intersectWithInPoint:(float *)inPoint withInNormal:(float *)inNormal withInColor:(uint8_t *)inColor  withLen:(int)inPointLen withInSearchDistance:(float)inSearchDistance withInBBMin:(NSArray *)inBBMin withInBBMax:(NSArray *)inBBMax;

+(NSDictionary *)registrationWithInPoint1:(float *)inPoint1 withInNormal1:(float *)inNormal1 withLen1:(int)inPoint1Len withInPoint2:(float *)inPoint2 withInNormal2:(float *)inNormal2 withLen2:(int)inPoint2Len withInSearchDistance:(float)inSearchDistance withInPtsPlaneRatio:(float)inPtsPlaneRatio withInTolerance:(float)inTolerance withInMaxInteration:(int)inMaxInteration;

+(BOOL)writeObjWithInVert:(float *)inVert  withInColor:(float *)inColor withVertLen:(int)inVertLen withInFaceVertId:(int *)inFaceVertId withFaceLen:(int)inFaceLen withInFileName:(NSString *)inFileName;

+(BOOL)writePlyWithInVert:(float *)inVert  withInColor:(unsigned char *)inColor withVertLen:(int)inVertLen withInFaceVertId:(int *)inFaceVertId withFaceLen:(int)inFaceVertLen withInFileName:(NSString *)inFileName;

+(NSDictionary *)extractOutOfSurfacePointWithInPoint:(float *)inPoint withInPointLen:(int)inPointLen withInPoint2:(float*)inPoint2 withInNormal2:(float*)inNormal2 withInPoint2Len:(int)inPoint2Len withInMaxDistance:(float)inMaxDistance;

+(NSArray *)findPointClosetColorWithInPoint:(float *)inPoint withInColor:(UInt8 *)inColor withInPointLen:(int)inPointLen withInDestPoint:(float*)inDestPoint withInDestPointLen:(int)inDestPointLen;

+(NSDictionary *)processFrameWithWithInPoint:(float *)inPoint withInColor:(UInt8 *)inColor withInPointLen:(int)inPointLen // new frame data
                                withInPoint2:(float *)inPoint2 withInNormal2:(float *)inNormal2 withInColor2:(UInt8 *)inColor2 withInPointLen2:(int)inPointLen2 // aggregated data
                                 withInBBMin:(NSArray *)inBBMin withInBBMax:(NSArray *)inBBMax // bb box
                        withInSearchDistance:(float)inSearchDistance withInPtsProp:(float)inPtsProp withInTolerance:(float)inTolerance withInMaxIteration:(int)inMaxIteration // registration params
                        withInVoxelSizeInput:(float)inVoxelSizeInput withInVoxelSizeOutput:(float)inVoxelSizeOutput// decimation params
                                   withInKnn:(int)inKnn; // normal params

@end

