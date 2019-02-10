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
	vec4 fbo_tex_move = texture(uTex_dm, vec2(vPassTexCoord.x, vPassTexCoord.y));
	vec4 fbo_tex;// = texture(uTex_dm, vPassTexCoord);
	rtFragColor = fbo_tex_move;
	float newTime = float(uTime);
	if (vPassTexCoord.x < 0.7 && vPassTexCoord.x >= 0.3 && vPassTexCoord.y< 0.7 && vPassTexCoord.y >= 0.3)
	{
		//kelly
		if(vPassTexCoord.x < 0.5 && vPassTexCoord.x >= 0.3 && vPassTexCoord.y< 0.5 && vPassTexCoord.y >= 0.3) //bottom left
		{
			fbo_tex = texture(uTex_dm, vec2(vPassTexCoord.x*4, vPassTexCoord.y*4));
			fbo_tex *= vec4(sin(newTime) + 0.7, 0.3, 0.5, 1.0);
		}
		//else if(vPassTexCoord.x < 0.7 && vPassTexCoord.x >= 0.5 && vPassTexCoord.y< 0.7 && vPassTexCoord.y >= 0.5)// top right  
		else if(vPassTexCoord.x < 0.7 + 0.3 * sin(newTime) && vPassTexCoord.x >= 0.5 + 0.3 * sin(newTime) && vPassTexCoord.y< 0.7 + 0.4 * sin(newTime) && vPassTexCoord.y >= 0.5 + 0.5 * sin(newTime))// top right  
		{
			fbo_tex = texture(uTex_dm, vec2(vPassTexCoord.x*4, vPassTexCoord.y*4));
			fbo_tex *= vec4(1.0 + cos(newTime), 1.0 + sin(newTime), 0.5 + 0.5 *sin(newTime), 1.0); 
		}
		else if(vPassTexCoord.x < 0.5 + 0.3 * sin(newTime) && vPassTexCoord.x >= 0.3 + 0.1* sin(newTime) && vPassTexCoord.y< 0.7 + 0.4 * sin(newTime) && vPassTexCoord.y >= 0.3 + 0.1 * sin(newTime)) //top left    
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
	}
	

	//fbo_tex *= vec4(0.5, 0.5, 1.0, 1.0);

	// DUMMY OUTPUT: all fragments are NORMAL MAP BLUE
	//rtFragColor = vec4(0.5, 0.5, 1.0, 1.0);
	//rtFragColor = vec4(vPassTexCoord, 0.0, 1.0);
	//rtFragColor = vec4(vec2(vPassTexCoord.x, vPassTexCoord.y + 10), 0.0, 1.0);
	//rtFragColor = texture(uTex_dm, vPassTexCoord);
	rtFragColor = fbo_tex;
	//rtFragColor = vec4(0.5f+0.5f*sin(uTime * 10.0), 0.5f + 0.5f*sin(uTime * 10.0), 0.5f + 0.5f*sin(uTime * 10.0), 1.0);
	//rtFragColor = vec4(0.5f + 0.5f*sin(newTime), 0.0, 0.0, 1.0);//), 0.5f + 0.5f*sin(newTime * 10.0), 0.5f + 0.5f*sin(newTime * 10.0), 1.0);P
	//rtFragColor = vec4(max(uTime, 0.0), 0.0, 0.0, 1.0);
	


}
