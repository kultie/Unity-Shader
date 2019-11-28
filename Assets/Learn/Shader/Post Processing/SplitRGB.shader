Shader "Learn/Post Processing/SplitRGB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Red ("Red Offset", Vector) = (0,0,0,0)
        _Blue ("Blue Offset", Vector) = (0,0,0,0)
        _Green ("Green Offset", Vector) = (0,0,0,0)
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
            float4 _Red;
            float4 _Blue;
            float4 _Green;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 filterArea = _ScreenParams.xy;
                fixed4 col = tex2D(_MainTex, uv);
                col.r = tex2D(_MainTex, uv + _Red.xy / filterArea).r;
                col.g = tex2D(_MainTex, uv + _Green.xy / filterArea).g;
                col.b = tex2D(_MainTex, uv + _Blue.xy / filterArea).b;
                return col;
            }
            ENDCG
        }
    }
}
