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
	
	drawBrightPass_fs4x.glsl
	Perform bright pass filter: bright stays bright, dark gets darker.
*/

#version 410

// ****TO-DO: 
//	1) implement a function to calculate the relative luminance of a color
//	2) implement a general tone-mapping or bright-pass filter
//	3) sample the input texture
//	4) filter bright areas, output result

in vec2 vPassTexcoord;

float brightPassMin = 0.2;

uniform sampler2D uImage0;

layout (location = 0) out vec4 rtFragColor;

//kelly
// This funtion calculates the relative luminance of a given color. 
// It first has a luminance vector containing the values for rgb that the color will be multiplied by
// It then multiples them together using the dot product, and finally caps the result using the bright pass minium,
// outputing the result
float relativeLuminance(in vec4 color)
{
	//relativeLuminance
	vec3 lumVector = vec3(0.2126,0.7152,0.0722);

	//multiplu the vector by the lum;
	float lum = dot(lumVector, color.rgb);

	//less than this value, filter color out
	lum = max(0.0, lum - brightPassMin);

	return lum;
}


void main()
{
	vec4 sample0 = texture(uImage0, vPassTexcoord);
	
	float lum = relativeLuminance(sample0);
	
	sample0.xyz *= lum;
		
	rtFragColor = sample0;
		
	// DUMMY OUTPUT: all fragments are ORANGE
	//rtFragColor = vec4(1.0, 0.5, 0.0, 1.0);
	// DEBUGGING
	//vec4 sample0 = texture(uImage0, vPassTexcoord);
	//rtFragColor = vec4(vPassTexcoord, 0.0, 1.0);
	//rtFragColor = 0.1 + sample0;
	//rtFragColor =  vec4(lum, lum, lum , 1.0);
}
