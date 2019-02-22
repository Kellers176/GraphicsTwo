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




//temp
//vec4 DiffuseTex;
//vec4 SpecularTex;
//vec3 col;


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

uniform sampler2D  uImage4, uImage5, uImage6;//, uImage7;


void main()
{
	//perspective divide
	vec4 screen_Proj = vPassBiasClipCoord / vPassBiasClipCoord.w; // (3)

	vec4 gPosition = texture(uImage4, screen_Proj.xy); //(2)
	vec4 gNormal = texture(uImage5, screen_Proj.xy);
	//vec2 gTexcoord = texture(uImage6, screen_Proj.xy).xy;
	//float gDepth = texture(uImage7, screen_Proj.xy).x;

	//PHONG
	//DiffuseTex = texture(uImage0, gTexcoord);
	//DiffuseTex = texture(uTex_dm, screen_Proj.xy);
	//SpecularTex = texture(uTex_sm, gTexcoord);
	

	vec3 N = gNormal.xyz;
	vec3 L = normalize(uPointLight[vPassInstanceID].viewPos.xyz - gPosition.xyz);
	vec3 V = normalize(-gPosition.xyz);
	vec3 R = reflect(-L, N);
	
	float kd = max(dot(N, L), 0.0f);// *  uPointLight[vPassInstanceID].color.xyz;//* DiffuseTex.xyz;
	float ks = max(dot(N, R), 0.0f);
	ks *= ks;
	ks *= ks;
	ks *= ks;
	ks *= ks;
	


	//float diffuseCoefficient = max(0.0, dot(normal, surfaceToLight));
	//vec3 diffuse = diffuseCoefficient * surfaceColor.rgb * light.intensities;
	//vec3 diffuse = max(dot(N, L), 0.0f) *  uPointLight[vPassInstanceID].color.xyz * DiffuseTex.xyz;
	//vec3 specular = specularCoefficient * materialSpecularColor * light.intensities;
	//vec3 specular = pow(max(dot(R, V), 0.0f), 32.0) * SpecularTex.xyz *  uPointLight[vPassInstanceID].color.xyz;
	//vec3 specular = pow(max(dot(R, V), 0.0f), 32.0) *  uPointLight[vPassInstanceID].color.xyz;
	
	//*  uPointLight[vPassInstanceID].color.xyz;
	
	//float distanceToLight = length(light.position - surfacePos);
	//float distanceToLight = length(uPointLight[vPassInstanceID].viewPos - gPosition); //vec4(vPassData.vPassNormal, 1.0f));
	float distanceToLight = length(L); //vec4(vPassData.vPassNormal, 1.0f));
	
	
	//float attenuation = 1.0 / (1.0 + light.attenuation * pow(distanceToLight, 2));
	//float attenuation = 1.0 / (1.0 + uPointLight[vPassInstanceID].radiusInvSq * pow(distanceToLight, 2));
	//float attenuation = 50.0 / (1.0 +  pow(distanceToLight, 2));
	
	float attenuation =  1.0 /(uPointLight[vPassInstanceID].radiusInvSq);// * uPointLight[vPassInstanceID].radiusInvSq);

	vec4 specular = uPointLight[vPassInstanceID].color * ks * attenuation;
	vec4 diffuse = uPointLight[vPassInstanceID].color * kd * attenuation;

	rtFragColor = diffuse;
	rtFragColor1 = specular;
	
	//vec3 linearColor = ambient + attenuation*(diffuse + specular);
	//col += attenuation * (diffuse + specular);
	
	
	//rtFragColor = vec4(col, 1.0f);
	//// DUMMY OUTPUT: all fragments are FADED MAGENTA
	//rtFragColor = uPointLight[vPassInstanceID].color;
	//rtFragColor = DiffuseTex;
	//rtFragColor = vPassBiasClipCoord;
	//rtFragColor = vec4(vPassTexCoord, 0.0, 1.0);
	//rtFragColor = gPosition;
	//rtFragColor = gNormal;
	//rtFragColor1 = gNormal;
	//rtFragColor = vec4(gTexcoord, 0.0, 1.0);
	//rtFragColor1 = vec4(col, 1.0);
	//rtFragColor = vec4(diffuse, 1.0);// + vec3(DiffuseTex), 1.0);
	//rtFragColor = vec4(attenuation * diffuse, 1.0);
	//rtFragColor = DiffuseTex;
	//rtFragColor = vec4(DiffuseTex.xyz, 1.0);
	//rtFragColor = vec4(1.0, 1.0, 1.0, 0.5);
	//rtFragColor = vec4(kd, kd, kd, 1.0);
	//rtFragColor = vec4(distanceToLight, distanceToLight, distanceToLight, 1.0);
	//rtFragColor = vec4(L, 1.0);
	//rtFragColor = vec4(attenuation, 1.0);
	//rtFragColor = vec4(uPointLight[vPassInstanceID].radiusInvSq, uPointLight[vPassInstanceID].radiusInvSq, uPointLight[vPassInstanceID].radiusInvSq, 1.0);
	//rtFragColor = uPointLight[vPassInstanceID].color * kd;// * attenuation;
	//rtFragColor = uPointLight[vPassInstanceID].worldPos;
}

