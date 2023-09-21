#include "PixelShaderCore.hlsllib"


float4 main(ShaderVertex input) : SV_TARGET
{
	input.Normal = normalize(input.Normal);
	float4 diffuseColor = DiffuxeTexture2D.Sample(LinearSampler, input.Texel.xy);
	float4 finalColor = float4(0, 0, 0, 0);

	for (unsigned int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		float3 lightToPixelVector = PointLights[i].Position.xyz - input.WorldPosition.xyz;
		float distance = length(lightToPixelVector);
		if (distance <= PointLights[i].Range)
		{
			lightToPixelVector /= distance;
			float lightIntensity = dot(lightToPixelVector, input.Normal);
			if (lightIntensity > 0)
			{
				finalColor += lightIntensity * diffuseColor * PointLights[i].Color;
				finalColor /= PointLights[i].Attenuation[0] + (PointLights[i].Attenuation[1] * distance) + (PointLights[i].Attenuation[2] * (distance * distance));
			}
		}
	}

	for (unsigned int i = 0; i < MAX_DIRECTIONAL_LIGHTS; ++i)
	{
		finalColor += saturate(dot((float3) DirectionalLights[i].Direction, input.Normal) * DirectionalLights[i].Color);
	}

	finalColor = saturate(finalColor + (AmbientColor * diffuseColor));
	finalColor.a = 1;
	return finalColor;
}