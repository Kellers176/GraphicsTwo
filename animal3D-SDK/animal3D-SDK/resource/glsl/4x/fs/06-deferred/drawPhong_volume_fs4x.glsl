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
	
	drawPhong_volume_fs4x.glsl
	Perform Phong shading for a single light within a volume; output 
		components to MRT.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong multi-light shader
//	1) geometric inputs from scene objects are not received from VS!
//		-> we are drawing a textured FSQ so where does the geometric 
//			input data come from? declare appropriately
//	2) declare varyings for light volume geometry
//		-> biased clip-space position, index
//	3) declare uniform blocks
//		-> implement data structure matching data in renderer
//		-> replace old lighting uniforms with new block
//	4) declare multiple render targets
//		-> diffuse lighting, specular lighting
//	5) compute screen-space coordinate for current light
//	6) retrieve new geometric inputs (no longer from varyings)
//		-> *test by outputting as color
//	7) use new inputs where appropriate in lighting
//		-> remove anything that can be deferred further



in vec4 vPassBiasClipCoord;	//(2)
flat in int vPassInstanceID;//(2)

uniform sampler2D uTex_dm; //(2)
uniform sampler2D uTex_sm;


//temp
vec4 DiffuseTex;
vec4 SpecularTex;
vec3 col;


//(3)
#define max_lights 1024

struct sPointLight
{
	vec4 worldPos;
	vec4 viewPos;
	vec4 color;
	float radius;
	float radiusInvSq;
	float pad[2];
};

uniform ubPointLight{
	sPointLight uPointLight[max_lights];
};

layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtFragColor1;

uniform sampler2D uImage4, uImage5, uImage6, uImage7;


void main()
{
	vec4 gPosition = texture(uImage4, vPassBiasClipCoord.xy); //(2)
	vec4 gNormal = texture(uImage5, vPassBiasClipCoord.xy);
	vec2 gTexcoord = texture(uImage6, vPassBiasClipCoord.xy).xy;
	float gDepth = texture(uImage7, vPassBiasClipCoord.xy).x;

	//PHONG
	DiffuseTex = texture(uTex_dm, gTexcoord);
	SpecularTex = texture(uTex_sm, gTexcoord);
	
	//Kelly worked on the for loop while zac and kelly worked on getting the algorithm working
	/*This for loop works through each light that is passed by the uniforms. This then calculates the and normalizes
	the normal of the scene, the light positions in teh scene, the position of the objects and then the reflection.
	This then calculates the diffuse and the specular lights with their algorithm. At tge end, we add all of these variables
	up into the final color (col) and we set it equal to the frag color.*/
	vec3 N = normalize(gNormal.xyz);
	vec3 L = normalize(uPointLight[vPassInstanceID].worldPos.xyz - gPosition.xyz);
	vec3 V = normalize(-gPosition.xyz);
	vec3 R = reflect(-L, N);
	
	//float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
	//vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
	vec3 diffuse = max(dot(N, L), 0.0f) *  uPointLight[vPassInstanceID].color.xyz * DiffuseTex.xyz;
	//vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
	vec3 specular = pow(max(dot(R, V), 0.0f), 32.0) * SpecularTex.xyz *  uPointLight[vPassInstanceID].color.xyz;
	
	//float distanceToLight = length(light.position - surfacePos);
	float distanceToLight = length(uPointLight[vPassInstanceID].worldPos - gPosition); //vec4(vPassData.vPassNormal, 1.0f));
	
	//float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
	float attenuation = 1.0 / (1.0 + uPointLight[vPassInstanceID].radius * pow(distanceToLight, 2));
	
	//vec3 linearColor = ambient + attenuation*(diffuse + specular);
	col += attenuation * (diffuse + specular);
	
	
	rtFragColor = vec4(col, 1.0f);
	//// DUMMY OUTPUT: all fragments are FADED MAGENTA
	//rtFragColor = uPointLight[vPassInstanceID].color;
	//rtFragColor = DiffuseTex;
	rtFragColor = vPassBiasClipCoord;
}

