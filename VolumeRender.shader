Shader "Unlit/VolumeRender"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _Alpha ("Alpha", float) = 0.02
        _StepSize ("Step Size", float) = 0.01
        _rScale ("r scale", float) = 1.0
        _gScale ("g scale", float) = 1.0
        _bScale ("b scale", float) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend One OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Maximum amount of raymarching samples
            #define MAX_STEP_COUNT 74

            // Allowed floating point inaccuracy
            #define EPSILON 0.001f

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 objectVertex : TEXCOORD0;
                float3 vectorToSurface : TEXCOORD1;
            };

            sampler3D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            float _StepSize;

            v2f vert (appdata v)
            {
                v2f o;

                // Vertex in object space this will be the starting point of raymarching
                o.objectVertex = v.vertex;

                // Calculate vector from camera to vertex in world space
                float3 worldVertex = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vectorToSurface = worldVertex - _WorldSpaceCameraPos;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 BlendUnder(float4 color, float4 newColor)
            {

                color.rgb += (1.0 - color.a) * newColor.a * newColor.rgb;
                
                color.a += (1.0 - color.a) * newColor.a;
                return color;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Start raymarching at the front surface of the object
                float3 rayOrigin = i.objectVertex;

                // Use vector from camera to object surface to get ray direction
                float3 rayDirection = mul(unity_WorldToObject, float4(normalize(i.vectorToSurface), 1.0));

                float4 color = float4(0, 0, 0, 0);
                float3 samplePosition = rayOrigin;
                //samplePosition.y -= 1.65;

                // Raymarch through object space
                for (int i = 0; i < MAX_STEP_COUNT; i++)
                {
                    // Accumulate color only within unit cube bounds
                    if(max(abs(samplePosition.x), max(abs(samplePosition.y), abs(samplePosition.z))) < 0.0625f + EPSILON)
					//if (max(abs(samplePosition.x), max(abs(samplePosition.y), abs(samplePosition.z))) < 0.5f + EPSILON)
                    {
                        float4 sampledColor = tex3D(_MainTex, samplePosition*8 + float3(0.5f, 0.5f, 0.5f));

                        sampledColor.r = pow(sampledColor.r, 1)*1.3;
                        sampledColor.g = pow(sampledColor.g, 1)*1.0;
                        sampledColor.b = pow(sampledColor.b, 1)*1.3;
                        //sampledColor.r = 0.0;
                        //sampledColor.g = 0.0;
                        //sampledColor.b = 0.3;
						//sampledColor.a = 0.01;

                        sampledColor.a *= _Alpha;
                        color = BlendUnder(color, sampledColor);

                        //samplePosition += rayDirection * _StepSize;

                        samplePosition.x = samplePosition.x + rayDirection.x * _StepSize;
                        samplePosition.y = samplePosition.y + rayDirection.y * _StepSize;
                        samplePosition.z = samplePosition.z + rayDirection.z * _StepSize;

                    }
                }

                return pow(color, 0.75)*180;
                //return color;
            }
            ENDCG
        }
    }
}
