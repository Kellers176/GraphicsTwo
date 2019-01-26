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
	
	passPhongAttribs_transform_vs4x.glsl
	Transform position attribute and pass attributes related to Phong shading 
		model down the pipeline.
*/

#version 410

// ****TO-DO: 
//	1) declare separate uniforms for MV and P matrices
//	2) transform object-space position to eye-space
//	3) transform eye-space position to clip space, store as output
//	4) declare normal attribute
//		-> look in 'a3_VertexDescriptors.h' for the correct location index
//	5) declare normal MV matrix
//	6) transform object-space normal to eye-space using the correct matrix
//	7) declare texcoord attribute
//	8) declare varyings for lighting data
//	9) copy lighting data to varyings

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal; //(4)
layout (location = 8) in vec2 aTexcoord; // (7) in a3_VertexDescriptor.h


uniform mat4 uMV; //(1)
uniform mat4 uP;

uniform mat4 uMV_nrm;

mat3 normalMV; //(...5?)

//varying block
out vPassDataBlock
{
	vec4 vPassPosition;
	vec3 vPassNormal;

	vec2 vPassTexcoord;

} vPassData;
//vPassData.(member)

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	vPassData.vPassPosition = uMV * aPosition; // eye space //(2)
	//vPassData.vPassPosition =  aPosition; // eye space //(2)
	//vPassData.vPassPosition = uP * vPassData.vPassPosition; //clip space //(3)

	//normalMV = mat3(uMV);
	normalMV = mat3(uMV_nrm);

	vPassData.vPassNormal = normalMV * aNormal;

	vPassData.vPassTexcoord = aTexcoord;

	gl_Position = uP * uMV * aPosition; //clip space
}
