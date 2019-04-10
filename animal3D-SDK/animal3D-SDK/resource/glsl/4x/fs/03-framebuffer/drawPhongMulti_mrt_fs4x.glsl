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
	This file was modified by Kelly Herstine and Zachary Taylor with permission of the author

	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhongMulti_mrt_fs4x.glsl
	Phong shading model with splitting to multiple render targets (MRT).
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong fragment shader
//	1) declare eight render targets
//	2) output appropriate data to render targets
const int MAX_LIGHTS = 10;

uniform sampler2D uTex_dm; //(2)
uniform sampler2D uTex_sm;


layout(location = 0) out vec4 rtFragColor;  // Position attribute data
layout(location = 1) out vec4 rtFragColor1;	// Normal attribute data
layout(location = 2) out vec4 rtFragColor2;	// Texcoord attribute data
layout(location = 3) out vec4 rtFragColor3;	// Diffuse map sample
layout(location = 4) out vec4 rtFragColor4;	// Specular map sample
layout(location = 5) out vec4 rtFragColor5;	// Diffuse shading total
layout(location = 6) out vec4 rtFragColor6;	// Specular shading total
layout(location = 7) out vec4 rtFragColor7;	// Phong shading total

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
	This then calculates the diffuse and the specular lights with their algorithm. At the end, we add all of these variables
	up into the final color (col) and we set it equal to the frag color.*/

	//Diffuse and Specular totals are added up so that they can be output later
	vec3 diffuseTotal;
	vec3 specularTotal;

	for(int i = 0; i < uLightCt; i++)
	{
		vec3 N = normalize(vPassData.vPassNormal);
		vec3 L = normalize(uLightPos[i].xyz - vPassData.vPassPosition.xyz);
		vec3 V = normalize(-vPassData.vPassPosition.xyz);
		vec3 R = reflect(-L, N);
		
		//float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
		//vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
		vec3 diffuseIndiv = max(dot(N, L), 0.0f) *  uLightCol[i].xyz * DiffuseTex.xyz;
		//Add diffuse total without the texteruing
		diffuseTotal += max(dot(N, L), 0.0f) *  uLightCol[i].xyz;

		//vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
		vec3 specularIndiv =  pow(max(dot(R,V), 0.0f), 32.0) * SpecularTex.xyz *  uLightCol[i].xyz;
		//Add specular total using the specular value
		specularTotal += specularIndiv;

		//float distanceToLight = length(light.position - surfacePos);
		float distanceToLight = length(uLightPos[i] - vPassData.vPassPosition); //vec4(vPassData.vPassNormal, 1.0f));

		//float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
		float attenuation = 1.0 / (1.0 + uLightSz[i]  * pow(distanceToLight, 2));

		//vec3 linearColor = ambient + attenuation*(diffuse + specular);
		col += attenuation * (diffuseIndiv + specularIndiv);		

	}

	rtFragColor =  vPassData.vPassPosition;							// Position attribute data						
	rtFragColor1 = vec4(normalize(vPassData.vPassNormal), 1.0f);	// Normal attribute data
	rtFragColor2 = vec4(vPassData.vPassTexcoord, 0.0, 1.0);			// Texcoord attribute data
	rtFragColor3 = DiffuseTex;										// Diffuse map sample
	rtFragColor4 = SpecularTex;										// Specular map sample
	rtFragColor5 = vec4(diffuseTotal, 1.0);							// Diffuse shading total
	rtFragColor6 = vec4(specularTotal, 1.0);						// Specular shading total
	rtFragColor7 = vec4(col, 1.0f);									// Phong shading total
}					 