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
	
	drawCustom_post_fs4x.glsl
	Custom post-processing fragment shader.
*/

#version 410

// ****TO-DO: 
//	0) start with texturing FS
//	1) declare any other uniforms, textures or otherwise, that would be 
//		appropriate for some post-processing effect
//	2) implement some simple post-processing algorithm (e.g. outlines)
const int MAX_LIGHTS = 10;

in vec2 vPassTexCoord; //(0)

uniform sampler2D uTex_dm; //(0)

layout (location = 0) out vec4 rtFragColor;

uniform int uLightCt; //(8)
uniform vec4  uLightPos[MAX_LIGHTS]; //position
uniform vec4  uLightCol[MAX_LIGHTS]; //intensity aka color
uniform float uLightSz[MAX_LIGHTS]; //attenuation

uniform double uTime;

void main()
{
	//kelly
	/*Create the variables to move around in the scene, also cast time as a float. This will allow us to use time
	as a float in the future*/
	vec4 fbo_tex_move = texture(uTex_dm, vec2(vPassTexCoord.x, vPassTexCoord.y));
	vec4 fbo_tex;// = texture(uTex_dm, vPassTexCoord);
	rtFragColor = fbo_tex_move;
	float newTime = float(uTime);

	//Zac
	/*Create upper and lower bounds of the square to move around. This will allow us to be able to manipulate this in the future*/
	float up, bot, mid;
	up = 0.7 + 0.1 * sin(newTime);
	bot = 0.3 + 0.2 *sin(newTime);
	mid = (up + bot) * 0.5;


	if (vPassTexCoord.x < up && vPassTexCoord.x >= bot && vPassTexCoord.y< up && vPassTexCoord.y >= bot)
	{
		//kelly
		/*Within the bottom left bounds, create a 4*4 texture and add a color to it. This creates an interesting post processing effect*/
		if(vPassTexCoord.x < mid && vPassTexCoord.x >= bot && vPassTexCoord.y< mid && vPassTexCoord.y >= bot) //bottom left
		{
			fbo_tex = texture(uTex_dm, vec2(vPassTexCoord.x*4, vPassTexCoord.y*4));
			fbo_tex *= vec4(sin(newTime) + 0.7, 0.3, 0.5, 1.0);
		}
		//Zac
		/*Within the other bounds of the box, create a 4*4 texture and add a color to it. This creates an interesting post processing effect*/
		//else if(vPassTexCoord.x < 0.7 && vPassTexCoord.x >= 0.5 && vPassTexCoord.y< 0.7 && vPassTexCoord.y >= 0.5)// top right  
		else if(vPassTexCoord.x < up + 0.3 * sin(newTime) && vPassTexCoord.x >= mid + 0.3 * sin(newTime) && vPassTexCoord.y< up + 0.4 * sin(newTime) && vPassTexCoord.y >= mid + 0.5 * sin(newTime))// top right  
		{
			fbo_tex = texture(uTex_dm, vec2(vPassTexCoord.x*4, vPassTexCoord.y*4));
			fbo_tex *= vec4(1.0 + cos(newTime), 1.0 + sin(newTime), 0.5 + 0.5 *sin(newTime), 1.0); 
		}
		else if(vPassTexCoord.x <mid + 0.3 * sin(newTime) && vPassTexCoord.x >= bot + 0.1* sin(newTime) && vPassTexCoord.y< up + 0.4 * sin(newTime) && vPassTexCoord.y >=bot + 0.1 * sin(newTime)) //top left    
		{
			fbo_tex = texture(uTex_dm, vec2(vPassTexCoord.x*4, vPassTexCoord.y*4));
		}
		else //bottom right
		{
			fbo_tex = texture(uTex_dm, vec2(vPassTexCoord.x*4, vPassTexCoord.y*4)) * fract(sin(dot(vPassTexCoord.xy, vec2(12,78))) * 43758 * sin(newTime));
		}
	}
	else
	{
		fbo_tex = texture(uTex_dm, vPassTexCoord);
		//fbo_tex = texture(uTex_dm, vec2( 0.01 * sin(newTime), vPassTexCoord.y));
	}
	
	rtFragColor = fbo_tex;
	


}
