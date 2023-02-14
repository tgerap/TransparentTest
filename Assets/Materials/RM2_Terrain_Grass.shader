Shader "RM2/Terrain/RM2_Grass"
{
    Properties
    {
    	[HelpURL(39ri60legu9i)]
        
		[Header (Surface Options)]
        [Space (10)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling", Float) = 0

        _Surface ("Surface", float) = 1
    	
    	[Toggle(_ALPHATEST_ON)]
        _AlphaClip ("Alpha Clipping", Float) = 1.0
        _Cutoff  ("Alpha Clip Threshold", Range(0.0, 1.0)) = 0.5
    	
    	[Toggle(_VIEW_FLIP_NORMAL)]
    	_EnableViewNormal ("Enable View Flip Normal" , Float) = 0.0
    	
    	[Space (5)]
    	[ToggleOff(_RECEIVE_SHADOWS_OFF)]        
        _ReceiveShadows ("Receive Shadows", Float) = 1.0
    	_ShadowBiasStrength ("Receive Shadow Strength", Range(0, 1)) = 0.0
        
        [Enum(Off,0,On,1)] _Coverage ("Alpha To Coverage", Float) = 0.0
    	
    	//_LightMapStrength ("LightMap Strength", Float) = 1.0
    	
        [Header (Surface Inputs)]
        [Space (10)] 
        _Color ("Base Color", Color) = (1,1,1,1)
        _BaseMap ("Albedo (RGB)", 2D) = "white" {}
    	
		[Header (Normal Inputs)]
        [Space (10)]
    	[Toggle(_NORMALMAP)]
        _EnableNormal ("Enable Normal Map", Float) = 1.0
        [NoScaleOffset]_BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Strength", Range(0.0, 3.0)) = 1.0
        _NormalBias ("Normal Bias", Range(0.0, 8.0)) = 0.0
    	
		[Header (Wind Inputs)]
        [Space (10)]
		_WindStrength ("Wind Strength", Float) = 0.18
    	_NormalStrength ("Normal StrengthTest", Float) = 1.0
    	_WindDirSize ("WindDir X Z", Vector) = (0.01,0.01,0.01,0.01)
    	_Jitter ("Jitter", Range(0.0, 1.0)) = 0.1
    	_WindTex ("WindTexture", 2D) = "white" {}
    	//_Metallic ("Metallic", Range(0.0, 1.0)) = 1.0
        //_Smoothness ("Smoothness", Range(0.0, 1.0)) = 1.0
        //_Occlusion ("Occlusion", Range(0.0, 1.0)) = 1.0
    	[Header (Advanced Option)]
        [Space (10)]
		_AmbientReflections ("Environment Relections Strength", Range(0.0, 1)) = 0.0
    }
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline"   "RenderType" = "TransparentCutout"   "Queue" = "AlphaTest" }
        
        //LOD (Level of Detail)
 		// 셰이더의 지원 레벨을 조정한다.
 		// 예) SubShader {LOD 200}, SubShader {LOD 100}이 있을 경우
 		// maximumLOD를 지정하지 않을 경우
  		// 디바이스가 지원하는 최대 레벨을 기준으로 SubShader가 적용된다.
 		// (최대가 1000이라고 가정하면 SubShader {LOD 200} 구문 사용)
 		// shader.maximumLOD = 100 처럼 셋팅할 경우 SubShader {LOD 100} 구문이 수행된다.
 		// material.shader.maximumLOD = 100 처럼 쓸 수 있다.
 		// Shader.globalMaximumLOD = 100 처럼 사용 시 모든 쉐이더를 세팅할 수 있다.
 		// 유니티에 내장된 셰이더들의 LOD는 아래와 같이 셋팅되어 있다.
 		// VertexLit kind of shaders = 100
 		// Decal, Reflective VertexLit = 150
 		// Diffuse = 200
 		// Diffuse Detail, Reflective Bumped Unlit, Reflective Bumped VertexLit = 250
 		// Bumped, Specular = 300
 		// Bumped Specular = 400
 		// Parallax = 500
 		// Parallax Specular = 600
				
        Pass
        {
        	Name "Universal Forward"
			Tags {"LightMode" = "UniversalForward"}
        	ZWrite On //Default Value
        	Cull [_Cull]
        	AlphaToMask [_Coverage]
        	
            HLSLPROGRAM
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma shader_feature_local _ALPHATEST_ON
			#pragma shader_feature_local _NORMALMAP
			#pragma shader_feature_local _VIEW_FLIP_NORMAL
	        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			//#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 staticLightmapUV : TEXCOORD1;
            	float4 color : COLOR;
            	UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;                
                float4 positionCS : SV_POSITION;
                //#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
				    float3 positionWS : TEXCOORD1;
				//#endif
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
            	
            	//#ifdef _ADDITIONAL_LIGHTS_VERTEX
			        half4 fogFactorAndVertexLight   : TEXCOORD4;
			    //#else
			    //    half  fogFactor                 : TEXCOORD4;
			    //#endif
            	//#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			        float4 shadowCoord : TEXCOORD5;
			   // #endif        

            	DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 6);
                float2 staticLightmapUV : TEXCOORD7;
            	float3 bitangentWS : TEXCOORD8;
            	float3 viewDirWS    : TEXCOORD9;
            	float4 surfaceColor : COLOR0;
            	float4 color : COLOR1;
            };

            CBUFFER_START(UnityPerMaterial)

				half4 _Color;
	            half4 _BaseMap_ST;
				half _Cutoff;
				half _AlphaClip;
				//half _Metallic;
				half _Smoothness;
				half _Occlusion;
				half _NormalBias;
				half _BumpScale;
				half _ReceiveShadowBias;
				half _WindStrength, _NormalStrength;
				half4 _WindDirSize;
				half _Jitter;
				
				half _AmbientReflections;
				half _ShadowBiasStrength;

            CBUFFER_END
            Texture2D _BaseMap;
			SamplerState sampler_BaseMap;
			Texture2D _BumpMap;
			Texture2D _WindTex;
            SamplerState sampler_WindTex;
            
            inline half3 TangentNormalToWorldNormal(float3 TangnetNormal, float3 T, float3  B, float3 N)
			{
				float3x3 TBN = float3x3(T, B, N);
				TBN = transpose(TBN);
				return mul(TBN, TangnetNormal);
			}
            
            Varyings LitPassVertex (Attributes input)
            {
                Varyings output = (Varyings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				//'VertexPositionInputs vertex_position_inputs = GetVertexPositionInputs(input.positionOS.xyz);
            	//법선좌표 변환
                //VertexNormalInputs vertex_normal_inputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

            	float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);;
            	half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
            	half4 wind = SAMPLE_TEXTURE2D_LOD(_WindTex, sampler_WindTex, (positionWS.xz), 10);
				
            	half windStrength = input.color.r * _WindStrength;
		        
            	windStrength *= wind.r;
		        float3 disp = sin((positionWS.x + positionWS.y + positionWS.z + _Time.y) * 10.0f) *
		        	normalWS * float3(1.0f, 0.35f, 1.0f);
		        positionWS += disp * windStrength * _Jitter; // * WindMultiplier.y;

		        positionWS.xz += _WindDirSize.xz * windStrength;
			    half2 normalWindDir = _WindDirSize.xz * _NormalStrength;
		        normalWS.xz += normalWindDir * windStrength;
				//  VertexPositionInputs
			    VertexPositionInputs vertexInput;
			    vertexInput.positionWS = positionWS;
			    vertexInput.positionVS = TransformWorldToView(positionWS);
			    vertexInput.positionCS = TransformWorldToHClip(positionWS);
			    float4 ndc = vertexInput.positionCS * 0.5f;
			    vertexInput.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
			    vertexInput.positionNDC.zw = vertexInput.positionCS.zw;

			//  VertexNormalInputs
			    VertexNormalInputs normalInput;
			    normalInput.normalWS = NormalizeNormalPerVertex(normalWS);
			    normalInput.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);

			    output.normalWS = normalInput.normalWS;
            	
			    #ifdef _NORMALMAP
			        real sign = input.tangentOS.w * GetOddNegativeScale();
			        half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
			        output.tangentWS = tangentWS;
			    #endif
            	
                //텍스쳐 스케일 및 오브셋을 대응하여 uv 정보 저장
				output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;//TRANSFORM_TEX(input.texcoord, _BaseMap);

            	half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
			    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

			    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
			    #ifdef DYNAMICLIGHTMAP_ON
			        output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
			    #endif
			    OUTPUT_SH(output.normalWS, output.vertexSH);

			    //#ifdef _ADDITIONAL_LIGHTS_VERTEX
			        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
			    //#else
			        //output.fogFactor = fogFactor;
			    //#endif

            	//#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
			        output.positionWS = positionWS;
			    //#endif

			   //#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			    output.shadowCoord = GetShadowCoord(vertexInput);
			   //#endif
				
			    output.positionCS = vertexInput.positionCS;
            	//return output;
				//#ifdef _MAIN_LIGHT_SHADOWS   
					//output.shadowCoord = float4(0,0,0,0);
				//#endif
				output.color = input.color;
            	#ifdef _ADDITIONAL_LIGHTS_VERTEX
			
					uint lightsCount = GetAdditionalLightsCount();
						for (uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
						{
							Light light = GetAdditionalLight(lightIndex, output.positionWS);
							half3 lightColor = light.color * light.distanceAttenuation;
							vertexLight += LightingLambert(lightColor, light.direction, output.normalWS) * 0.05;
						}
				#endif			    

			    return output;
            	
            }             
/*
			inline void InitializeSurfaceDataVegetation(Varyings input, out SurfaceData out_surface_data)
			{
				half4 albedoAlpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                
                out_surface_data.alpha = Alpha(albedoAlpha.a, _Color, _Cutoff);
                
            	out_surface_data.albedo = albedoAlpha.rgb * _Color;
            	out_surface_data.metallic = half(0.0);
            	out_surface_data.smoothness = _Smoothness;
            	out_surface_data.occlusion = half(0.0);
            	out_surface_data.emission = half(0.0);
            	out_surface_data.specular = half(0.0);

            	#if defined (_NORMALMAP)
                    float4 SampleNormal = SAMPLE_TEXTURE2D_BIAS(_BumpMap, sampler_BumpMap, input.uv, _NormalBias);
                    out_surface_data.normalTS = normalize(UnpackNormalScale(SampleNormal, _BumpScale));
                
                #else
                    out_surface_data.normalTS = half3(0,1,0);
                #endif
            	
            	
            	out_surface_data.clearCoatMask = half(0.0);
            	out_surface_data.clearCoatSmoothness = half(0.0);
            	
			}
*/
/*
            void InitializeInputData(Varyings input, half3 normalTS, out InputData input_data)
            {
                input_data = (InputData)0;
            	#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
				    input_data.positionWS = input.positionWS;
				#endif
                
                input_data.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                input_data.normalWS = input.normalWS;
                
                #ifdef _NORMALMAP
                    float3 bitangent = input.tangentWS.w * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    half3x3 TBN = half3x3(input.tangentWS.xyz, bitangent, input.normalWS.xyz);               
                    input_data.normalWS = TransformTangentToWorld(normalTS, TBN);
                    input_data.normalWS = NormalizeNormalPerPixel(input_data.normalWS);
                #endif
                
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    input_data.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    input_data.shadowCoord = TransformWorldToShadowCoord(input_data.positionWS + input.normalWS * _PBRLitShadowBias);
                #else
                    input_data.shadowCoord = float4(0, 0, 0, 0);
                #endif

                #if defined(DYNAMICLIGHTMAP_ON)
                    input_data.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
                #else
                    input_data.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input_data.normalWS);
                #endif
                
                #ifdef _ADDITIONAL_LIGHTS_VERTEX
			        input_data.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
			        input_data.vertexLighting = input.fogFactorAndVertexLight.yzw;
			    #else
			        input_data.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
			    #endif
                
            }
            */
            half4 LitPassFragment (Varyings input) : SV_Target
            {
				float3 viewDir = normalize(input.viewDirWS);
            	
            	//input.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				input.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
            	Light mainlight = GetMainLight(input.shadowCoord);
            	
            	
				float3 lightDir = mainlight.direction;
				//texture sampling
				half4 diffuse = _BaseMap.Sample(sampler_BaseMap, input.uv) * _Color;
				
            	#if defined _NORMALMAP
            		float4 SampleNormal = SAMPLE_TEXTURE2D_BIAS(_BumpMap, sampler_BaseMap, input.uv, _NormalBias);
                    half3 bump = normalize(UnpackNormalScale(SampleNormal, _BumpScale));
				    float3 worldNormal = TangentNormalToWorldNormal(bump, input.tangentWS, input.bitangentWS, input.normalWS);
				               		
                #else
				   float3 worldNormal = input.normalWS;				   
                #endif
				
            	#if defined (_VIEW_FLIP_NORMAL)
            		half3 normalViewFlip = TransformWorldToViewDir(worldNormal,false);
            		normalViewFlip.z = abs(normalViewFlip.z);
            		worldNormal = normalize(mul((real3x3)UNITY_MATRIX_I_V, normalViewFlip));
            	#endif

            	float ndotL = dot(worldNormal, lightDir) * 0.5 + 0.5;
            	worldNormal = NormalizeNormalPerPixel(worldNormal);            	
				//float colorNdot = 1-(input.color.b * ndotL * 1.5);
				//float colorNdot = input.color.r + 0.7;

            	//Environment Lighting
				half3 reflectVector = reflect(-viewDir, worldNormal);
				half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, 10);
			   
				half3 irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);

				half3 diffuseColor = diffuse.rgb * 0.3 * mainlight.color * saturate((_ShadowBiasStrength+0.2) + mainlight.shadowAttenuation);

				half3 ambient = SampleSH(worldNormal);
				
            	#ifdef _ADDITIONAL_LIGHTS
				   uint pixelLightCount = GetAdditionalLightsCount();
				   for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
				   {
				   Light light = GetAdditionalLight(lightIndex, input.positionWS);

				   half3 attenuatedLightColor = light.color * (light.distanceAttenuation * saturate(_ShadowBiasStrength + light.shadowAttenuation));
				   diffuseColor += LightingLambert(attenuatedLightColor, light.direction, worldNormal) * 0.05;
				   }
				#endif
            	//half4 color = half4(diffuseColor * colorNdot, diffuse.a);
            	half4 color = half4(diffuseColor, diffuse.a);
            					
			   #ifdef _ADDITIONAL_LIGHTS_VERTEX
				  diffuseColor += input.fogFactorAndVertexLight.yzw;;
				#endif
            	
				//diffuseColor += irradiance * ambient * _AmbientReflections;
			   diffuseColor += irradiance * ambient * _AmbientReflections;
				//half4 color = half4(diffuseColor, diffuse.a);
            	
				#if _ALPHATEST_ON
					clip(color.a - _Cutoff);
				#endif

			   //apply fog
			   //color.rgb = MixFog(color.rgb, input.fogFactor);
				color.rgb = MixFog(color.rgb, input.fogFactorAndVertexLight.x);

            	
			   return color;

            	
            }
            ENDHLSL
        }
    	
    	Pass
			   {
			   Name "ShadowCaster"

			   Tags{"LightMode" = "ShadowCaster"}

			   Cull Off

			   HLSLPROGRAM

			   #pragma prefer_hlslcc gles
			   #pragma exclude_renderers d3d11_9x
			   #pragma target 2.0

			   #pragma vertex ShadowPassVertex
			   #pragma fragment ShadowPassFragment

			   #pragma shader_feature_local _ALPHATEST_ON
			   #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			   #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			  CBUFFER_START(UnityPerMaterial)

				half4 _Color;
	            half4 _BaseMap_ST;
				half _Cutoff;
				half _AlphaClip;
				//half _Metallic;
				half _Smoothness;
				half _Occlusion;
				half _NormalBias;
				half _BumpScale;
				half _ReceiveShadowBias;
				half _WindStrength, _NormalStrength;
				half4 _WindDirSize;
				half _Jitter;
				
				half _AmbientReflections;
				half _ShadowBiasStrength;

            CBUFFER_END
            Texture2D _BaseMap;
			SamplerState sampler_BaseMap;
			Texture2D _BumpMap;
			Texture2D _WindTex;
            SamplerState sampler_WindTex;

			   float3 _LightDirection;
			   float3 _LightPosition;			   

				struct VertexInput
				{
					float4 positionOS : POSITION;
					float4 normalOS : NORMAL;
					half4 color : COLOR;
					#if  _ALPHATEST_ON
					float2 uv     : TEXCOORD0;
					#endif
				};

				struct VertexOutput
				{
					float4 positionCS : SV_POSITION;

					#if  _ALPHATEST_ON
					float2 uv     : TEXCOORD0;
					#endif
				};

				float4 GetShadowPositionHClip(VertexInput i)
					{
						float3 positionWS = TransformObjectToWorld(i.positionOS.xyz);
						float3 normalWS = TransformObjectToWorldNormal(i.normalOS.xyz);

half4 wind = SAMPLE_TEXTURE2D_LOD(_WindTex, sampler_WindTex, (positionWS.xz), 10);
				
            	half windStrength = i.color.r * _WindStrength;
		        
            	windStrength *= wind.r;
		        float3 disp = sin((positionWS.x + positionWS.y + positionWS.z + _Time.y) * 10.0f) *
		        	normalWS * float3(1.0f, 0.35f, 1.0f);
		        positionWS += disp * windStrength * _Jitter; // * WindMultiplier.y;

		        positionWS.xz += _WindDirSize.xz * windStrength;
			    half2 normalWindDir = _WindDirSize.xz * _NormalStrength;
		        normalWS.xz += normalWindDir * windStrength;
					
					#if _CASTING_PUNCTUAL_LIGHT_SHADOW
						float3 lightDirectionWS = normalize(_LightPosition - positionWS);
					#else
						float3 lightDirectionWS = _LightDirection;
					#endif

						float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
					#if UNITY_REVERSED_Z
					    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
					#else
					    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
					#endif
						return positionCS;
					}

				VertexOutput ShadowPassVertex(VertexInput v)
				{
				  VertexOutput o;
					
				 //float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
				 //float3 normalWS = TransformObjectToWorldNormal(v.normalOS.xyz);

				 //o.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
				 
				  o.positionCS = GetShadowPositionHClip(v);

				 #if _ALPHATEST_ON
				  o.uv = v.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
				 #endif 
				 return o;
				}

				half4 ShadowPassFragment(VertexOutput i) : SV_TARGET
				{
				#if _ALPHATEST_ON
					half alpha = _BaseMap.Sample(sampler_BaseMap, i.uv).a * _Color.a;
					clip(alpha - _Cutoff);
				#endif

				return 0;
				}

				ENDHLSL
			   }
    }
}
