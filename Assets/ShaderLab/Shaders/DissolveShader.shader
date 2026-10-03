Shader "ShaderLab/DissolveShader"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)

        _Noise ("Noise", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0,1)) = 0
        _EdgeWidth("Edge Width", Range(0, 0.5)) = 0.1
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
        _Speed("Speed", Range(0, 10)) = 1
        _Enabled("Enabled", Float) = 0
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
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);

            CBUFFER_START(UnityPerMaterial)

                float4 _BaseMap_ST;
                float4 _Color;
                float4 _EdgeColor;
                float _DissolveAmount;
                float _EdgeWidth;   
                float _Speed;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float noise = SAMPLE_TEXTURE2D(_Noise, sampler_Noise, IN.uv).r;
                
                float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                
                float dissolve = saturate(frac(_Time.y * _Speed));
                
                float distance = abs(noise - dissolve);
                float edge = 1.0 - smoothstep(0.0, _EdgeWidth, distance);
                edge *= step(0.001, dissolve);
                float3 color = baseColor.rgb + edge * _EdgeColor;

                clip(noise - dissolve);

                return float4(color, 1); 
            }

            ENDHLSL
        }
    }
}