/*
	Copyright 2011-2019 Daniel S. Buckstein
	“This file was modified by Zac with permission of the author.”
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
	
	drawTangentBasis_gs4x.glsl
	Draw tangent basis.
*/

#version 410

// ****TO-DO: 
//	1) declare input and output varying data
//	2) draw tangent basis in place of each vertex

layout (triangles) in;
layout (line_strip, max_vertices = 18) out;

uniform mat4 uP;

in mat4 vPassTangentBasis[];	// (1)
out vec4 vPassColor;

void main()
{
	//zac
	for(int i = 0; i < 3; i++)
	{
		//color per tangent
		vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
		color[i] = 1.0;
		vPassColor =color;

		////move the axis a bit outside of the object
		vec4 offset = normalize(vPassTangentBasis[i][2]) * 0.01;

		//setting the base position of the axis
		gl_Position = gl_in[i].gl_Position + offset;
		//emit the vertex
		EmitVertex();

		//getting the actual tangents for the objects
		gl_Position = gl_in[i].gl_Position+ offset + normalize(vPassTangentBasis[i][i]) * 0.2;
		EmitVertex();
		EndPrimitive();
	}
	
	
}
