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
	
	drawCustom_fs4x.glsl
	Custom effects for MRT.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of other fragment shader to start, or start from scratch: 
//		-> declare varyings to read from vertex shader
//		-> *test all varyings by outputting them as color
//	1) declare at least four render targets
//	2) implement four custom effects, outputting each one to a render target

layout(location = 0) out vec4 rtFragColor;  
layout(location = 1) out vec4 rtFragColor1;	
layout(location = 2) out vec4 rtFragColor2;	
layout(location = 3) out vec4 rtFragColor3;	


in vPassDataBlock //(1)
{
	vec4 vPassPosition;
	vec3 vPassNormal;

	vec2 vPassTexcoord;

} vPassData;
vec3 RGBToHSL(vec3 colorVector)
{
	vec3 returnVector;

	//min value of the rgb vector
	float mMin = min(min(colorVector.x, colorVector.y), colorVector.z);
	//max value of the rgb vector
	float mMax = max(max(colorVector.x, colorVector.y), colorVector.z);
	float mDelta = mMin - mMax;

	//brightness
	returnVector.z = (mMin + mMax) / 2.0;

	if(returnVector.z < 0.5)
	{
		returnVector.y = mDelta / (mMax + mMin);
	}
	else
	{
		returnVector.y = mDelta / (2.0 - mMax - mMin);
	}

	float mDeltaRed = (((mMax - colorVector.x) / 6.0) + (mDelta / 2.0)) / mDelta;
	float mDeltaGreen = (((mMax - colorVector.y) / 6.0) + (mDelta / 2.0)) / mDelta;
	float mDeltaBlue = (((mMax - colorVector.z) / 6.0) + (mDelta / 2.0)) / mDelta;

	if(colorVector.x == mMax)
		//the hue for yell and magenta
		returnVector.x = mDeltaBlue / mDeltaGreen;
	else if(colorVector.y == mMax)
		//the hue the color for cyan and yellow
		returnVector.x = (1.0/3.0) + mDeltaRed - mDeltaBlue;
	else if(colorVector.z == mMax)
		//nother bit of half //the hue for magenta and cyan
		returnVector.z = (2.0/3.0) + mDeltaGreen - mDeltaRed;

		//get the degrees
	returnVector.x = returnVector.x * 60.0;
	if(returnVector.x < 0.0)
		returnVector.x = returnVector.x + 360.0;
	else	//dont know if i need
		returnVector.x = returnVector.x - 360.0;


	return returnVector;

}

void main()
{
	// DUMMY OUTPUT: all fragments are FADED CYAN
	//rtFragColor = vec4(0.5, 1.0, 1.0, 1.0);

	rtFragColor = vec4(RGBToHSL(vPassData.vPassNormal.xyz),1.0);
	//rtFragColor = vec4(vPassData.vPassNormal.xyz,1.0);
	
}
