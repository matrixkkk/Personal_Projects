#line 2 "D:\���Ӻ긮��\Gamebryo 2.2 Source\Sdk\Win32\Shaders\Data\DX9\\Generated\\NiStandardMaterial\01000040-00000000-52143000-00000000-V.hlsl"
//---------------------------------------------------------------------------
// Constant variables:
//---------------------------------------------------------------------------

float4x4 g_World;
float4x4 g_ViewProj;
float4 g_MaterialEmissive;
float4 g_MaterialDiffuse;
float4 g_MaterialAmbient;
float4 g_AmbientLight;
float4 g_PointAmbient0;
float4 g_PointDiffuse0;
float4 g_PointSpecular0;
float4 g_PointWorldPosition0;
float4 g_PointAttenuation0;
float4 g_PointAmbient;
float4 g_PointDiffuse;
float4 g_PointSpecular;
float4 g_PointWorldPosition;
float4 g_PointAttenuation;
float4 g_PointAmbient2;
float4 g_PointDiffuse2;
float4 g_PointSpecular2;
float4 g_PointWorldPosition2;
float4 g_PointAttenuation2;
float4 g_DirAmbient0;
float4 g_DirDiffuse0;
float4 g_DirSpecular0;
float4 g_DirWorldPosition0;
float4 g_DirWorldDirection0;
float4 g_SpotAmbient0;
float4 g_SpotDiffuse0;
float4 g_SpotSpecular0;
float4 g_SpotWorldPosition0;
float4 g_SpotAttenuation0;
float4 g_SpotWorldDirection0;
float4 g_SpotSpotAttenuation0;
float4 g_SpotAmbient;
float4 g_SpotDiffuse;
float4 g_SpotSpecular;
float4 g_SpotWorldPosition;
float4 g_SpotAttenuation;
float4 g_SpotWorldDirection;
float4 g_SpotSpotAttenuation;
float4 g_SpotAmbient2;
float4 g_SpotDiffuse2;
float4 g_SpotSpecular2;
float4 g_SpotWorldPosition2;
float4 g_SpotAttenuation2;
float4 g_SpotWorldDirection2;
float4 g_SpotSpotAttenuation2;
float4 g_SpotAmbient3;
float4 g_SpotDiffuse3;
float4 g_SpotSpecular3;
float4 g_SpotWorldPosition3;
float4 g_SpotAttenuation3;
float4 g_SpotWorldDirection3;
float4 g_SpotSpotAttenuation3;
//---------------------------------------------------------------------------
// Functions:
//---------------------------------------------------------------------------

/*

    This fragment is responsible for applying the view projection transform
    to the input position. Additionally, this fragment applies the world 
    transform to the input position. 
    
*/

void TransformPosition(float3 Position,
    float4x4 World,
    out float4 WorldPos)
{

    // Transform the position into world space for lighting, and projected 
    // space for display
    WorldPos = mul( float4(Position, 1.0f), World );
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for applying the view projection transform
    to the input world position.
    
*/

void ProjectPositionWorldToProj(float4 WorldPosition,
    float4x4 ViewProjection,
    out float4 ProjPos)
{

    ProjPos = mul(WorldPosition, ViewProjection );
    
}
//---------------------------------------------------------------------------
/*

    This fragment is responsible for applying the world transform to the
    normal.
    
*/

void TransformNormal(float3 Normal,
    float4x4 World,
    out float3 WorldNrm)
{

    // Transform the normal into world space for lighting
    WorldNrm = mul( Normal, (float3x3)World );
    WorldNrm = normalize(WorldNrm);
    
}
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
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float2 UVSet0 : TEXCOORD0;

};

//---------------------------------------------------------------------------
// Output:
//---------------------------------------------------------------------------

struct Output
{
    float4 PosProjected : POSITION0;
    float4 DiffuseAccum : TEXCOORD0;
    float2 UVSet0 : TEXCOORD1;

};

//---------------------------------------------------------------------------
// Main():
//---------------------------------------------------------------------------

Output Main(Input In)
{
    Output Out;
	// Function call #0
    float4 WorldPos_CallOut0;
    TransformPosition(In.Position, g_World, WorldPos_CallOut0);

	// Function call #1
    ProjectPositionWorldToProj(WorldPos_CallOut0, g_ViewProj, Out.PosProjected);

	// Function call #2
    float3 WorldNrm_CallOut2;
    TransformNormal(In.Normal, g_World, WorldNrm_CallOut2);

	// Function call #3
    float3 VectorOut_CallOut3;
    NormalizeFloat3(WorldNrm_CallOut2, VectorOut_CallOut3);

	// Function call #4
    float3 Color_CallOut4;
    float Opacity_CallOut4;
    SplitColorAndOpacity(g_MaterialDiffuse, Color_CallOut4, Opacity_CallOut4);

	// Function call #5
    float3 AmbientAccumOut_CallOut5;
    float3 DiffuseAccumOut_CallOut5;
    float3 SpecularAccumOut_CallOut5;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(1), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_PointWorldPosition0, 
        g_PointAmbient0, g_PointDiffuse0, g_PointSpecular0, g_PointAttenuation0, 
        float3(-1.0, -1.0, 0.0), float3(1.0, 0.0, 0.0), 
        float4(1.0, 1.0, 1.0, 1.0), g_AmbientLight, float3(0.0, 0.0, 0.0), 
        float3(0.0, 0.0, 0.0), AmbientAccumOut_CallOut5, 
        DiffuseAccumOut_CallOut5, SpecularAccumOut_CallOut5);

	// Function call #6
    float3 AmbientAccumOut_CallOut6;
    float3 DiffuseAccumOut_CallOut6;
    float3 SpecularAccumOut_CallOut6;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(1), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_PointWorldPosition, g_PointAmbient, 
        g_PointDiffuse, g_PointSpecular, g_PointAttenuation, 
        float3(-1.0, -1.0, 0.0), float3(1.0, 0.0, 0.0), 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut5, 
        DiffuseAccumOut_CallOut5, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut6, DiffuseAccumOut_CallOut6, 
        SpecularAccumOut_CallOut6);

	// Function call #7
    float3 AmbientAccumOut_CallOut7;
    float3 DiffuseAccumOut_CallOut7;
    float3 SpecularAccumOut_CallOut7;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(1), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_PointWorldPosition2, 
        g_PointAmbient2, g_PointDiffuse2, g_PointSpecular2, g_PointAttenuation2, 
        float3(-1.0, -1.0, 0.0), float3(1.0, 0.0, 0.0), 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut6, 
        DiffuseAccumOut_CallOut6, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut7, DiffuseAccumOut_CallOut7, 
        SpecularAccumOut_CallOut7);

	// Function call #8
    float3 AmbientAccumOut_CallOut8;
    float3 DiffuseAccumOut_CallOut8;
    float3 SpecularAccumOut_CallOut8;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(0), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_DirWorldPosition0, g_DirAmbient0, 
        g_DirDiffuse0, g_DirSpecular0, float3(0.0, 1.0, 0.0), 
        float3(-1.0, -1.0, 0.0), g_DirWorldDirection0, 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut7, 
        DiffuseAccumOut_CallOut7, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut8, DiffuseAccumOut_CallOut8, 
        SpecularAccumOut_CallOut8);

	// Function call #9
    float3 AmbientAccumOut_CallOut9;
    float3 DiffuseAccumOut_CallOut9;
    float3 SpecularAccumOut_CallOut9;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(2), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_SpotWorldPosition0, g_SpotAmbient0, 
        g_SpotDiffuse0, g_SpotSpecular0, g_SpotAttenuation0, 
        g_SpotSpotAttenuation0, g_SpotWorldDirection0, 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut8, 
        DiffuseAccumOut_CallOut8, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut9, DiffuseAccumOut_CallOut9, 
        SpecularAccumOut_CallOut9);

	// Function call #10
    float3 AmbientAccumOut_CallOut10;
    float3 DiffuseAccumOut_CallOut10;
    float3 SpecularAccumOut_CallOut10;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(2), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_SpotWorldPosition, g_SpotAmbient, 
        g_SpotDiffuse, g_SpotSpecular, g_SpotAttenuation, g_SpotSpotAttenuation, 
        g_SpotWorldDirection, float4(1.0, 1.0, 1.0, 1.0), 
        AmbientAccumOut_CallOut9, DiffuseAccumOut_CallOut9, 
        float3(0.0, 0.0, 0.0), AmbientAccumOut_CallOut10, 
        DiffuseAccumOut_CallOut10, SpecularAccumOut_CallOut10);

	// Function call #11
    float3 AmbientAccumOut_CallOut11;
    float3 DiffuseAccumOut_CallOut11;
    float3 SpecularAccumOut_CallOut11;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(2), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_SpotWorldPosition2, g_SpotAmbient2, 
        g_SpotDiffuse2, g_SpotSpecular2, g_SpotAttenuation2, 
        g_SpotSpotAttenuation2, g_SpotWorldDirection2, 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut10, 
        DiffuseAccumOut_CallOut10, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut11, DiffuseAccumOut_CallOut11, 
        SpecularAccumOut_CallOut11);

	// Function call #12
    float3 AmbientAccumOut_CallOut12;
    float3 DiffuseAccumOut_CallOut12;
    float3 SpecularAccumOut_CallOut12;
    Light(WorldPos_CallOut0, VectorOut_CallOut3, int(2), bool(false), 
        float(1.0), float3(0.0, 0.0, 0.0), g_SpotWorldPosition3, g_SpotAmbient3, 
        g_SpotDiffuse3, g_SpotSpecular3, g_SpotAttenuation3, 
        g_SpotSpotAttenuation3, g_SpotWorldDirection3, 
        float4(1.0, 1.0, 1.0, 1.0), AmbientAccumOut_CallOut11, 
        DiffuseAccumOut_CallOut11, float3(0.0, 0.0, 0.0), 
        AmbientAccumOut_CallOut12, DiffuseAccumOut_CallOut12, 
        SpecularAccumOut_CallOut12);

	// Function call #13
    float3 Diffuse_CallOut13;
    float3 Specular_CallOut13;
    ComputeShadingCoefficients(g_MaterialEmissive, Color_CallOut4, 
        g_MaterialAmbient, float3(1.0, 1.0, 1.0), float3(0.0, 0.0, 0.0), 
        DiffuseAccumOut_CallOut12, AmbientAccumOut_CallOut12, bool(false), 
        Diffuse_CallOut13, Specular_CallOut13);

	// Function call #14
    CompositeFinalRGBAColor(Diffuse_CallOut13, Opacity_CallOut4, 
        Out.DiffuseAccum);

    Out.UVSet0 = In.UVSet0;
    return Out;
}
