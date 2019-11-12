Shader "Learn/Post Processing/NormalMapFilter"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _Strength ("Strength", Range(0.01,.1)) = 0.1
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
            float _Strength;
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                
                float x = 1;
                float y = 1;
                
                float M = abs(tex2D(_MainTex, uv + float2(0,0) / _ScreenParams.xy).r); 
                float L = abs(tex2D(_MainTex, uv + float2(x,0) / _ScreenParams.xy).r); 
                float R = abs(tex2D(_MainTex, uv + float2(-x,0) / _ScreenParams.xy).r); 
                float U = abs(tex2D(_MainTex, uv + float2(0,y) / _ScreenParams.xy).r); 
                float D = abs(tex2D(_MainTex, uv + float2(0,-y) / _ScreenParams.xy).r); 

                float X = ((R-M) + (M-L)) * 0.5;
                float Y = ((D-M) + (M-U)) * 0.5;

                float4 N = float4(normalize(float3(X,Y,_Strength)), 1.0);
                return fixed4(N.xyz * 0.5 + 0.5, 1.0);


            }
            ENDCG
        }
    }
}
