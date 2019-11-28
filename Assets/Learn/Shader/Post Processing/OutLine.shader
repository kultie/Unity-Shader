Shader "Learn/Post Processing/OutLine"
{
    Properties
    {
        [HideInInpspector]_MainTex ("Texture", 2D) = "white" {}
        _Thickness("Thickness", Range(0,100)) = 0
        _Color("Color", Color) = (0,0,0,1)
        _FilterClamp("Filter Clamp", Vector) = (0,0,0,0)
        _Step("Step", Range(1,20)) = 1
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
            int _Thickness;
            float _Step;
            fixed4 _Color;
            float4 _FilterClamp;

            const float PI = 3.14159265358979323846264;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 ownCol = tex2D(_MainTex, i.uv);
                fixed4 currentCol;

                float maxAlpha = 0.0;
                float2 displaced;

                float doublePI = PI * 2.0;
                float angleStep = PI  * 2.0 / _Step;


                for(float angle = 0; angle < doublePI; angle += angleStep){
                    displaced.x = i.uv.x + _Thickness * cos(angle);
                    displaced.y = i.uv.y + _Thickness * sin(angle);
                    currentCol = tex2D(_MainTex, clamp(displaced, _FilterClamp.xy, _FilterClamp.zw));
                    maxAlpha = max(maxAlpha, currentCol.a);
                }
                float result = max(maxAlpha, ownCol.a);
                fixed4 col = fixed4((ownCol.rgb + _Color.rgb * (1.0 - ownCol.a)) * result, result);
                return col;
            }
            ENDCG
        }
    }
}
