/*
	Copyright 2011-2019 Daniel S. Buckstein
	“This file was modified by Kelly Herstine and Zachary Taylor with permission of the author.”

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
	
	a3_DemoState_idle-input.c/.cpp
	Demo state function implementations.

	****************************************************
	*** THIS IS ONE OF YOUR DEMO'S MAIN SOURCE FILES ***
	*** Implement your demo logic pertaining to      ***
	***     HANDLING INPUT in this file.             ***
	****************************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_DemoState.h"


//-----------------------------------------------------------------------------
// HANDLE INPUT

void a3demo_input(a3_DemoState *demoState, a3f64 dt)
{
	a3real ctrlRotateSpeed = 1.0f;
	a3real azimuth = 0.0f;
	a3real elevation = 0.0f;
	a3boolean rotatingCamera = 0, movingCamera = 0, changingParam = 0;
	a3_DemoCamera *camera = demoState->camera + demoState->activeCamera;


	// using Xbox controller
	if (a3XboxControlIsConnected(demoState->xcontrol))
	{
		// move and rotate camera using joysticks
		a3f64 lJoystick[2], rJoystick[2], lTrigger[1], rTrigger[1];
		a3XboxControlGetJoysticks(demoState->xcontrol, lJoystick, rJoystick);
		a3XboxControlGetTriggers(demoState->xcontrol, lTrigger, rTrigger);

		movingCamera = a3demo_moveSceneObject(camera->sceneObject, (a3f32)dt * camera->ctrlMoveSpeed,
			(a3real)(rJoystick[0]),
			(a3real)(*rTrigger - *lTrigger),
			(a3real)(-rJoystick[1])
		);
		// rotate
		{
			ctrlRotateSpeed = 10.0f;
			azimuth = (a3real)(-lJoystick[0]);
			elevation = (a3real)(lJoystick[1]);

			// this really defines which way is "up"
			// mouse's Y motion controls pitch, but X can control yaw or roll
			// controlling yaw makes Y axis seem "up", roll makes Z seem "up"
			rotatingCamera = a3demo_rotateSceneObject(camera->sceneObject,
				ctrlRotateSpeed * (a3f32)dt * camera->ctrlRotateSpeed,
				// pitch: vertical tilt
				elevation,
				// yaw/roll depends on "vertical" axis: if y, yaw; if z, roll
				demoState->verticalAxis ? azimuth : a3realZero,
				demoState->verticalAxis ? a3realZero : azimuth);
		}
	}

	// using mouse and keyboard
	else
	{
		// move using WASDEQ
		movingCamera = a3demo_moveSceneObject(camera->sceneObject, (a3f32)dt * camera->ctrlMoveSpeed,
			(a3real)a3keyboardGetDifference(demoState->keyboard, a3key_D, a3key_A),
			(a3real)a3keyboardGetDifference(demoState->keyboard, a3key_E, a3key_Q),
			(a3real)a3keyboardGetDifference(demoState->keyboard, a3key_S, a3key_W)
		);
		if (a3mouseIsHeld(demoState->mouse, a3mouse_left))
		{
			azimuth = -(a3real)a3mouseGetDeltaX(demoState->mouse);
			elevation = -(a3real)a3mouseGetDeltaY(demoState->mouse);

			// this really defines which way is "up"
			// mouse's Y motion controls pitch, but X can control yaw or roll
			// controlling yaw makes Y axis seem "up", roll makes Z seem "up"
			rotatingCamera = a3demo_rotateSceneObject(camera->sceneObject,
				ctrlRotateSpeed * (a3f32)dt * camera->ctrlRotateSpeed,
				// pitch: vertical tilt
				elevation,
				// yaw/roll depends on "vertical" axis: if y, yaw; if z, roll
				demoState->verticalAxis ? azimuth : a3realZero,
				demoState->verticalAxis ? a3realZero : azimuth);
		}
		
		float complexNumX = (a3real)a3keyboardGetDifference(demoState->keyboard, a3key_rightArrow, a3key_leftArrow);
		float complexNumY = (a3real)a3keyboardGetDifference(demoState->keyboard, a3key_downArrow, a3key_upArrow);
		//float power = (a3real)a3keyboardGetDifference(demoState->keyboard, a3key_B, a3key_K);
		//float iterations = (a3real)a3keyboardGetDifference(demoState->keyboard, a3key_C, a3key_V);



		complexNumX *= 0.0001f;
		complexNumY *= 0.0001f;
		//power += 1.0f;
		//iterations += 1.0f;

		complexNumX += demoState->complexNumber.x;
		complexNumY += demoState->complexNumber.y;
		//power += demoState->power;
		//iterations += demoState->maxIterations;


		a3real2Set(demoState->complexNumber.v, complexNumX, complexNumY);

		if (a3keyboardIsHeld(demoState->keyboard, a3key_1))
		{
			demoState->power = 7.0f;
			demoState->maxIterations = 15.0f;
			a3real2Set(demoState->complexNumber.v, 0.365f, 0.36f);
		}
		else if (a3keyboardIsHeld(demoState->keyboard, a3key_2))
		{
			demoState->power = 5.0f;
			demoState->maxIterations = 10.0f;
			a3real2Set(demoState->complexNumber.v, -1.4793f, 0.002f);
		}
		//demoState->scaleNumber = 1.0f;
		a3real2Set(demoState->centerNumber.v, 0.0f, 0.0f);
	}
}


//-----------------------------------------------------------------------------
