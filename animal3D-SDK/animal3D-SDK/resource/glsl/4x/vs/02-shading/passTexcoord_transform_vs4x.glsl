/*
“This file was modified by Kelly and Zac with permission of the author.”
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
	
	passTexcoord_transform_vs4x.glsl
	Transform position attribute and pass texture coordinate down the pipeline.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for MVP matrix; see demo code for hint
//	2) correctly transform input position by MVP matrix
//	3) declare attribute for texture coordinate
//		-> look in 'a3_VertexDescriptors.h' for the correct location index
//	4) declare varying for texture coordinate
//	5) copy texture coordinate attribute to varying

//Kelly and Zac
/*We both worked together in order to create the attributes for the shader as well as copying 
the texture coordinate attribute to the varying varuable. This will help to pass the info to the 
fragment shader*/
layout (location = 0) in vec4 aPosition;
layout (location = 8) in vec2 aTexcoord; // (3) in a3_VertexDescriptor.h

uniform mat4 uMVP;

out vec2 vPassTexCoord; //(4)

void main()
{
	gl_Position = uMVP * aPosition;

	vPassTexCoord = aTexcoord;
}
