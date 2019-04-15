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
	
	drawPhongMulti_tangentBasis_nm_pom_fs4x.glsl
	Calculate and output Phong shading model for multiple lights using full 
		tangent basis passed from previous shader; perform normal mapping and 
		parallax occlusion mapping.
*/

#version 410

// ****TO-DO: 
//	1) 

in mat4 vPassTangentBasis;
in vec4 vPassTexcoord;

//light structure
//uniform blocks
//light count

uniform sampler2D uTex_dm, uTex_sm, uTex_nm, uTex_hm;
uniform float uRange;

layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtNormal;

void main()
{
	// DUMMY OUTPUT: all fragments are FADED BLUE
//	rtFragColor = vec4(0.5, 0.5, 1.0, 1.0);

	mat4 tangentBasis = mat4(
		normalize(vPassTangentBasis[0]),
		normalize(vPassTangentBasis[1]),
		normalize(vPassTangentBasis[2]),
		vec4(0.0));

	vec4 viewPos_unit = normalize(vec4(vPassTangentBasis[3].xyz, 0.0));
	vec3 rayDir_tan;
	rayDir_tan.x = dot(tangentBasis[0], viewPos_unit);
	rayDir_tan.y = dot(tangentBasis[1], viewPos_unit);
	rayDir_tan.z = dot(tangentBasis[2], viewPos_unit);

	vec3 c_orig = vec3(vPassTexcoord.xy, 1.0);
	vec3 c_far = c_orig - rayDir_tan / rayDir_tan.z;

//	rtFragColor.rgb = rayDir_tan;
//	rtFragColor.a = 1.0;
//	return;


//	vec2 texcoord = vPassTexcoord.xy;
	vec2 texcoord = c_far.xy;

	vec4 sample_dm = texture(uTex_dm, texcoord);
	vec4 sample_sm = texture(uTex_sm, texcoord);
	vec4 sample_nm = texture(uTex_nm, texcoord) * 2.0 - 1.0;

	//vec4 fragNrm_unit = tangentBasis[2];
	vec4 fragNrm_unit = tangentBasis * sample_nm;
	vec4 lightVec = vec4(0.0, 0.0, 1.0, 0.0);

	float kd = dot(fragNrm_unit, lightVec);
	kd = max(kd, 0.0);

	//c = (u,v,h)
	//cFrag = (uFrag, vFrag,1)
	//cEnd = (uEnd, vEnd, 0)
	//Check if bump map height > ray height
	float n = uRange;
	float dt = 1 / n;
	vec4 ct;

	ct = mix(fragNrm_unit, vec4(c_far, 1.0), dt);
	
		//n = float(numSamples)
		//dt = 1/n
		//ct = lerp(cFrag, cEnd, t) = (ut, vt, ht)


	rtFragColor = ct;
	//rtFragColor = sample_sm;
	//rtFragColor = tangentBasis[2];
	//rtFragColor = vec4(kd, kd, kd, 1.0);
	//rtFragColor = fragNrm_unit;
	//rtFragColor.a = 1.0;

	// DUMMY OUTPUT: standard normal blue
//	rtNormal = vec4(0.5, 0.5, 1.0, 1.0);
}
