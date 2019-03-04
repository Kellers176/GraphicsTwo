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
	
	drawCurveHandles_gs4x.glsl
	Draw curve control values.
*/

#version 410

// ****TO-DO: 
//	1) declare input varying data
//	2) declare uniform blocks
//	3) draw line between waypoint and handle
//	4) draw shape for handle (e.g. diamond)

#define max_verts 8
#define max_waypoints 32

layout (points) in;
layout (line_strip, max_vertices = max_verts) out;

uniform mat4 uMVP;



//uniform vec4 ubCurveWaypoint[32]; //	(2)
uniform ubCurveWaypoint{
	vec4 uCurveWaypoint[max_waypoints];
}; //	(2)
uniform ubCurveHandle{
	vec4 uCurveHandle[max_waypoints];
};

flat in int vPassInstanceID[]; // (1)

void main()
{
	//Draw line between waypoint and handle
	gl_Position = uMVP * uCurveWaypoint[vPassInstanceID[0]];
	EmitVertex();

	gl_Position = uMVP * uCurveHandle[vPassInstanceID[0]];
	EmitVertex();
	
	EndPrimitive();


	vec4 offset1 = uCurveHandle[vPassInstanceID[0]] + vec4(0, 0.1, 0.0, 0);
	vec4 offset2 = uCurveHandle[vPassInstanceID[0]] + vec4(0.1, 0.0, 0.0, 0);
	vec4 offset3 = uCurveHandle[vPassInstanceID[0]] + vec4(0,-0.1, 0.0, 0);
	vec4 offset4 = uCurveHandle[vPassInstanceID[0]] + vec4(-0.1, 0.0, 0.0, 0);

	//gl_Position = uMVP * (uCurveHandle[vPassInstanceID[0]] + vec4(0, 0.1, 0.0, 1.0));
	gl_Position = uMVP * offset1;
	EmitVertex();

	//gl_Position = uMVP * (uCurveHandle[vPassInstanceID[0]] + vec4(0.1, 0.0, 0.0, 1.0));
	gl_Position = uMVP * offset2;
	EmitVertex();

	//gl_Position = uMVP * (uCurveHandle[vPassInstanceID[0]] + vec4(0, -0.1, 0.0, 1.0));
	gl_Position = uMVP * offset3;
	EmitVertex();

	//gl_Position = uMVP * (uCurveHandle[vPassInstanceID[0]] + vec4(-0.1, 0.0, 0.0, 1.0));
	gl_Position = uMVP * offset4;
	EmitVertex();

	//gl_Position = uMVP * (uCurveHandle[vPassInstanceID[0]] + vec4(0, 0.1, 0.0, 1.0));
	gl_Position = uMVP * offset1;
		EmitVertex();
	EndPrimitive();
}
