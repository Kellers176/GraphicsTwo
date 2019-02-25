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
	
	manipTriangle_gs4x.glsl
	Manipulate a single input triangle.
*/

#version 410

// ****TO-DO: 
//	1) declare input and output varying data
//	2) either copy input directly to output for each vertex, or 
//		do something with the vertices first (e.g. explode, invert)

//no more variables for this shader
layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

uniform mat4 uP;

//(1)
//recieved passPhongAttribs
in vbPassDataBlock
{
	vec4 vPosition;
	vec4 vNormal;
	vec2 vTexcoord;

} vPassData_in[];
//pass to drawPhongMulti
out vbPassDataBlock
{
	vec4 vPosition;
	vec4 vNormal;
	vec2 vTexcoord;

} vPassData_out;


void main()
{
	const float explodeSz = 0.5;
	//use for loop
	vPassData_out.vPosition = vPassData_in[0].vPosition
							+ normalize(vPassData_in[0].vNormal) * explodeSz;
	vPassData_out.vNormal = vPassData_in[0].vNormal;
	vPassData_out.vTexcoord = vPassData_in[0].vTexcoord;
	//gl_Position = gl_in[0].gl_Position; //clip space
	gl_Position = uP * vPassData_out.vPosition;
	EmitVertex();

	vPassData_out.vPosition = vPassData_in[1].vPosition
							+ normalize(vPassData_in[1].vNormal) * explodeSz;
	vPassData_out.vNormal = vPassData_in[1].vNormal;
	vPassData_out.vTexcoord = vPassData_in[1].vTexcoord;
	gl_Position = uP * vPassData_out.vPosition;
	EmitVertex();

	vPassData_out.vPosition = vPassData_in[2].vPosition
							+ normalize(vPassData_in[2].vNormal) * explodeSz;
	vPassData_out.vNormal = vPassData_in[2].vNormal;
	vPassData_out.vTexcoord = vPassData_in[2].vTexcoord;
	gl_Position = uP * vPassData_out.vPosition;
	EmitVertex();

	EndPrimitive();
}
