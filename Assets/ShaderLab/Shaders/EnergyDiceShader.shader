Shader "ShaderLab/EnergyDiceShader"
{
    Properties
    {
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _EnergyColor("Energy Color", Color) = (0.1, 0.6, 1.0)
        _EnergyIntensity("Energy Intensity", Range(0, 10)) = 2.0
        _NoiseTex("Noise Texture", 2D) = "white" {}
        
        _DistortionStrength("Noise Distortion Strength", Range(0, 2)) = 0.2
        _DistortionSpeed("Distortion Speed", Range(0, 2)) = 0.5
        _CoreSpeed("Core Speed", Range(0, 2)) = 1.0
        _DistortionDirection("Distortion Direction", Vector) = (1.0, 0.0, 0.0, 0.0)
        _CoreDirection("Core Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
        
        _EdgeBrightness("Edge Brightness", range(0, 10)) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Blend One Zero
            ZWrite On
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL; 
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float2 uv : TEXCOORD0;
            };
            
            TEXTURE2D(_NoiseTex); 
            SAMPLER(sampler_NoiseTex);
            
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float3 _EnergyColor;
                float _DistortionStrength;
                float _EnergyIntensity;
                float _EdgeBrightness;
                float _DistortionSpeed;
                float _CoreSpeed;
                float4 _DistortionDirection;
                float4 _CoreDirection;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 viewDirection = normalize(GetCameraPositionWS() - IN.positionWS);
                float fresnel = 1.0 - saturate(dot(IN.normalWS, viewDirection));
                
                float2 distortionUV = IN.uv; 
                distortionUV += _DistortionDirection.xy * _Time.y * _DistortionSpeed;
                float distortion = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, distortionUV).r;
                
                float2 noiseUV = IN.uv; 
                noiseUV += _CoreDirection * _Time.y * _CoreSpeed;
                noiseUV.y += distortion * _DistortionStrength; 
                float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;
               
                float core = smoothstep(0.2, 0.8, noise); 
                
                float3 coreColor = _BaseColor * core;
                float3 edgeColor = _EnergyColor * fresnel * _EdgeBrightness;
                
                float3 energyColor = (coreColor + edgeColor) * _EnergyIntensity;
                float alpha = lerp(0.5, 1.0, saturate(edgeColor));
                
                return float4(energyColor, alpha); 
            }
            ENDHLSL
        }
    }
}
