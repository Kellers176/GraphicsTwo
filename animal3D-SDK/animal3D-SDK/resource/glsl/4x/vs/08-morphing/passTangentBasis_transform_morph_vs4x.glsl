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
	
	passTangentBasis_transform_morph_vs4x.glsl
	Transform and pass complete tangent basis after performing morph animation.
*/

#version 410

// ****TO-DO: 
//	1) declare all tangent basis attributes configured for morphing
//	2) declare transformation matrix uniforms
//	3) declare tangent basis to pass along
//	4) define morphing algorithm and related uniforms
//	5) define local tangent basis and store morphed attributes
//	6) transform and pass tangent basis
//	7) set final clip-space position
//	8) declare additional attributes, uniforms and varyings for shading
//	9) transform and pass additional values for shading

#define max_morphTarget 5

//layout (location = 0)	in vec4 aPosition;
layout (location = 0)	in vec4 aPosition[max_morphTarget]; // (1)
layout (location = 5)	in vec4 aNormal[max_morphTarget]; // (1)
layout (location = 10)	in vec4 aTangent[max_morphTarget]; // (1)
layout (location = 15)	in vec4 aTexcoord; // (1)

uniform mat4 uMV, uP; //(2)

uniform ivec4 uIndex; //(4)
uniform float uTime;	 //(4)

#define i0 uIndex[0]
#define i1 uIndex[1]
#define iNext uIndex[2]
#define iPrev uIndex[3]

vec4 CatmullRom()
{
	vec4 returnVec;
	returnVec = (1 / 2) * (((-uTime + (2 * pow(uTime, 2)) - pow(uTime, 3)) * aPosition[iPrev]) + ((2 - (5 * pow(uTime, 5)) + (3 * pow(uTime, 3))) * aPosition[i0])
		+ (uTime + (4 * pow(uTime, 2)) - (3 * pow(uTime, 3)) * aPosition[i1]) + (-pow(uTime, 2) + pow(uTime, 3)) * aPosition[iNext]);
	return returnVec;
}

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	vec4 position = 
		mix(aPosition[i0], aPosition[i1], uTime);
	//vec4 position = CatmullRom();

	gl_Position = uP * uMV * position;
}
