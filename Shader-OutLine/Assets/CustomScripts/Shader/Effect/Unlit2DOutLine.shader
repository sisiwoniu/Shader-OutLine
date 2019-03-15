Shader "Custom/Unlit2DOutLine"
{
    Properties
    {
		[PerRendererData]
        _MainTex ("Texture", 2D) = "white" {}

		_OutLineColor("OutLine Color", Color) = (0, 0, 0, 1)

		_OutLineSize("OutLine Size", Range(0, 10)) = 2
    }

    SubShader
    {
        Tags 
		{ 
			"RenderType"="Opaque"
			"Queue"="Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha

		Pass 
		{
			Name "2DOUTLINE"

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

			sampler2D _MainTex;

			fixed _OutLineSize;

			fixed4 _OutLineColor;

			fixed4 _MainTex_TexelSize;

			v2f vert(appdata i) 
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(i.vertex);

				o.uv = i.uv;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target 
			{
				fixed a = smoothstep(tex2D(_MainTex, i.uv).a, 0, 1);

				fixed2 offset = _OutLineSize * _MainTex_TexelSize.xy;

				a = ((tex2D(_MainTex, fixed2(i.uv.x, i.uv.y + offset.y)).a + tex2D(_MainTex, fixed2(i.uv.x, i.uv.y - offset.y)).a)) 
				+ ((tex2D(_MainTex, fixed2(i.uv.x + offset.x, i.uv.y)).a + tex2D(_MainTex, fixed2(i.uv.x - offset.x, i.uv.y)).a))
				+ (tex2D(_MainTex, i.uv.xy + offset).a + tex2D(_MainTex, i.uv.xy - offset).a)
				+ (tex2D(_MainTex, fixed2(i.uv.x - offset.x, i.uv.y + offset.y)).a + tex2D(_MainTex, fixed2(i.uv.x + offset.x, i.uv.y - offset.y)).a);

				_OutLineColor.a = saturate(a);

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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 color : COLOR;
            };

            sampler2D _MainTex;

			fixed4 _MainTex_TexelSize;

			fixed4 _OutLineColor;

			fixed4 _OutLineSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				col *= i.color;

				return col;
            }
            ENDCG
        }
    }
}
