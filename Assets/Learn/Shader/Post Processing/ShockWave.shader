Shader "Learn/Post Processing/ShockWave"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _Amplitude("Amplitude", Range(1,100)) = 1
        _WaveLength("Wave Length", Range(2,400)) = 2
        _Brightness("Brightness", Range(0.2,2)) = 0.2
        _Radius("Radius", Range(100,2000)) = 2000
        _Speed("Speed", Range(800,1000)) = 1
        _Position("Position", Vector) = (0,0,0,0)
        _StartWave("Start Wave", float) = 0
        _CurrentTime("Current Time", float) = 0
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
            #define PI 3.141592654

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
            int _Amplitude;
            int _WaveLength;
            float _Brightness;
            int _Radius;
            float2 _Position;
            int _Speed;
            float _StartWave;
            float _CurrentTime;

            fixed4 frag (v2f i) : SV_Target
            {
                if(_StartWave == 1){
                    float halfWavelength = _WaveLength * 0.5 / _ScreenParams.x;
                    float maxRadius = _Radius / _ScreenParams.x;
                    float currentRadius = (_Time[1] - _CurrentTime) * _Speed / _ScreenParams.x;

                    float fade = 1;

                    if (maxRadius > 0){
                        if(currentRadius > maxRadius){
                            fixed4 col = tex2D(_MainTex, i.uv);
                            return col;
                        }
                        fade = 1.0 - pow(currentRadius/maxRadius,2);
                    }

                    float2 dir = float2(i.uv - _Position);
                    dir.y *= _ScreenParams.y / _ScreenParams.x;
                    float dist = length(dir);

                    if(dist <= 0 || dist < currentRadius - halfWavelength || dist > currentRadius + halfWavelength){
                        fixed4 col = tex2D(_MainTex,i.uv);
                        return col;
                    }

                    float2 diffUV = normalize(dir);
                    float diff = (dist - currentRadius) / halfWavelength;
                    float p = 1.0 - pow(abs(diff), 2);
                    float powDiff = 1.25 * sin(diff * PI) * p * (_Amplitude * fade);

                    float2 offset = diffUV * powDiff / _ScreenParams.xy;

                    float2 coord = i.uv + offset;
                    fixed4 col = tex2D(_MainTex, coord);
                    col.rgb *= 1 + (_Brightness - 1) * p * fade;
                    return col;
                }
                else{
                    fixed4 col = tex2D(_MainTex, i.uv);
                    return col;
                }
            }
            ENDCG
        }
    }
}
