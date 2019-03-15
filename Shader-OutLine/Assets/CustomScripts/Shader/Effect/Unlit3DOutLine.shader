Shader "Custom/Unlit3DOutLine"
{
    Properties
    {
		[NoScaleOffset]
        _MainTex("Texture", 2D) = "white" {}

		[Toggle]_UseVert("Use Vert", Float) = 0

		_OutLineColor("OutLineColor", Color) = (0.1, 0.1, 0.1, 1)

		_OutLineSize("OutLineSize", Range(0, 2)) = 0
    }

    SubShader
    {
        Tags { 
			"RenderType"="Geometry"
		}

		Pass {
			Cull Front

			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

			fixed4 _OutLineColor;

			fixed _OutLineSize;

			v2f vert(appdata v) {
				v2f o;

				v.vertex.xyz += v.normal * _OutLineSize;

				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return _OutLineColor;
			}

			ENDCG
		}

        Pass
        {
			Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#pragma shader_feature _USEVERT_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				fixed4 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);

				#ifdef _USEVERT_ON

				//ローカルにあった法線ベクトルをワールド空間に変換する
				fixed nl = max(0, dot(UnityObjectToWorldNormal(v.normal).xyz, _WorldSpaceLightPos0.xyz));

				if(nl <= 0.01)
					nl = 0.1;
				else if(nl < 0.3)
					nl = 0.3;
				else
					nl = 1;

				o.color = fixed4(nl, nl, nl, 1);

				#endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				#ifdef _USEVERT_ON

				return i.color;

				#endif

				fixed nl = max(0, dot(i.normal, _WorldSpaceLightPos0.xyz));

				if(nl <= 0.01) {
					nl = 0.1;
				} else if(nl < 0.3) {
					nl = 0.3;
				} else {
					nl = 1.0;
				}

				return fixed4(nl, nl, nl, 1);
            }
            ENDCG
        }
    }
}
