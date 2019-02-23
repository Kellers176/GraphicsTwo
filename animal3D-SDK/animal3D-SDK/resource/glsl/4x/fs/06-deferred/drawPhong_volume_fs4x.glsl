/*
	Copyright 2011-2019 Daniel S. Buckstein
	This file was modified by Kelly and Zac with permission of the author.

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
	//kelly and zac
	//get the perspective divide and use those coordinates for the buffer.
	//perspective divide
	vec4 screen_Proj = vPassBiasClipCoord / vPassBiasClipCoord.w; // (3)

	vec4 gPosition = texture(uImage4, screen_Proj.xy); //(2)
	vec4 gNormal = texture(uImage5, screen_Proj.xy);
	
	//calulcate the distance and other variables needed for each light
	vec3 N = gNormal.xyz;
	vec3 L = normalize(uPointLight[vPassInstanceID].viewPos.xyz - gPosition.xyz); 
	vec3 V = normalize(-gPosition.xyz);
	vec3 R = reflect(-L, N);
	
	
	//get the distance to the light and use that for the attenuation
	float distanceToLight = length(gPosition.xyz- uPointLight[vPassInstanceID].viewPos.xyz); 
	float attenuation = smoothstep(uPointLight[vPassInstanceID].radius, 0, distanceToLight);

	//get the diffuse and specular 
	vec4 diffuse = max(dot(N, L), 0.0f) *  uPointLight[vPassInstanceID].color;

	vec4 specular = pow(max(dot(N, R), 0.0f), 8.0) *  uPointLight[vPassInstanceID].color;


	rtFragColor = attenuation * diffuse;
	rtFragColor1 = attenuation* specular;

}

