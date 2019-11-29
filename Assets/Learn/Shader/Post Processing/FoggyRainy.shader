Shader "Learn/Post Processing/Foggy Rainy"
{
    //show values to edit in inspector
	Properties{
		[HideInInspector]_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("Blur Size", Range(0,0.5)) = 0
	    _Samples ("Quality", Range(10,100)) = 10
		[Toggle(GAUSS)] _Gauss ("Gaussian Blur", float) = 0
		[PowerSlider(3)]_StandardDeviation("Standard Deviation (Gauss only)", Range(0.00, 0.3)) = 0.02
        _Size("Size", range(1,10)) = 1
        _Distortion("Distortion", range(-5,5)) = 0
	}

	SubShader{
		// markers that specify that we don't need culling 
		// or reading/writing to the depth buffer
		Cull Off
		ZWrite Off 
		ZTest Always


		//Vertical Blur
		Pass{
			CGPROGRAM
			//include useful shader functions
			#include "UnityCG.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile
			#pragma shader_feature GAUSS

			//texture and transforms of the texture
			sampler2D _MainTex;
			float _BlurSize;
			float _StandardDeviation;
            int _Samples;

			#define PI 3.14159265359
			#define E 2.71828182846

			//the object data that's put into the vertex shader
			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//the data that's used to generate fragments and can be read by the fragment shader
			struct v2f{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//the vertex shader
			v2f vert(appdata v){
				v2f o;
				//convert the vertex positions from object space to clip space so they can be rendered
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{
			#if GAUSS
				//failsafe so we can use turn off the blur by setting the deviation to 0
				if(_StandardDeviation == 0)
				return tex2D(_MainTex, i.uv);
			#endif
				//init color variable
				float4 col = 0;
			#if GAUSS
				float sum = 0;
			#else
				float sum = _Samples;
			#endif
				//iterate over blur samples
				for(float index = 0; index < _Samples; index++){
					//get the offset of the sample
					float offset = (index/(_Samples-1) - 0.5) * _BlurSize;
					//get uv coordinate of sample
					float2 uv = i.uv + float2(0, offset);
				#if !GAUSS
					//simply add the color if we don't have a gaussian blur (box)
					col += tex2D(_MainTex, uv);
				#else
					//calculate the result of the gaussian function
					float stDevSquared = _StandardDeviation*_StandardDeviation;
					float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
					//add result to sum
					sum += gauss;
					//multiply color with influence from gaussian function and add it to sum color
					col += tex2D(_MainTex, uv) * gauss;
				#endif
				}
				//divide the sum of values by the amount of samples
				col = col / sum;
				return col;
			}

			ENDCG
		}

		//Horizontal Blur
		Pass{
			CGPROGRAM
			//include useful shader functions
			#include "UnityCG.cginc"

			#pragma multi_compile
			#pragma shader_feature GAUSS

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			//texture and transforms of the texture
			sampler2D _MainTex;
			float _BlurSize;
			float _StandardDeviation;
            int _Samples;

			#define PI 3.14159265359
			#define E 2.71828182846

					//the object data that's put into the vertex shader
			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//the data that's used to generate fragments and can be read by the fragment shader
			struct v2f{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//the vertex shader
			v2f vert(appdata v){
				v2f o;
				//convert the vertex positions from object space to clip space so they can be rendered
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{
			#if GAUSS
				//failsafe so we can use turn off the blur by setting the deviation to 0
				if(_StandardDeviation == 0)
				return tex2D(_MainTex, i.uv);
			#endif
				//calculate aspect ratio
				float invAspect = _ScreenParams.y / _ScreenParams.x;
				//init color variable
				float4 col = 0;
			#if GAUSS
				float sum = 0;
			#else
				float sum = _Samples;
			#endif
				//iterate over blur samples
				for(float index = 0; index < _Samples; index++){
					//get the offset of the sample
					float offset = (index/(_Samples-1) - 0.5) * _BlurSize * invAspect;
					//get uv coordinate of sample
					float2 uv = i.uv + float2(offset, 0);
				#if !GAUSS
					//simply add the color if we don't have a gaussian blur (box)
					col += tex2D(_MainTex, uv);
				#else
					//calculate the result of the gaussian function
					float stDevSquared = _StandardDeviation*_StandardDeviation;
					float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
					//add result to sum
					sum += gauss;
					//multiply color with influence from gaussian function and add it to sum color
					col += tex2D(_MainTex, uv) * gauss;
				#endif
				}
				//divide the sum of values by the amount of samples
				col = col / sum;
				return col;
			}

			ENDCG
		}
		 Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define S(a,b,t) smoothstep(a,b,t)

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
            float _Size,_Distortion;

            float N21(float2 p){
                p = frac(p * float2(123.34,345.45));
                p += dot(p,p+34.345);
                return frac(p.x * p.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = fmod(_Time.y,7200);
                fixed4 col = 0;

                float2 aspect = float2(2,1);
                float2 uv = i.uv * _Size * aspect;
                uv.y += t * .25;
                float2 gv = frac(uv) - .5;
                float2 id = floor(uv);

                float n= N21(id); //0~1

                t += n * 6.2831;
                float w = i.uv.y * 10;
                float x = (n-.5) * .8; //-.4 ~ .4
                x += (.4 - abs(x)) * sin(3 * w) * pow(sin(w), 6) * .45;

                float y = -sin(t+sin(t + sin(t) * .5)) * .45;
                y -= (gv.x-x) * (gv.x-x);


                float2 dropPos = (gv - float2(x,y))/aspect;
                float drop = S(.05,.03,length(dropPos));

                float2 trailPos = (gv - float2(x,t * .25))/aspect;
                trailPos.y = (frac(trailPos.y * 8)-.5)/8;
                float trail = S(.03,.01,length(trailPos));

                float fogTrail = S(-.05,.05,dropPos.y);
                fogTrail *= S(.5,y,gv.y);
                trail *= fogTrail;
                fogTrail *= S(.05,.04,abs(dropPos.x));

                col += fogTrail * .5;
                col+= trail;
                col += drop;
                col.rg = gv;

                float2 offSet = drop * dropPos + trail * trailPos;

                col = tex2D(_MainTex, i.uv + offSet * _Distortion);

                return col;
            }
            ENDCG
        }
	}
}
