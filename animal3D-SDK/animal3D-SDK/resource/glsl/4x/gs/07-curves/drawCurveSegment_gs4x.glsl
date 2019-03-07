/*
	Copyright 2011-2019 Daniel S. Buckstein
	“This file was modified by Kelly and Zac with permission of the author.”
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
	
	drawCurveSegment_gs4x.glsl
	Draw curve segment using interpolation algorithm.
*/

#version 410

// ****TO-DO: 
//	1) declare input varying data
//	2) declare uniform blocks
//	3) implement interpolation sampling function(s)
//	4) implement curve drawing function(s)
//	5) call choice curve drawing function in main

#define max_verts 32
#define max_waypoints 32

layout (points) in;
layout (line_strip, max_vertices = max_verts) out;

uniform ubCurveWaypoint{
	vec4 uCurveWaypoint[max_waypoints];
}; //	(2)
uniform ubCurveHandle{
	vec4 uCurveHandle[max_waypoints];
};
uniform mat4 uMVP;

flat in int vPassInstanceID[]; // (1)

//kelly and zac
//We used the fucntion from the SuperBible to get LERP to work :)
void lerp(in vec4 A, in vec4 B)
{
	//set the previous P to the start of the line
	vec4 prevP = A;
	float var = 2.0 / float(max_verts);

	//go through each of the segments and use those for the new points
	for (int i = 0; i < max_verts; i++)
	{
		//newP = 
		vec4 D = (B - A);
		gl_Position = prevP;
		EmitVertex();
	
		vec4 newP = prevP + var * (D);
		gl_Position = newP;
		EmitVertex();
	
		//EndPrimitive();
	
		prevP = newP;
	}
	EndPrimitive();

}

void main()
{
	lerp(uMVP * uCurveWaypoint[vPassInstanceID[0]], uMVP * uCurveWaypoint[vPassInstanceID[0] + 1]);
}
