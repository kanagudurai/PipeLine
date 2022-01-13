//
//  ObjectiveC-SDK.m
//  MesherSDK
//
//  Created by Eesha on 2021-10-13.
//
#include "sdk.h"
#include "ObjectiveC-SDK.h"

@implementation WrapperSDK

+(NSDictionary *) decimateWithInPoint:(float *)inPoint withInNormal:(float *)inNormal withColor:(uint8_t *)inColor withLen:(int)inPointLen withInVexelSize:(float)in_voxel_size
{
    float *out_point = NULL;
    float *out_normal = NULL;
    uint8_t *out_color = NULL;
    int out_point_len = 0;
    i2::decimate(inPoint, inNormal, inColor, inPointLen, &out_point, &out_normal, &out_color, &out_point_len, in_voxel_size);
    
    NSMutableArray *outPtArray = [NSMutableArray new];
    for (int i = 0; i < out_point_len; i++) {
        [outPtArray addObject:[NSNumber numberWithFloat:out_point[i]]];
    }
    delete [] out_point;
    
    NSMutableArray *outNrArray = nil;
    if(out_normal){
        outNrArray = [NSMutableArray new];
        for (int i = 0; i < out_point_len; i++) {
            [outNrArray addObject:[NSNumber numberWithFloat:out_normal[i]]];
        }
        delete [] out_normal;
    }
    
    NSMutableArray *outColorArray = nil;
    if(out_color){
        outColorArray = [NSMutableArray new];
        for (int i = 0; i < out_point_len; i++) {
            [outColorArray addObject:[NSNumber numberWithUnsignedInt:out_color[i]]];
        }
        delete [] out_color;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    dic[@"outPoint"] = outPtArray;
    dic[@"outNormal"] = outNrArray;
    dic[@"outColor"] = outColorArray;
    return dic;
    
}

+(NSDictionary *)computeNormalsWithInPoint:(float *)inPoint withLen:(int)inPointLen withInKnn:(int)inKnn
{
    
    float *out_normal = NULL;
    bool success = i2::computeNormals(inPoint, inPointLen, &out_normal, inKnn);
    
    NSMutableArray *outNormal = nil;
    if(out_normal){
        outNormal = [NSMutableArray new];
        for (int i = 0; i < inPointLen; i++) {
            [outNormal addObject:[NSNumber numberWithFloat:out_normal[i]]];
        }
        
        delete [] out_normal;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"success"] = [NSNumber numberWithBool:success];
    dic[@"outNormal"] = outNormal;
    return dic;
    
}

+(NSDictionary *)meshWithInPoint:(float *)inPoint  withInNormal:(float *)inNormal withLen:(int)inPointLen withInOpeningDistance:(float)inOpeningDistance withInDepth:(int)inDepth withNbThread:(int)nbThread
{
    
    float *out_vert = NULL;
    int out_vert_len = 0;
    int *out_faceVert_id = NULL;
    int out_faceVert_len = 0;
    
    i2::mesh(inPoint, inNormal, inPointLen, &out_vert, &out_vert_len, &out_faceVert_id, &out_faceVert_len, inOpeningDistance, inDepth, nbThread);
    
    NSMutableArray *outVert = [NSMutableArray new];
    for(int i = 0; i < out_vert_len; i++){
        [outVert addObject:[NSNumber numberWithFloat:out_vert[i]]];
    }
    delete [] out_vert;
    
    NSMutableArray *outFaceVertId = nil;
    if(out_faceVert_id){
        outFaceVertId = [NSMutableArray new];
        for(int i = 0; i < out_faceVert_len; i++){
            [outFaceVertId addObject:[NSNumber numberWithInt:out_faceVert_id[i]]];
        }
        delete [] out_faceVert_id;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"outVert"] = outVert;
    dic[@"outFaceVertId"] = outFaceVertId;
    return dic;
    
}

+(NSDictionary *)intersectWithInPoint:(float *)inPoint withInNormal:(float *)inNormal withInColor:(uint8_t *)inColor  withLen:(int)inPointLen withInSearchDistance:(float)inSearchDistance withInBBMin:(NSArray *)inBBMin withInBBMax:(NSArray *)inBBMax
{
    float *in_bb_min = new float[inBBMin.count];
    float *in_bb_max = new float[inBBMin.count];
    for(int i = 0; i < inBBMin.count; i++){
        in_bb_min[i] = [[inBBMin objectAtIndex:i] floatValue];
        in_bb_max[i] = [[inBBMax objectAtIndex:i] floatValue];
    }
    
    float *out_point = NULL;
    float *out_normal = NULL;
    uint8_t *out_color = NULL;
    int out_point_len = 0;
    
    i2::intersect(inPoint, inNormal, inColor, inPointLen, &out_point, &out_normal, &out_color, &out_point_len, inSearchDistance, in_bb_min, in_bb_max);
    
    NSMutableArray *outPoint = [NSMutableArray new];
    for(int i = 0; i < out_point_len; i ++){
        [outPoint addObject:[NSNumber numberWithFloat:out_point[i]]];
    }
    delete [] out_point;
    
    NSMutableArray *outNormal = nil;
    if( out_normal){
        outNormal = [NSMutableArray new];
        for(int i = 0; i < out_point_len; i ++){
            [outNormal addObject:[NSNumber numberWithFloat:out_normal[i]]];
        }
        
        delete [] out_normal;
    }
    
    NSMutableArray *outColorArray = nil;
    if(out_color){
        outColorArray = [NSMutableArray new];
        for (int i = 0; i < out_point_len; i++) {
            [outColorArray addObject:[NSNumber numberWithUnsignedInt:out_color[i]]];
        }
        delete [] out_color;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"outPoint"] = outPoint;
    dic[@"outNormal"] = outNormal;
    dic[@"outColor"] = outColorArray;
    
    return dic;
}

+(NSDictionary *)registrationWithInPoint1:(float *)inPoint1 withInNormal1:(float *)inNormal1 withLen1:(int)inPoint1Len withInPoint2:(float *)inPoint2 withInNormal2:(float *)inNormal2 withLen2:(int)inPoint2Len withInSearchDistance:(float)inSearchDistance withInPtsPlaneRatio:(float)inPtsPlaneRatio withInTolerance:(float)inTolerance withInMaxInteration:(int)inMaxInteration
{
    float *out_point = NULL, *out_normal = NULL;
    
    bool success = i2::registration(inPoint1, inNormal1, inPoint1Len, inPoint2, inNormal2, inPoint2Len, &out_point, &out_normal, inSearchDistance);
    
    NSMutableArray *outPoint = [NSMutableArray new];
    NSMutableArray *outNormal = [NSMutableArray new];
    
    if (success) {
        for(int i = 0; i < inPoint2Len; i ++){
            [outPoint addObject:[NSNumber numberWithFloat:out_point[i]]];
        }
        
        for(int i = 0; i < inPoint2Len; i ++){
            [outNormal addObject:[NSNumber numberWithFloat:out_normal[i]]];
        }
    }
    delete[] out_point;
    delete[] out_normal;
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"success"] = [NSNumber numberWithBool:success];
    dic[@"outPoint"] = outPoint;
    dic[@"outNormal"] = outNormal;
    return dic;
}

+(BOOL)writeObjWithInVert:(float *)inVert  withInColor:(float *)inColor withVertLen:(int)inVertLen withInFaceVertId:(int *)inFaceVertId withFaceLen:(int)inFaceLen withInFileName:(NSString *)inFileName
{
    
    return i2::writeObj(inVert, inColor, inVertLen, inFaceVertId, inFaceLen, [inFileName UTF8String]);
}
+(BOOL)writePlyWithInVert:(float *)inVert withInColor:(unsigned char *)inColor withVertLen:(int)inVertLen withInFaceVertId:(int *)inFaceVertId withFaceLen:(int)inFaceVertLen withInFileName:(NSString *)inFileName
{
    return i2::writePly(inVert, inColor, inVertLen, inFaceVertId, inFaceVertLen, [inFileName UTF8String]);
}

+(NSDictionary *)extractOutOfSurfacePointWithInPoint:(float *)inPoint withInPointLen:(int)inPointLen withInPoint2:(float*)inPoint2 withInNormal2:(float*)inNormal2 withInPoint2Len:(int)inPoint2Len withInMaxDistance:(float)inMaxDistance
{
    float *out_point = NULL;
    float *out_normal = NULL;
    int out_point_len = 0;
    i2::extractOutOfSurfacePoint(inPoint, inPointLen, inPoint2, inNormal2, inPoint2Len, &out_point, &out_normal, &out_point_len, inMaxDistance);
    
    NSMutableArray *outPoint = nil;
    if(out_point){
        outPoint = [NSMutableArray new];
        for (int i = 0; i < out_point_len; i++) {
            [outPoint addObject:[NSNumber numberWithFloat:out_point[i]]];
        }
        delete [] out_point;
    }
    
    NSMutableArray *outNormal = nil;
    if(out_normal){
        outNormal = [NSMutableArray new];
        for (int i = 0; i < out_point_len; i++) {
            [outNormal addObject:[NSNumber numberWithFloat:out_normal[i]]];
        }
        delete [] out_normal;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"outPoint"] = outPoint;
    dic[@"outNormal"] = outNormal;
    
    return dic;
}
+(NSArray *)findPointClosetColorWithInPoint:(float *)inPoint withInColor:(UInt8 *)inColor withInPointLen:(int)inPointLen withInDestPoint:(float*)inDestPoint withInDestPointLen:(int)inDestPointLen
{
    UInt8 *out_color = NULL;
    
    i2::findPointClosestColor(inPoint, inColor, inPointLen, inDestPoint, inDestPointLen, &out_color);
    
    NSMutableArray *outColor = nil;
    if(out_color){
        outColor = [NSMutableArray new];
        for (int i = 0; i < inDestPointLen; i++) {
            [outColor addObject:[NSNumber numberWithUnsignedChar:out_color[i]]];
        }
        delete [] out_color;
    }
    return outColor;
}

+(NSDictionary *)processFrameWithWithInPoint:(float *)inPoint withInColor:(UInt8 *)inColor withInPointLen:(int)inPointLen // new frame data
                                withInPoint2:(float *)inPoint2 withInNormal2:(float *)inNormal2 withInColor2:(UInt8 *)inColor2 withInPointLen2:(int)inPointLen2 // aggregated data
                                 withInBBMin:(NSArray *)inBBMin withInBBMax:(NSArray *)inBBMax // bb box
                        withInSearchDistance:(float)inSearchDistance withInPtsProp:(float)inPtsProp withInTolerance:(float)inTolerance withInMaxIteration:(int)inMaxIteration // registration params
                        withInVoxelSizeInput:(float)inVoxelSizeInput withInVoxelSizeOutput:(float)inVoxelSizeOutput// decimation params
                                   withInKnn:(int)inKnn // normal params
{
    
    
    float *in_bb_min = new float[inBBMin.count];
    float *in_bb_max = new float[inBBMin.count];
    for(int i = 0; i < inBBMin.count; i++){
        in_bb_min[i] = [[inBBMin objectAtIndex:i] floatValue];
        in_bb_max[i] = [[inBBMax objectAtIndex:i] floatValue];
    }
    
    float *out_point = NULL;
    float *out_normal = NULL;
    uint8_t *out_color = NULL;
    int out_point_len = 0;
    
    bool success = i2::processFrame(inPoint, inColor, inPointLen, inPoint2, inNormal2, inColor2, inPointLen2, &out_point, &out_normal, &out_color, &out_point_len, in_bb_min, in_bb_max, inSearchDistance, inPtsProp, inTolerance, inMaxIteration, inVoxelSizeInput, inVoxelSizeOutput, inKnn);
    
    NSMutableArray *outPoint = [NSMutableArray new];
    for(int i = 0; i < out_point_len; i ++){
        [outPoint addObject:[NSNumber numberWithFloat:out_point[i]]];
    }
    delete [] out_point;
    
    NSMutableArray *outNormal = nil;
    if( out_normal){
        outNormal = [NSMutableArray new];
        for(int i = 0; i < out_point_len; i ++){
            [outNormal addObject:[NSNumber numberWithFloat:out_normal[i]]];
        }
        
        delete [] out_normal;
    }
    
    NSMutableArray *outColorArray = nil;
    if(out_color){
        outColorArray = [NSMutableArray new];
        for (int i = 0; i < out_point_len; i++) {
            [outColorArray addObject:[NSNumber numberWithUnsignedInt:out_color[i]]];
        }
        delete [] out_color;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"success"] = [NSNumber numberWithBool:success];
    dic[@"outPoint"] = outPoint;
    dic[@"outNormal"] = outNormal;
    dic[@"outColor"] = outColorArray;
    
    return dic;
}

@end

