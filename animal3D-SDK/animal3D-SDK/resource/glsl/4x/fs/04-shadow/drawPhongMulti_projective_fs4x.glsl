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
	
	drawPhongMulti_projective_fs4x.glsl
	Phong shading with projective texturing.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong fragment shader
//	1) declare texture to project
//	2) declare varying to receive shadow coordinate
//	3) perform perspective divide to acquire projector's screen-space coordinate
//		-> *try outputting this as color
//	4) sample projective texture using screen-space coordinate
//		-> *try outputting this on its own
//	5) apply/blend projective texture properly
const int MAX_LIGHTS = 10;
//out vec4 rtFragColor;

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

layout (location = 0) out vec4 rtFragColor;
vec4 projTex;
uniform sampler2D uTex_proj; //(1)


in vPassDataBlock 
{
	vec4 vPassPosition;
	vec3 vPassNormal;

	vec2 vPassTexcoord;

} vPassData;

in vec4 vPassShadowCoord; // (2)


void main()
{
	//PHONG
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


	vec4 screen_Proj = vPassShadowCoord / vPassShadowCoord.w; // (3)
	projTex = texture(uTex_proj,screen_Proj.xy); //(4)
	rtFragColor = 1 - (1 - rtFragColor) * (1 - projTex);//(5)
	rtFragColor.a = 1.0;

	//proj tex = 3 lines
	//inter 5 lines
	//combo 7-10 lines of code
}
