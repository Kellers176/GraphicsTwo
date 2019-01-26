/*
	Copyright 2011-2019 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhongMulti_fs4x.glsl
	Calculate and output Phong shading model for multiple lights using data 
		from prior shader.
*/

#version 410

// ****TO-DO: 
//	1) declare varyings to read from vertex shader
//		-> *test all varyings by outputting them as color
//	2) declare uniforms for textures (diffuse, specular)
//	3) sample textures and store as temporary values
//		-> *test all textures by outputting samples
//	4) declare fixed-sized arrays for lighting values and other related values
//		-> *test lighting values by outputting them as color
//		-> one day this will be made easier... soon, soon...
//	5) implement Phong shading calculations
//		-> *save time where applicable
//		-> diffuse, specular, attenuation
//		-> remember to be modular (e.g. write a function)
//	6) calculate Phong shading model for one light
//		-> *test shading values (diffuse, specular) by outputting them as color
//	7) calculate Phong shading for all lights
//		-> *test shading values
//	8) add all light values appropriately
//	9) calculate final Phong model (with textures) and copy to output
//		-> *test the individual shading totals
//		-> use alpha channel from diffuse sample for final alpha
const int MAX_LIGHTS = 10;


out vec4 rtFragColor;

uniform sampler2D uTex_dm; //(2)
uniform sampler2D uTex_sm;

//temp
vec4 DiffuseTex;
vec4 SpecularTex;
vec3 col;

uniform int uLightCt; //(8)
uniform vec4  uLightPos[MAX_LIGHTS]; //position
uniform vec4  uLightCol[MAX_LIGHTS]; //intensity aka color
uniform float uLightSz[MAX_LIGHTS]; //attenuation

in vPassDataBlock //(1)
{
	vec4 vPassPosition;
	vec3 vPassNormal;

	vec2 vPassTexcoord;

} vPassData;



void main()
{
	DiffuseTex = texture(uTex_dm, vPassData.vPassTexcoord);
	SpecularTex = texture(uTex_sm, vPassData.vPassTexcoord);

	for(int i = 0; i < uLightCt; i++)
	{
		vec3 N = normalize(vPassData.vPassNormal);
		vec3 L = normalize(uLightPos[i].xyz - vPassData.vPassPosition.xyz);
		vec3 V = normalize(-vPassData.vPassPosition.xyz);
		vec3 R = reflect(-L, N);
		
		//float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
		//vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
		vec3 diffuse = max(dot(N, L), 0.0f) * DiffuseTex.xyz;
		//vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
		vec3 specular = max(dot(R,V), 0.0f) * SpecularTex.xyz;

		//float distanceToLight = length(light.position - surfacePos);
		float distance = length(uLightPos[i] - vPassData.vPassPosition);

		//float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
		float attenuation = 1.0 / (1.0 + uLightSz[i]  * pow(distance, 2));
		//vec3 ambient = light.ambientCoefficient * surfaceColor.rgb * light.intensities;
		vec3 ambient = vec3(0.03) * attenuation;

		//vec3 linearColor = ambient + attenuation*(diffuse + specular);
		col += uLightCol[i].xyz * attenuation * (diffuse + specular);
		//col += diffuse + specular * uLightCol[i].xyz;
		

	}

	
	rtFragColor =  vec4(col, 1.0f);
	//rtFragColor = vec4(diffuse+specular, 1.0f) * col;
}

