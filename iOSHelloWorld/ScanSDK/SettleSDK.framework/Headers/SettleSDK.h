#ifndef LEO_SETTLE_SDK_H
#define LEO_SETTLE_SDK_H

#if WIN32
#define LEO_SETTLE_SDK_API __declspec(dllexport)
#define LEO_SETTLE_SDK_CALL __stdcall
#else
#define LEO_SETTLE_SDK_API
#define LEO_SETTLE_SDK_CALL
#endif

typedef void* LeoSettlerHandle;

typedef int LeoSettlerStatus;

#define     LEO_SETTLER_STATUS_UNSTABLE                 0
#define     LEO_SETTLER_STATUS_STABLE                   1
#define     LEO_SETTLER_STATUS_ROTATION_LIMIT_EXCEEDED  2


#ifdef __cplusplus
extern "C"
{
#endif

    LEO_SETTLE_SDK_API void LEO_SETTLE_SDK_CALL leoSettlerGetVersion(int* major, int* minor, int* patch);

    LEO_SETTLE_SDK_API LeoSettlerHandle LEO_SETTLE_SDK_CALL leoCreateSettler(
        const float* vertices, int numVertices, const int* triangles, int numTriangles,
        const float* initialTransformMat, float gravityDirX, float gravityDirY, float gravityDirZ);
    LEO_SETTLE_SDK_API void LEO_SETTLE_SDK_CALL leoDestroySettler(LeoSettlerHandle handle);
    LEO_SETTLE_SDK_API LeoSettlerStatus LEO_SETTLE_SDK_CALL leoSettlerStep(LeoSettlerHandle handle);
    LEO_SETTLE_SDK_API const float* LEO_SETTLE_SDK_CALL leoSettlerGetCurrentTransformation(const LeoSettlerHandle handle);
    LEO_SETTLE_SDK_API float LEO_SETTLE_SDK_CALL leoSettlerGetRotationAngle(const LeoSettlerHandle handle);

    LEO_SETTLE_SDK_API LeoSettlerStatus LEO_SETTLE_SDK_CALL leoSettleObject(
        const float* vertices, int numVertices, const int* triangles, int numTriangles, 
        const float* initialTransformMat, float gravityDirX, float gravityDirY, float gravityDirZ, int maxIterations, float maxRotationAngle,
        float* resultTransformMat, float* rotationAngle);

#ifdef __cplusplus
}
#endif


#endif