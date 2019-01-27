/*
	“This file was modified by Kelly and Zac with permission of the author.”

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

//Kelly and Zac made changes
/* we created the variables for the phong shading algorithm. This file calulates the phong lighting in the window.*/
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

	//Kelly worked on the for loop while zac and kelly worked on getting the algorithm working
	/*This for loop works through each light that is passed by the uniforms. This then calculates the and normalizes
	the normal of the scene, the light positions in teh scene, the position of the objects and then the reflection.
	This then calculates the diffuse and the specular lights with their algorithm. At tge end, we add all of these variables
	up into the final color (col) and we set it equal to the frag color.*/
	for(int i = 0; i < uLightCt; i++)
	{
		vec3 N = normalize(vPassData.vPassNormal);
		vec3 L = normalize(uLightPos[i].xyz - vPassData.vPassPosition.xyz);
		vec3 V = normalize(-vPassData.vPassPosition.xyz);
		vec3 R = reflect(-L, N);
		
		//float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
		//vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
		vec3 diffuse = max(dot(N, L), 0.0f) *  uLightCol[i].xyz * DiffuseTex.xyz;
		//vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
		vec3 specular =  pow(max(dot(R,V), 0.0f), 32.0) * SpecularTex.xyz *  uLightCol[i].xyz;

		//float distanceToLight = length(light.position - surfacePos);
		float distanceToLight = length(uLightPos[i] - vPassData.vPassPosition); //vec4(vPassData.vPassNormal, 1.0f));

		//float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
		float attenuation = 1.0 / (1.0 + uLightSz[i]  * pow(distanceToLight, 2));

		//vec3 linearColor = ambient + attenuation*(diffuse + specular);
		col += attenuation * (diffuse + specular);
		

	}
	rtFragColor =  vec4(col, 1.0f);
}

