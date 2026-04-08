#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

void AllLights_float(float3 WorldPos, float3 WorldNormal, float Threshold,
    out float LightAmount, out float3 LightColor, out float ShadowAtten)
{
    #ifdef SHADERGRAPH_PREVIEW
        LightAmount = 0.7;
        LightColor = float3(1, 1, 1);
        ShadowAtten = 1;
    #else
        LightAmount = 0;
        LightColor = float3(0, 0, 0);
        ShadowAtten = 0;

        // 1. Main Light (Directional, si existe)
        float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
        Light mainLight = GetMainLight(shadowCoord);

        float mainNdotL = dot(WorldNormal, mainLight.direction) * 0.5 + 0.5;
        float mainStep = smoothstep(Threshold - 0.05, Threshold + 0.05, mainNdotL);
        float mainContrib = mainStep * mainLight.shadowAttenuation * mainLight.distanceAttenuation;

        LightAmount += mainContrib;
        LightColor += mainLight.color * mainContrib;
        ShadowAtten = max(ShadowAtten, mainLight.shadowAttenuation);

        // 2. Additional Lights (Point, Spot, etc.)
        int lightCount = GetAdditionalLightsCount();
        for (int i = 0; i < lightCount; i++)
        {
            Light addLight = GetAdditionalLight(i, WorldPos, half4(1,1,1,1));

            float addNdotL = dot(WorldNormal, addLight.direction) * 0.5 + 0.5;
            float addStep = smoothstep(Threshold - 0.05, Threshold + 0.05, addNdotL);
            float addContrib = addStep * addLight.shadowAttenuation * addLight.distanceAttenuation;

            LightAmount += addContrib;
            LightColor += addLight.color * addContrib;
            ShadowAtten = max(ShadowAtten, addLight.shadowAttenuation);
        }

        // Clamp para que no se pase de 1
        LightAmount = saturate(LightAmount);
        LightColor = max(LightColor, float3(0, 0, 0));
    #endif
}

#endif