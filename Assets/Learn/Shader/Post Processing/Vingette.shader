Shader "Learn/Post Processing/Vingette"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _VRadius("Vignette Radius", Range(0.0, 1.0)) = 1.0
        _VSoft("Vignette Softness", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _VRadius;
            float _VSoft;

            float4 BlurSample (float2 uv, float uOffset = 0.0, float vOffset = 0.0) {
                uv += float2(uOffset * ddx(uv.x), vOffset * ddy(uv.y));
                return tex2D(_MainTex, uv);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = BlurSample(i.uv,0.1,0.1);
                float distFromCenter = distance(i.uv,float2(0.5,0.5));
                float vignette = smoothstep(_VRadius, _VRadius - _VSoft, distFromCenter);
                col = saturate(col*vignette);
                return col;
            }
            ENDCG
        }
    }
}
