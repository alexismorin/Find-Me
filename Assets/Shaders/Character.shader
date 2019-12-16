// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Character"
{
	Properties
	{
		_OutfitsMask("Outfits Mask", 2D) = "white" {}
		_ShirtColor("Shirt Color", Color) = (1,1,1,1)
		_ShoesColor("Shoes Color", Color) = (1,0,0,1)
		_PantsColor("Pants Color", Color) = (1,1,1,1)
		_SkinColor("Skin Color", Color) = (1,0.8866527,0.8160377,1)
		_ShoesLength("Shoes Length", Float) = 0.5
		_ShirtLength("Shirt Length", Float) = 0.5
		_PantsLength("Pants Length", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _SkinColor;
		uniform float4 _PantsColor;
		uniform sampler2D _OutfitsMask;
		uniform float4 _OutfitsMask_ST;
		uniform float _PantsLength;
		uniform float4 _ShirtColor;
		uniform float _ShirtLength;
		uniform float4 _ShoesColor;
		uniform float _ShoesLength;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_OutfitsMask = i.uv_texcoord * _OutfitsMask_ST.xy + _OutfitsMask_ST.zw;
			float4 tex2DNode1 = tex2D( _OutfitsMask, uv_OutfitsMask );
			float temp_output_33_0 = step( tex2DNode1.r , _PantsLength );
			float temp_output_27_0 = ( 1.0 - temp_output_33_0 );
			float4 lerpResult24 = lerp( _SkinColor , ( _PantsColor * temp_output_27_0 ) , temp_output_27_0);
			float temp_output_34_0 = step( tex2DNode1.g , _ShirtLength );
			float temp_output_28_0 = ( 1.0 - temp_output_34_0 );
			float4 lerpResult25 = lerp( lerpResult24 , ( _ShirtColor * temp_output_28_0 ) , temp_output_28_0);
			float temp_output_35_0 = step( tex2DNode1.b , _ShoesLength );
			float temp_output_29_0 = ( 1.0 - temp_output_35_0 );
			float4 lerpResult26 = lerp( lerpResult25 , ( _ShoesColor * temp_output_29_0 ) , temp_output_29_0);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV54 = dot( ase_worldNormal, ase_worldlightDir );
			float fresnelNode54 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV54, 2.0 ) );
			float temp_output_55_0 = step( fresnelNode54 , 0.4 );
			o.Emission = ( lerpResult26 * saturate( ( temp_output_55_0 + 0.5 ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
835;672;1335;593;3.01651;456.2105;1.662681;True;True
Node;AmplifyShaderEditor.RangedFloatNode;7;-529.7192,-363.0551;Inherit;False;Property;_PantsLength;Pants Length;7;0;Create;True;0;0;False;0;0.5;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-872.2091,55.5423;Inherit;True;Property;_OutfitsMask;Outfits Mask;0;0;Create;True;0;0;False;0;f56e4b710a208ac43b00788064ac9340;f56e4b710a208ac43b00788064ac9340;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-525.1205,-284.0495;Inherit;False;Property;_ShirtLength;Shirt Length;6;0;Create;True;0;0;False;0;0.5;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;33;-159.2182,-336.8111;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-532.5703,-186.2269;Inherit;False;Property;_ShoesLength;Shoes Length;5;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-184.1197,-740.945;Inherit;False;Property;_PantsColor;Pants Color;3;0;Create;True;0;0;False;0;1,1,1,1;0.3247597,0.5985394,0.7735849,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;27;38.58504,-378.7036;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;34;-149.3326,-197.0214;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;46.49524,-283.627;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;272.0459,-864.6602;Inherit;False;Property;_SkinColor;Skin Color;4;0;Create;True;0;0;False;0;1,0.8866527,0.8160377,1;1,0.8866527,0.8160377,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;54;479.0647,-2.204202;Inherit;False;Standard;WorldNormal;LightDir;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-192.2844,-566.8282;Inherit;False;Property;_ShirtColor;Shirt Color;1;0;Create;True;0;0;False;0;1,1,1,1;1,0.6302263,0.2971698,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;434.4848,-458.4193;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;35;-140.2893,-69.53851;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;452.4008,-311.4505;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-179.4625,-927.7236;Inherit;False;Property;_ShoesColor;Shoes Color;2;0;Create;True;0;0;False;0;1,0,0,1;0.4433962,0.3081464,0.2405215,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;24;727.0911,-427.9433;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;29;69.67423,-109.7522;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;55;765.5272,77.88096;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;988.8193,-245.3201;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;424.5783,-158.8277;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;1072.132,85.12137;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;1183.715,180.1056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;1155.535,-92.26926;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;49;1428.469,377.8074;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-258.4254,344.8245;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;36;-74.04759,154.4216;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;59;933.4678,211.6378;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;1229.469,344.8074;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;1353.478,125.4312;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-247.2365,181.1141;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;44;629.0517,400.5322;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;47;86.98312,419.1523;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;378.6871,224.9681;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;80.42301,275.5668;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;1216.469,435.8074;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;False;0;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-251.8653,488.41;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;41;-59.22128,310.4778;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;70.95642,97.48195;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;926.9098,320.3897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;46;-52.66117,454.0633;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1682.283,98.5811;Float;False;True;2;ASEMaterialInspector;0;0;Unlit;Character;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;33;0;1;1
WireConnection;33;1;7;0
WireConnection;27;0;33;0
WireConnection;34;0;1;2
WireConnection;34;1;6;0
WireConnection;28;0;34;0
WireConnection;21;0;4;0
WireConnection;21;1;27;0
WireConnection;35;0;1;3
WireConnection;35;1;5;0
WireConnection;22;0;3;0
WireConnection;22;1;28;0
WireConnection;24;0;19;0
WireConnection;24;1;21;0
WireConnection;24;2;27;0
WireConnection;29;0;35;0
WireConnection;55;0;54;0
WireConnection;25;0;24;0
WireConnection;25;1;22;0
WireConnection;25;2;28;0
WireConnection;23;0;2;0
WireConnection;23;1;29;0
WireConnection;52;0;55;0
WireConnection;53;0;52;0
WireConnection;26;0;25;0
WireConnection;26;1;23;0
WireConnection;26;2;29;0
WireConnection;49;0;50;0
WireConnection;49;1;51;0
WireConnection;40;0;6;0
WireConnection;36;0;1;1
WireConnection;36;1;38;0
WireConnection;59;0;55;0
WireConnection;59;1;43;0
WireConnection;45;0;26;0
WireConnection;45;1;53;0
WireConnection;38;0;7;0
WireConnection;44;0;43;0
WireConnection;47;0;35;0
WireConnection;47;1;46;0
WireConnection;43;0;39;0
WireConnection;43;1;42;0
WireConnection;43;2;47;0
WireConnection;42;0;34;0
WireConnection;42;1;41;0
WireConnection;48;0;5;0
WireConnection;41;0;1;2
WireConnection;41;1;40;0
WireConnection;39;0;33;0
WireConnection;39;1;36;0
WireConnection;56;0;55;0
WireConnection;56;1;44;0
WireConnection;46;0;1;3
WireConnection;46;1;48;0
WireConnection;0;2;45;0
ASEEND*/
//CHKSM=9EA0086AD397F72B671331CB8E5360343B169860