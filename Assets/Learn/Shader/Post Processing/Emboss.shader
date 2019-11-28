Shader "Learn/Post Processing/Emboss"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _Strength ("Strength", Range(0,20)) = 0
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
            int _Strength;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 onePixel = float2(1.0/_ScreenParams.xy);
                fixed4 col;

                col.rgb = float3(0.5,0.5,0.5);
                col -= tex2D(_MainTex, i.uv - onePixel) * _Strength;
                col += tex2D(_MainTex, i.uv + onePixel) * _Strength;

                fixed value = (col.r + col.g + col.b) / 3;
                col.rgb = float3(value,value,value);
                float alpha = tex2D(_MainTex, i.uv).a;
                return fixed4(col.rgb * alpha,alpha);

            }
            ENDCG
        }
    }
}
