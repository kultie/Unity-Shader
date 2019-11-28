Shader "Learn/Post Processing/Glow"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _Color ("Glow Color", Color) = (1,1,1,1)
        _Distance("Distance", Range(10,20)) = 15
        _OuterStrength("Outer Strength", Range(0,20)) = 10
        _InnerStrength("Inner Strenth", Range(0,20)) = 10
        _FilterClamp("Filter Clamp", Vector) = (0,0,0,0)
        _Quality("Quality", Range(0.01,1)) = 0.01
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
            #define PI 3.14159265358979323846264

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
            fixed4 _Color;
            int _Distance;
            int _OuterStrength;
            int _InnerStrength;
            float4 _FilterClamp;
            float _Quality;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 px = float2(1/_ScreenParams.x, 1/_ScreenParams.y);
                fixed4 ownColor = tex2D(_MainTex,i.uv);
                fixed4 curColor;
                float totalAlpha = 0;
                float maxTotalAlpha = 0;
                float cosAngle;
                float sinAngle;
                float2 displaced;

                for(float angle = 0; angle <= PI * 2; angle += (1/_Quality/_Distance)){
                    cosAngle = cos(angle);
                    sinAngle = sin(angle);
                    for(float curDistance = 1.0; curDistance <= _Distance; curDistance++){
                        displaced.x = i.vertex.x + cosAngle * curDistance * px.x;
                        displaced.y = i.vertex.y + sinAngle * curDistance * px.y;
                        curColor = tex2D(_MainTex, float2(displaced.x,displaced.y));
                        totalAlpha += (_Distance - curDistance) * curColor.a;
                        maxTotalAlpha += (_Distance - curDistance);
                    }
                }
                maxTotalAlpha = max(maxTotalAlpha,0.0001);
                ownColor.a = max (ownColor.a, 0.0001);
                ownColor.rgb = ownColor.rgb / ownColor.a;
                float outerGlowAlpha = (totalAlpha/maxTotalAlpha) * _OuterStrength * (1 - ownColor.a);
                float innerGlowAlpha = ((maxTotalAlpha - totalAlpha)/ maxTotalAlpha) * _InnerStrength * ownColor.a;
                float resultAlpha = (ownColor.a + outerGlowAlpha);
                return fixed4(lerp(lerp(ownColor.rgb,_Color.rgb, innerGlowAlpha/ownColor.a),_Color.rgb,outerGlowAlpha/resultAlpha) * resultAlpha,resultAlpha);
            }
            ENDCG
        }
    }
}
