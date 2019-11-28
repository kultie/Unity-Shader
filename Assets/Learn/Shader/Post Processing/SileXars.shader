Shader "Learn/Post Processing/SileXars"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
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
            #define t  _Time[1];
            // #define r _ScreenParams.xy;

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

            fixed4 frag (v2f index) : SV_Target
            {
                float2 uv = index.uv;

                float3 wave_color = float3(0.0,0.0,0.0);
                float iTime = _Time[1];
                float wave_width = 0.0;
                uv  = -3.0 + 2.0 * uv;
                uv.y += 0.0;
                for(float i = 0.0; i <= 28.0; i++) {
                    uv.y += (0.2+(0.9*sin(iTime*0.4) * sin(uv.x + i/3.0 + 3.0 *iTime )));
                    uv.x += 1.7* sin(iTime*0.4);
                    wave_width = abs(1.0 / (200.0*abs(cos(iTime)) * uv.y));
                    wave_color += float3(wave_width *( 0.4+((i+1.0)/18.0)), wave_width * (i / 9.0), wave_width * ((i+1.0)/ 8.0) * 1.9);
                }

                return float4(wave_color, 1.0);
            }
            ENDCG
        }       
    }
}
