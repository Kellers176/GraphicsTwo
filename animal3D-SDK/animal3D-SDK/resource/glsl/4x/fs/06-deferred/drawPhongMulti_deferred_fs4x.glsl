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
	
	drawPhongMulti_deferred_fs4x.glsl
	Perform Phong shading on multiple lights, deferred.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong multi-light shader
//	1) geometric inputs from scene objects are not received from VS!
//		-> we are drawing a textured FSQ so where does the geometric 
//			input data come from? declare appropriately
//	2) retrieve new geometric inputs (no longer from varyings)
//		-> *test by outputting as color
//	3) use new inputs where appropriate in lighting

in vec2 vPassTexCoord;

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


//(1) postion, normal, texcoord, depth
uniform sampler2D uImage4, uImage5, uImage6, uImage7;

layout (location = 0) out vec4 rtFragColor;

void main()
{
	
	//vec4 image0Tex = texture(uImage3, vPassTexCoord);

	vec4 gPosition = texture(uImage4, vPassTexCoord); //(2)
	vec4 gNormal = texture(uImage5, vPassTexCoord);
	vec2 gTexcoord = texture(uImage6, vPassTexCoord).xy;
	float gDepth = texture(uImage7, vPassTexCoord).x;

	


	DiffuseTex = texture(uTex_dm, gTexcoord);
	SpecularTex = texture(uTex_sm, gTexcoord);

	//Kelly worked on the for loop while zac and kelly worked on getting the algorithm working
	/*This for loop works through each light that is passed by the uniforms. This then calculates the and normalizes
	the normal of the scene, the light positions in teh scene, the position of the objects and then the reflection.
	This then calculates the diffuse and the specular lights with their algorithm. At tge end, we add all of these variables
	up into the final color (col) and we set it equal to the frag color.*/
	for (int i = 0; i < uLightCt; i++)
	{
		vec3 N = normalize(gNormal.xyz);
		vec3 L = normalize(uLightPos[i].xyz - gPosition.xyz);
		vec3 V = normalize(-gPosition.xyz);
		vec3 R = reflect(-L, N);

		//float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
		//vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
		vec3 diffuse = max(dot(N, L), 0.0f) *  uLightCol[i].xyz * DiffuseTex.xyz;
		//vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
		vec3 specular = pow(max(dot(R, V), 0.0f), 32.0) * SpecularTex.xyz *  uLightCol[i].xyz;

		//float distanceToLight = length(light.position - surfacePos);
		float distanceToLight = length(uLightPos[i] - gPosition); //vec4(vPassData.vPassNormal, 1.0f));

		//float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
		float attenuation = 1.0 / (1.0 + uLightSz[i] * pow(distanceToLight, 2));

		//vec3 linearColor = ambient + attenuation*(diffuse + specular);
		col += attenuation * (diffuse + specular);


	}

	rtFragColor = vec4(col, gPosition.a);
	

	// DUMMY OUTPUT: all fragments are PURPLE
	//rtFragColor = worldPosition;
	//rtFragColor = vec4(0.5, 0.0, 1.0, 1.0);
	//rtFragColor = vec4(vPassTexCoord, 0.0, 0.0);
	//rtFragColor = DiffuseTex;
	//rtFragColor = SpecularTex;
	//rtFragColor = image0Tex;
	//rtFragColor = gPosition; //(2*)
	//rtFragColor = vec4(gNormal.xyz * 0.5 + 0.5, 1.0); //(2*)
	//rtFragColor = vec4(gTexcoord, 0.0, 1.0); ; //(2*)
	//rtFragColor = vec4(gDepth, gDepth, gDepth, 1.0); //(2*)
}
