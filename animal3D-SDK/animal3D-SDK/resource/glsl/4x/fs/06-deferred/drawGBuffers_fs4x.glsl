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
	
	drawGBuffers_fs4x.glsl
	Output attributes to MRT ("g-buffers").
*/

#version 410
//done
// ****TO-DO: 
//	1) declare varyings (attribute data) to receive from vertex shader
//	2) declare g-buffer render targets
//	3) pack attribute data into outputs

layout(location = 0) out vec4 rtFragColor; //position // (2)
layout(location = 1) out vec4 rtFragColor1; //normal
layout(location = 2) out vec4 rtFragColor2; //texcoord


in vPassDataBlock
{
	vec4 vPassPosition;
	vec4 vPassNormal;


	vec4 vPassTexcoord;

} vPassData;

void main()
{
	//zac
	//Passing in the variables to the FSQ
	rtFragColor = vPassData.vPassPosition;
	rtFragColor1 = normalize(vPassData.vPassNormal);
	rtFragColor2 = vPassData.vPassTexcoord;
}
