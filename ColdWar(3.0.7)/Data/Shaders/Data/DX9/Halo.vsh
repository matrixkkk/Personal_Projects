/************************************************************************
Copyright (C) 1999, 2000 NVIDIA Corporation
*************************************************************************/

#include "HaloConstants.h"

// v0  -- position
// v1  -- normal
// CV_SCALING = (edgesize, 0.0f, 0.0f, 0.0f)

vs_1_1

dcl_position v0
dcl_normal v1

mul r4, v1, c[CV_SCALING].xxxy
add r4, v0, r4

// transform position
dp4 oPos.x, r4, c[CV_WORLDVIEWPROJ_0]
dp4 oPos.y, r4, c[CV_WORLDVIEWPROJ_1]
dp4 oPos.z, r4, c[CV_WORLDVIEWPROJ_2]
dp4 oPos.w, r4, c[CV_WORLDVIEWPROJ_3]

// transform normal
dp3 r0.x, v1, c[CV_WORLD_IT_0]
dp3 r0.y, v1, c[CV_WORLD_IT_1]
dp3 r0.z, v1, c[CV_WORLD_IT_2]

// normalize normal
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0, r0, r0.w

// compute world space position
dp4 r1.x, r4, c[CV_WORLD_0]
dp4 r1.y, r4, c[CV_WORLD_1]
dp4 r1.z, r4, c[CV_WORLD_2]

// vector from point to eye
add r2.xyz, c[CV_EYE], -r1

// normalize e
dp3 r2.w, r2, r2
rsq r2.w, r2.w
mul r2, r2, r2.w

//alpha value
dp3 oD0.w, r0, r2

mov oD0.xyz, c[CV_COLOR]
