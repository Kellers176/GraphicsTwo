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
	
	a3_Kinematics.c
	Implementation of kinematics solvers.
*/

#include "a3_Kinematics.h"


//-----------------------------------------------------------------------------

// FK solver
extern inline a3i32 a3kinematicsSolveForward(const a3_HierarchyState *hierarchyState)
{
	return a3kinematicsSolveForwardPartial(hierarchyState, 0, hierarchyState->poseGroup->hierarchy->numNodes);
}

extern inline a3i32 a3kinematicsSolveForwardObjects(const a3_DemoSceneHierarchy *hierarchyState,  a3_DemoSceneObject *objectInfo)
{
	return a3kinematicsSolveForwardPartialObjects(hierarchyState, objectInfo, 0, hierarchyState->numNodes);
}

// partial FK solver
extern inline a3i32 a3kinematicsSolveForwardPartial(const a3_HierarchyState *hierarchyState, const a3ui32 firstIndex, const a3ui32 nodeCount)
{
	if (hierarchyState && hierarchyState->poseGroup && 
		firstIndex < hierarchyState->poseGroup->hierarchy->numNodes && nodeCount)
	{
		// ****TO-DO: implement forward kinematics algorithm
		a3ui32 i, end = firstIndex + nodeCount;
		for (i = firstIndex; i < end; i++)
		{
			//blah blah
			//else
			// general forward kinematics: 
			// given local transforms for hierarchy nodes, calculate object-space: 
			//		if not root, 
			//			object-space node = object-space parent * local-space node
			//		else
			//			object-space node = local-space node
			if (firstIndex == (hierarchyState->poseGroup->hierarchy->nodes[i].parentIndex < 0))
			{
				a3real4x4Product(hierarchyState->objectSpace->transform[i].m, hierarchyState->objectSpace->transform[hierarchyState->poseGroup->hierarchy->nodes[i].parentIndex].m, hierarchyState->localSpace->transform[i].m );
			}
			else
				hierarchyState->objectSpace->transform[i] = hierarchyState->localSpace->transform[i];
		}
	}
	return -1;
}

inline a3i32 a3kinematicsSolveForwardPartialObjects(const a3_DemoSceneHierarchy *hierarchyState,  a3_DemoSceneObject *objectInfo, const a3ui32 firstIndex, const a3ui32 nodeCount)
{/*
	if (hierarchyState && hierarchyState->poseGroup &&
		firstIndex < hierarchyState->poseGroup->hierarchy->numNodes && nodeCount)
	{*/
		// ****TO-DO: implement forward kinematics algorithm
		a3ui32 i, end = firstIndex + nodeCount;
		for (i = firstIndex; i < end; i++)
		{
			//blah blah
			//else
			// general forward kinematics: 
			// given local transforms for hierarchy nodes, calculate object-space: 
			//		if not root, 
			//			object-space node = object-space parent * local-space node
			//		else
			//			object-space node = local-space node
			a3i32 parent = hierarchyState->nodes[i].parentIndex;
			if (a3hierarchyDemoStateIsParentNode(hierarchyState, parent, i))
			{
				a3real4x4Product(objectInfo[i].modelMat.m, objectInfo[parent].modelMat.m, objectInfo[i].localModelMat.m);
			}
			else
				a3real4x4SetReal4x4(objectInfo[i].modelMat.m, objectInfo[i].localModelMat.m);
				//hierarchyState->objectInfo[i].modelMat = hierarchyState->objectInfo[i].localModelMat;
		}
	//}
	return -1;
}


//-----------------------------------------------------------------------------

// IK solver
extern inline a3i32 a3kinematicsSolveInverse(const a3_HierarchyState *hierarchyState)
{
	return a3kinematicsSolveInversePartial(hierarchyState, 0, hierarchyState->poseGroup->hierarchy->numNodes);
}

// partial IK solver
extern inline a3i32 a3kinematicsSolveInversePartial(const a3_HierarchyState *hierarchyState, const a3ui32 firstIndex, const a3ui32 nodeCount)
{
	if (hierarchyState && hierarchyState->poseGroup &&
		firstIndex < hierarchyState->poseGroup->hierarchy->numNodes && nodeCount)
	{
		// ****TO-DO: implement inverse kinematics algorithm

	}
	return -1;
}


//-----------------------------------------------------------------------------
