#line 2 "D:\게임브리오\Gamebryo 2.2 Source\Sdk\Win32\Shaders\Data\DX9\\Generated\\NiStandardMaterial\0000430F-00000000-00000000-00280040-P.hlsl"
//---------------------------------------------------------------------------
// Constant variables:
//---------------------------------------------------------------------------

float4 g_AmbientLight;
float4 g_MaterialEmissive;
float4 g_MaterialDiffuse;
float4 g_MaterialAmbient;
sampler Normal;
sampler Base;
float4 g_DirAmbient0;
float4 g_DirDiffuse0;
float4 g_DirSpecular0;
float4 g_DirWorldPosition0;
float4 g_DirWorldDirection0;
float4 g_DirAmbient;
float4 g_DirDiffuse;
float4 g_DirSpecular;
float4 g_DirWorldPosition;
float4 g_DirWorldDirection;
float4 g_DirAmbient2;
float4 g_DirDiffuse2;
float4 g_DirSpecular2;
float4 g_DirWorldPosition2;
float4 g_DirWorldDirection2;
float4 g_DirAmbient3;
float4 g_DirDiffuse3;
float4 g_DirSpecular3;
float4 g_DirWorldPosition3;
float4 g_DirWorldDirection3;
sampler Glow;
//---------------------------------------------------------------------------
// Functions:
//---------------------------------------------------------------------------

/*

    This fragment is responsible for normalizing a float3.
    
*/

void NormalizeFloat3(float3 VectorIn,
    out float3 VectorOut)
{

    VectorOut = normalize(VectorIn);
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for sampling a texture and returning its value
    as a RGB value and an A value.
    
*/

void TextureRGBASample(float2 TexCoord,
    sampler Sampler,
    bool Saturate,
    out float4 ColorOut)
{

    ColorOut = tex2D(Sampler, TexCoord);
    if (Saturate)
    {
        ColorOut = saturate(ColorOut);
    }
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for sampling a texture and returning its value
    as a RGB value.
    
*/

void TextureRGBSample(float2 TexCoord,
    sampler Sampler,
    bool Saturate,
    out float3 ColorOut)
{

    ColorOut.rgb = tex2D(Sampler, TexCoord).rgb;
    if (Saturate)
    {
        ColorOut.rgb = saturate(ColorOut.rgb);
    }
    
}
//---------------------------------------------------------------------------
/*

    Separate a float4 into a float3 and a float.   
    
*/

void SplitColorAndOpacity(float4 ColorAndOpacity,
    out float3 Color,
    out float Opacity)
{

    Color.rgb = ColorAndOpacity.rgb;
    Opacity = ColorAndOpacity.a;
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for sampling a normal map to generate the
    new world-space normal.
    
    The normal map type is an enumerated value that indicates the following:
        0 - Standard (rgb = normal/binormal/tangent)
        1 - DXN (rg = normal.xy need to calculate z)
        2 - DXT5 (ag = normal.xy need to calculate z)
    
*/

void CalculateNormalFromColor(float4 NormalMap,
    float3 WorldNormalIn,
    float3 WorldBinormalIn,
    float3 WorldTangentIn,
    int NormalMapType,
    out float3 WorldNormalOut)
{

    
    NormalMap = NormalMap * 2.0 - 1.0;
    
    // Do nothing extra for Standard
    // Handle compressed types:
    if (NormalMapType == 1) // DXN
    {
        NormalMap.rgb = float3(NormalMap.r, NormalMap.g, 
            sqrt(1 - NormalMap.r * NormalMap.r - NormalMap.g * NormalMap.g));
    }
    else if (NormalMapType == 2) // DXT5
    {
        NormalMap.rg = NormalMap.ag;
        NormalMap.b = sqrt(1 - NormalMap.r*NormalMap.r -  
            NormalMap.g * NormalMap.g);
    }
       
    float3x3 xForm = float3x3(WorldTangentIn, WorldBinormalIn, WorldNormalIn);
    xForm = transpose(xForm);
    WorldNormalOut = mul(xForm, NormalMap.rgb);
    
    WorldNormalOut = normalize(WorldNormalOut);
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for accumulating the effect of a light
    on the current pixel.
    
    LightType can be one of three values:
        0 - Directional
        1 - Point 
        2 - Spot
        
    Note that the LightType must be a compile-time variable,
    not a runtime constant/uniform variable on most Shader Model 2.0 cards.
    
    The compiler will optimize out any constants that aren't used.
    
    Attenuation is defined as (const, linear, quad, range).
    Range is not implemented at this time.
    
    SpotAttenuation is stored as (cos(theta/2), cos(phi/2), falloff)
    theta is the angle of the inner cone and phi is the angle of the outer
    cone in the traditional DX manner. Gamebryo only allows setting of
    phi, so cos(theta/2) will typically be cos(0) or 1. To disable spot
    effects entirely, set cos(theta/2) and cos(phi/2) to -1 or lower.
    
*/

void Light(float4 WorldPos,
    float3 WorldNrm,
    int LightType,
    bool SpecularEnable,
    float Shadow,
    float3 WorldViewVector,
    float4 LightPos,
    float3 LightAmbient,
    float3 LightDiffuse,
    float3 LightSpecular,
    float3 LightAttenuation,
    float3 LightSpotAttenuation,
    float3 LightDirection,
    float4 SpecularPower,
    float3 AmbientAccum,
    float3 DiffuseAccum,
    float3 SpecularAccum,
    out float3 AmbientAccumOut,
    out float3 DiffuseAccumOut,
    out float3 SpecularAccumOut)
{
   
    // Get the world space light vector.
    float3 LightVector;
    float DistanceToLight;
        
    if (LightType == 0)
    {
        LightVector = -LightDirection;
    }
    else
    {
        LightVector = LightPos - WorldPos;
        DistanceToLight = length(LightVector);
        LightVector = LightVector / DistanceToLight;
    }
    
    // Take N dot L as intensity.
    float LightNDotL = dot(LightVector, WorldNrm);
    float LightIntensity = max(0, LightNDotL);

    float Attenuate = 1.0;
    
    if (LightType != 0)
    {
        // Attenuate Here
        Attenuate = LightAttenuation.x +
            LightAttenuation.y * DistanceToLight +
            LightAttenuation.z * DistanceToLight * DistanceToLight;
        Attenuate = max(1.0, Attenuate);
        Attenuate = 1.0 / Attenuate;

        if (LightType == 2)
        {
            // Get intensity as cosine of light vector and direction.
            float CosAlpha = dot(-LightVector, LightDirection);

            // Factor in inner and outer cone angles.
            CosAlpha = saturate((CosAlpha - LightSpotAttenuation.y) / 
                (LightSpotAttenuation.x - LightSpotAttenuation.y));

            // Power to falloff.
            CosAlpha = pow(CosAlpha, LightSpotAttenuation.z);

            // Multiply the spot attenuation into the overall attenuation.
            Attenuate *= CosAlpha;
        }

        LightIntensity = LightIntensity * Attenuate;
    }

    // Determine the interaction of diffuse color of light and material.
    // Scale by the attenuated intensity.
    DiffuseAccumOut = DiffuseAccum;
    DiffuseAccumOut.rgb += LightDiffuse.rgb * LightIntensity * Shadow;

    // Determine ambient contribution - not affected by shadow
    AmbientAccumOut = AmbientAccum;
    AmbientAccumOut.rgb += LightAmbient.rgb * Attenuate;

    SpecularAccumOut = SpecularAccum;
    if (SpecularEnable)
    {
        // Get the half vector.
        float3 LightHalfVector = LightVector + WorldViewVector;
        LightHalfVector = normalize(LightHalfVector);

        // Determine specular intensity.
        float LightNDotH = max(0, dot(WorldNrm, LightHalfVector));
        float LightSpecIntensity = pow(LightNDotH, SpecularPower.x);
        
        //if (LightNDotL < 0.0)
        //    LightSpecIntensity = 0.0;
        // Must use the code below rather than code above.
        // Using previous lines will cause the compiler to generate incorrect
        // output.
        float SpecularMultiplier = LightNDotL > 0.0 ? 1.0 : 0.0;
        
        // Attenuate Here
        LightSpecIntensity = LightSpecIntensity * Attenuate * 
            SpecularMultiplier;
        
        // Determine the interaction of specular color of light and material.
        // Scale by the attenuated intensity.
        SpecularAccumOut.rgb += Shadow * LightSpecIntensity * LightSpecular;
    }
    
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for multiplying two floats.   
    
*/

void MultiplyFloat(float V1,
    float V2,
    out float Output)
{

    Output = V1 * V2;
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for computing the coefficients for the 
    following equations:
    
    Kdiffuse = MatEmissive + 
        MatAmbient * Summation(0...N){LightAmbientContribution[N]} + 
        MatDiffuse * Summation(0..N){LightDiffuseContribution[N]}
        
    Kspecular = MatSpecular * Summation(0..N){LightSpecularContribution[N]}
    
    
*/

void ComputeShadingCoefficients(float3 MatEmissive,
    float3 MatDiffuse,
    float3 MatAmbient,
    float3 MatSpecular,
    float3 LightSpecularAccum,
    float3 LightDiffuseAccum,
    float3 LightAmbientAccum,
    bool Saturate,
    out float3 Diffuse,
    out float3 Specular)
{

    Diffuse = MatEmissive + MatAmbient * LightAmbientAccum + 
        MatDiffuse * LightDiffuseAccum;
    Specular = MatSpecular * LightSpecularAccum;
    
    if (Saturate)
    {
        Diffuse = saturate(Diffuse);
        Specular = saturate(Specular);
    }
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for multiplying two float3's.   
    
*/

void MultiplyFloat3(float3 V1,
    float3 V2,
    out float3 Output)
{

    Output = V1 * V2;
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for adding two float3's.   
    
*/

void AddFloat3(float3 V1,
    float3 V2,
    out float3 Output)
{

    Output = V1 + V2;
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for computing the final RGB color.
    
*/

void CompositeFinalRGBColor(float3 DiffuseColor,
    float3 SpecularColor,
    out float3 OutputColor)
{

    OutputColor.rgb = DiffuseColor.rgb + SpecularColor.rgb;
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for computing the final RGBA color.
    
*/

void CompositeFinalRGBAColor(float3 FinalColor,
    float FinalOpacity,
    out float4 OutputColor)
{

    OutputColor.rgb = FinalColor.rgb;
    OutputColor.a = saturate(FinalOpacity);
    
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// Input:
//---------------------------------------------------------------------------

struct Input
{
    float4 PosProjected : POSITION0;
    float4 WorldPos : TEXCOORD0;
    float3 WorldNormal : TEXCOORD1;
    float3 WorldBinormal : TEXCOORD2;
    float3 WorldTangent : TEXCOORD3;
    float2 UVSet0 : TEXCOORD4;

};

//---------------------------------------------------------------------------
// Output:
//---------------------------------------------------------------------------

struct Output
{
    float4 Color : COLOR0;

};

//---------------------------------------------------------------------------
// Main():
//---------------------------------------------------------------------------

Output Main(Input In)
{
    Output Out;
	// Function call #0
    float3 VectorOut_CallOut0;
    NormalizeFloat3(In.WorldNormal, VectorOut_CallOut0);

	// Function call #1
    float3 VectorOut_CallOut1;
    NormalizeFloat3(In.WorldTangent, VectorOut_CallOut1);

	// Function call #2
    float3 VectorOut_CallOut2;
    NormalizeFloat3(In.WorldBinormal, VectorOut_CallOut2);

	// Function call #3
    float4 ColorOut_CallOut3;
    TextureRGBASample(In.UVSet0, Normal, bool(false), ColorOut_CallOut3);

	// Function call #4
    float4 ColorOut_CallOut4;
    TextureRGBASample(In.UVSet0, Base, bool(false), ColorOut_CallOut4);

	// Function call #5
    float3 ColorOut_CallOut5;
    TextureRGBSample(In.UVSet0, Glow, bool(false), ColorOut_CallOut5);

	// Function call #6
    float3 Color_CallOut6;
    float Opacity_CallOut6;
    SplitColorAndOpacity(g_MaterialDiffuse, Color_CallOut6, Opacity_CallOut6);

	// Function call #7
    float3 Color_CallOut7;
    float Opacity_CallOut7;
    SplitColorAndOpacity(ColorOut_CallOut4, Color_CallOut7, Opacity_CallOut7);

	// Function call #8
    float3 WorldNormalOut_CallOut8;
    CalculateNormalFromColor(ColorOut_CallOut3, VectorOut_CallOut0, 
        VectorOut_CallOut2, VectorOut_CallOut1, int(0), WorldNormalOut_CallOut8);

	// Function call #9
    float3 AmbientAccumOut_CallOut9;
    float3 DiffuseAccumOut_CallOut9;
    float3 SpecularAccumOut_CallOut9;
    Light(In.WorldPos, WorldNormalOut_CallOut8, int(0), bool(false), float(1.0), 
        float3(0.0, 0.0, 0.0), g_DirWorldPosition0, g_DirAmbient0, 
        g_DirDiffuse0, g_DirSpecular0, float3(0.0, 1.0, 0.0), 
        float3(-1.0, -1.0, 0.0), g_DirWorldDirection0, 
        float4(1.0, 1.0, 1.0, 1.0), g_AmbientLight, float3(0.0, 0.0, 0.0), 
        float3(0.0, 0.0, 0.0), AmbientAccumOut_CallOut9, 
        DiffuseAccumOut_CallOut9, SpecularAccumOut_CallOut9);

	// Function call #10
    float Output_CallOut10;
    MultiplyFloat(Opacity_CallOut6, Opacity_CallOut7, Output_CallOut10);

	// Function call #11
    float3 AmbientAccumOut_CallOut11;
    float3 DiffuseAccumOut_CallOut11;
    float3 SpecularAccumOut_CallOut11;
    Light(In.WorldPos, WorldNormalOut_CallOut8, int(0), bool(false), float(1.0), 
        float3(0.0, 0.0, 0.0), g_DirWorldPosition, g_DirAmbient, g_DirDiffuse, 
        g_DirSpecular, float3(0.0, 1.0, 0.0), float3(-1.0, -1.0, 0.0), 
        g_DirWorldDirection, float4(1.0, 1.0, 1.0, 1.0), 
        AmbientAccumOut_CallOut9, DiffuseAccumOut_CallOut9, 
        float3(0.0, 0.0, 0.0), AmbientAccumOut_CallOut11, 
        DiffuseAccumOut_CallOut11, SpecularAccumOut_CallOut11);

	// Function call #12
    float3 AmbientAccumOut_CallOut12;
    float3 DiffuseAccumOut_CallOut12;
    float3 SpecularAccumOut_CallOut12;
    Light(In.WorldPos, WorldNormalOut_CallOut8, int(0), bool(false), float(1.0), 
        float3(0.0, 0.0, 0.0), g_DirWorldPosition2, g_DirAmbient2, 
        g_DirDiffuse2, g_DirSpecular2, float3(0.0, 1.0, 0.0), 
        float3(-1.0, -1.0, 0.0), g_DirWorldDirection2, 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut11, 
        DiffuseAccumOut_CallOut11, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut12, DiffuseAccumOut_CallOut12, 
        SpecularAccumOut_CallOut12);

	// Function call #13
    float3 AmbientAccumOut_CallOut13;
    float3 DiffuseAccumOut_CallOut13;
    float3 SpecularAccumOut_CallOut13;
    Light(In.WorldPos, WorldNormalOut_CallOut8, int(0), bool(false), float(1.0), 
        float3(0.0, 0.0, 0.0), g_DirWorldPosition3, g_DirAmbient3, 
        g_DirDiffuse3, g_DirSpecular3, float3(0.0, 1.0, 0.0), 
        float3(-1.0, -1.0, 0.0), g_DirWorldDirection3, 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut12, 
        DiffuseAccumOut_CallOut12, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut13, DiffuseAccumOut_CallOut13, 
        SpecularAccumOut_CallOut13);

	// Function call #14
    float3 Diffuse_CallOut14;
    float3 Specular_CallOut14;
    ComputeShadingCoefficients(g_MaterialEmissive, Color_CallOut6, 
        g_MaterialAmbient, float3(1.0, 1.0, 1.0), float3(0.0, 0.0, 0.0), 
        DiffuseAccumOut_CallOut13, AmbientAccumOut_CallOut13, bool(false), 
        Diffuse_CallOut14, Specular_CallOut14);

	// Function call #15
    float3 Output_CallOut15;
    MultiplyFloat3(Diffuse_CallOut14, Color_CallOut7, Output_CallOut15);

	// Function call #16
    float3 Output_CallOut16;
    AddFloat3(Output_CallOut15, ColorOut_CallOut5, Output_CallOut16);

	// Function call #17
    float3 OutputColor_CallOut17;
    CompositeFinalRGBColor(Output_CallOut16, Specular_CallOut14, 
        OutputColor_CallOut17);

	// Function call #18
    CompositeFinalRGBAColor(OutputColor_CallOut17, Output_CallOut10, Out.Color);

    return Out;
}

