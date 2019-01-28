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
	
	drawPhongMulti_mrt_fs4x.glsl
	Phong shading model with splitting to multiple render targets (MRT).
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong fragment shader
//	1) declare eight render targets
//	2) output appropriate data to render targets

//out vec4 rtFragColor;
//out vec4 rtFragColor1;
//out vec4 rtFragColor2;
//out vec4 rtFragColor3;

layout(location = 0) out vec4 rtFragColor;
layout(location = 1) out vec4 rtFragColor1;
layout(location = 2) out vec4 rtFragColor2;
layout(location = 3) out vec4 rtFragColor3;

//layout (location = 0) out vec4 rtPosition;
//layout (location = 1) out vec4 rtNormal;
//layout (location = 2) out vec4 rtTexCoord;
//layout (location = 3) out vec4 rtDiffuseMap;

void main()
{
	rtFragColor = vec4(0.5, 0.0, 0.5, 1.0);;

	//Depth doesnt count
	//How many shaders do we need? No, one fragment shader does everything you need

	//testing
	rtFragColor1 = vec4(1.0, 0.5, 0.0, 1.0);	//orange
	rtFragColor2 = vec4(1.0, 0.0, 1.0, 1.0);	//magenta
	rtFragColor3 = vec4(0.5, 0.0, 0.5, 1.0);	//purple

}
