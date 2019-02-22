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
	
	drawDeferredLightingComposite_fs4x.glsl
	Composite deferred lighting.
*/

#version 410

// ****TO-DO: 
//	1) declare images with results of lighting pass
//	2) declare remaining geometry inputs (atlas coordinates) and atlas textures
//	3) declare any other shading variables not involved in lighting pass
//	4) sample inputs to get components of Phong shading model
//		-> surface colors, lighting results
//		-> *test by outputting as color
//	5) compute final Phong shading model (i.e. the final sum)

in vec2 vPassTexCoord;

layout (location = 0) out vec4 rtFragColor;

uniform sampler2D uImage4, uImage5, uImage6; //

uniform sampler2D uTex_dm; //(2)
uniform sampler2D uTex_sm;

void main()
{
	vec4 gDiffuse = texture(uImage4, vPassTexCoord); //(2)
	vec4 gSpecular = texture(uImage5, vPassTexCoord);
	vec2 gTexcoord = texture(uImage6, vPassTexCoord).xy;

	//Diffuse and specular text
	vec4 DiffuseTex = texture(uTex_dm, gTexcoord);

	//add together


	// DUMMY OUTPUT: all fragments are FADED CYAN
	//rtFragColor = vec4(0.5, 1.0, 1.0, 1.0);
	//rtFragColor = vec4(gTexcoord, 0.0, 1.0);
	//rtFragColor = vec4(vPassTexCoord, 0.0, 1.0);
	//rtFragColor = gSpecular;
	//rtFragColor = vec4(DiffuseTex.xyz * gDiffuse.xyz,gDiffuse.a) ;
}
