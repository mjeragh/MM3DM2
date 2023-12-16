//
//  Ray.metal
//  MM3DUI
//
//  Created by Mohammad Jeragh on 24/07/2022.
//

#include <metal_stdlib>
#include <simd/simd.h>
#include <metal_atomic>
#include <metal_matrix>
#include <metal_simdgroup_matrix>

#import "Common.h"

using namespace metal;
using namespace raytracing;

//Matrix Computations
//https://www.tutorialspoint.com/cplusplus-program-to-find-inverse-of-a-graph-matrix
//#define N 4
//https://www.geeksforgeeks.org/adjoint-inverse-matrix/
//https://semath.info/src/inverse-cofactor-ex4.html
//#define N 4
float3x3 getCofactor(float4x4 A, int p, int q, int n)
{
    int i = 0, j = 0;
    float3x3 temp;
    // Looping for each element of the matrix
    for (int row = 0; row < n; row++)
    {
        for (int col = 0; col < n; col++)
        {
            //  Copying into temporary matrix only those element
            //  which are not in given row and column
            if (row != p && col != q)
            {
                temp[i][j++] = A[row][col];
 
                // Row is filled, so increase row index and
                // reset col index
                if (j == n - 1)
                {
                    j = 0;
                    i++;
                }
            }
        }
    }
    return temp;
}



float4x4 adjoint(float4x4 A, int N)
{
    float4x4 adj;
    float3x3 temp;
    if (N == 1)
    {
        adj[0][0] = 1;
        return adj;
    }
 
    // temp is used to store cofactors of A[][]
    int sign = 1;
 
    for (int i=0; i<N; i++)
    {
        for (int j=0; j<N; j++)
        {
            // Get cofactor of A[i][j]
            temp = getCofactor(A, i, j, N);
 
            // sign of adj[j][i] positive if sum of row
            // and column indexes is even.
            sign = ((i+j)%2==0)? 1: -1;
 
            // Interchanging rows and columns to get the
            // transpose of the cofactor matrix
            adj[j][i] = (sign)*(determinant(temp));
        }
    }
    return adj;
}

struct INVReturn {
    float det;
    float4x4 adj;
    float4x4 inv;
};

INVReturn INV(float4x4 M, int N) {
    INVReturn answer;
    float4x4 inv;
   answer.det = determinant(M);
   if (answer.det == 0) {
      return answer;
   }
   float4x4 adj = adjoint(M, N);
   for (int i=0; i<N; i++)
       for (int j=0; j<N; j++)
           inv[i][j] = adj[i][j]/float(answer.det);
    answer.adj = adj;
    answer.inv = inv;
   return answer;
}
//end Matrix

// Return type for a bounding box intersection function.
struct BoundingBoxIntersection {
    bool accept   ; // Whether to accept or reject the intersection.
    float4 distance ;            // Distance from the ray origin to the intersection point.
};


/*
 Custom sphere intersection function. The [[intersection]] keyword marks this as an intersection
 function. The [[bounding_box]] keyword means that this intersection function handles intersecting rays
 with bounding box primitives. To create sphere primitives, the sample creates bounding boxes that
 enclose the sphere primitives.
 
 The [[triangle_data]] and [[instancing]] keywords indicate that the intersector that calls this
 intersection function returns barycentric coordinates for triangle intersections and traverses
 an instance acceleration structure. These keywords must match between the intersection functions,
 intersection function table, intersector, and intersection result to ensure that Metal propagates
 data correctly between stages. Using fewer tags when possible may result in better performance,
 as Metal may need to store less data and pass less data between stages. For example, if you do not
 need barycentric coordinates, omitting [[triangle_data]] means Metal can avoid computing and storing
 them.
 
 The arguments to the intersection function contain information about the ray, primitive to be
 tested, and so on. The ray intersector provides this datas when it calls the intersection function.
 Metal provides other built-in arguments but this sample doesn't use them.
 */
BoundingBoxIntersection IntersectionFunction(BoundingBox boundingBox,
                                             ray ray
                                             )
{
    
    
    float3 tmin = boundingBox.minBounds;
    float3 tmax = boundingBox.maxBounds;
    
    float3 inverseDirection = 1 / ray.direction;
    
    int sign[3];
    sign[0]= (inverseDirection.x < 0);
    sign[1]= (inverseDirection.y < 0);
    sign[2]= (inverseDirection.z < 0);
    
    BoundingBoxIntersection ret;
    ret.accept = false;
    
    float3 bounds[2] = {tmin,tmax};
    
    tmin.x = (bounds[sign[0]].x - ray.origin.x) * inverseDirection.x;
    tmax.x = (bounds[1 - sign[0]].x - ray.origin.x) * inverseDirection.x;
    
    tmin.y = (bounds[sign[1]].y - ray.origin.y) * inverseDirection.y;
    tmax.y = (bounds[1 - sign[1]].y - ray.origin.y) * inverseDirection.y;
    
    float t0 = float(tmax.z);
    
    if ((tmin.x > tmax.y) || (tmin.y > tmax.x)){
        
        return ret;
    }
    
    
    
    if (tmin.y > tmin.x){
        tmin.x = tmin.y;
    }
    
    
    if (tmax.y < tmax.x){
        tmax.x = tmax.y;
    }
    
    tmin.z = (bounds[sign[2]].z - ray.origin.z) * inverseDirection.z;
    tmax.z = (bounds[1-sign[2]].z - ray.origin.z) * inverseDirection.z;
    
    
    
    if ((tmin.x > tmax.z) || (tmin.z > tmax.x)){
        
        return ret;
    }
    
    if (tmin.z > tmin.x){
        tmin.x = tmin.z;
        t0 = tmin.x;
    }
    
    if (tmax.z < tmax.x){
        tmax.x = tmax.z;
        t0 = tmax.x;
    }
    
    ret.accept = true;
    ret.distance =float4(ray.origin + ray.direction * t0, 1);
    return ret ;
}
 

float interpolate(ray r, float3 p){
    return length(p - float3(0,0,0)) / length(r.direction);
}


kernel void testKernel(constant Uniforms & uniforms [[buffer(1)]],
                       
                       constant NodeGPU *nodeGPU [[buffer(0)]],
                       device uint &selected [[buffer(2)]],
                       uint pid [[thread_position_in_grid]]){
    
//    atomic<int> min {0};
    ///Moving the CPU code to the GPU, although it should be calculated only once but for now it is fine
    ///November 23
    
    float clipX = (2 * uniforms.point.x) / uniforms.width - 1;
    float clipY = 1 - (2 * uniforms.point.y) / uniforms.height;
    float4 clipCoords = float4(clipX, clipY, 0, 1); // Assume clip space is hemicube, -Z is into the screen
    
    float4 eyeRayDir = uniforms.projectionMatrix * clipCoords;
    eyeRayDir.z = 1;
    eyeRayDir.w = 0;
    
   
    
    float3 worldRayDir = (uniforms.viewMatrix * eyeRayDir).xyz;
    float3 direction = normalize(worldRayDir);
    
   
    float4 eyeRayOrigin = float4(0, 0, 0, 1);
    float3 origin = (uniforms.viewMatrix * eyeRayOrigin).xyz;
    ///the above was modified from swift to C++
    
    BoundingBoxIntersection answer;
    ray ray;
   // ray.origin = nodeGPU[pid].localRay.localOrigin;
    
    INVReturn INVanswer = INV(nodeGPU[pid].modelMatrix, 4);
    
    ray.origin = (INVanswer.inv * float4(origin,1)).xyz;
    
    // Map normalized pixel coordinates into camera's coordinate system.
   // ray.direction = nodeGPU[pid].localRay.localDirection;//normalize(uv.x * uniforms.right + uv.y * uniforms.up + uniforms.forward);
    ray.direction = direction;//(modalMatrixInverse * float4(uniforms.direction,0)).xyz;
    // Don't limit intersection distance.
    ray.max_distance = INFINITY;
   //intersector is not supported by anything lower than A13, not iOS14
   //I will move my intersector from CPU to the GPU
    
    //hit test with local ray
    
    answer = IntersectionFunction(nodeGPU[pid].boundingBox, ray);
//    nodeGPU[pid].debug = 1;
//    nodeGPU[pid].localRay.localDirection = ray.direction;
//    nodeGPU[pid].localRay.localOrigin = ray.origin;
//    nodeGPU[pid].parameter = INFINITY;//10000000000.0;
    if (answer.accept){
        
//        float3 worldPoint = (nodeGPU[pid].modelMatrix * answer.distance).xyz;
//        struct ray worldRay;
//        worldRay.origin = uniforms.origin;
//        worldRay.direction = uniforms.direction;
//        nodeGPU[pid].debug = 2;
//        nodeGPU[pid].parameter = interpolate(worldRay, worldPoint);
        selected = pid;
    }
    
}
