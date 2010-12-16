/*****************************************************************************
 Copyright   2010   The Regents of the University of California All Rights Reserved
 
 Permission to copy, modify and distribute any part of this WHOLE BRAIN CATALOG MOBILE
 for educational, research and non-profit purposes, without fee, and without a written
 agreement is hereby granted, provided that the above copyright notice, this paragraph
 and the following three paragraphs appear in all copies.
 
 Those desiring to incorporate this WHOLE BRAIN CATALOG MOBILE into commercial products
 or use for commercial purposes should contact the Technology Transfer Office, University of California, San Diego, 
 9500 Gilman Drive, Mail Code 0910, La Jolla, CA 92093-0910, Ph: (858) 534-5815,
 FAX: (858) 534-7345, E-MAIL:invent@ucsd.edu.
 
 IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR DIRECT, 
 INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, 
 ARISING OUT OF THE USE OF THIS WHOLE BRAIN CATALOG MOBILE, EVEN IF THE UNIVERSITY
 OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 THE WHOLE BRAIN CATALOG MOBILE PROVIDED HEREIN IS ON AN "AS IS" BASIS, AND THE 
 UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, 
 ENHANCEMENTS, OR MODIFICATIONS.  THE UNIVERSITY OF CALIFORNIA MAKES NO REPRESENTATIONS 
 AND EXTENDS NO WARRANTIES OF ANY KIND, EITHER IMPLIED OR EXPRESS, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE,
 OR THAT THE USE OF THE WHOLE BRAIN CATALOG MOBILE WILL NOT INFRINGE ANY PATENT, 
 TRADEMARK OR OTHER RIGHTS. 
 *********************************************************************************
 
 Developed by Rich Stoner, Sid Vijay, Stephen Larson, and Mark Ellisman
 
 Initial Release Date: November, 2010 
 
 For more information, visit wholebraincatalog.org/app 
 
 ***********************************************************************************/


#ifndef WBC_INTERACTIVE_SCENE
#define WBC_INTERACTIVE_SCENE

#include "ofxWBCglobals.h"
#include "ofxGuiGlobals.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "wbcTileRender.h"
#include "ofx3DModelLoader.h"

#include "wbcDynamicElement.h"


class wbcInteractiveScene 
{
public:
	
	wbcInteractiveScene();
	
	ofxGuiGlobals*		mGlobals;  

	void				loadResources(ofxGuiGlobals* _ptr);
	void				linkToGui(ofxGuiGlobals* _ptr); //needed here, as it has a globals pointer
	
	bool				bIsLoaded;
	
	void				updateScene(bool bPressDown);
	void				drawScene(bool _showModels);
	
	void				renderAxes();
	
	ofxCamera*			mCamera;
	
	wbcTileRender*		mTileRender;
	
	void drawCoordinateFrame( float axisLength, float headLength, float headRadius );
	void drawVector( const ofxVec3f &start, const ofxVec3f &end, float headLength, float headRadius );
	void drawSphere( const ofxVec3f &center, float radius, int segments );
	void drawColorCube( const ofxVec3f &center, const ofxVec3f &size );
	void drawCube( const ofxVec3f &center, const ofxVec3f &size );
	void drawCubeImpl( const ofxVec3f &c, const ofxVec3f &size, bool drawColors );

	void initializeLights();
	ofx3DModelLoader*	mModel;
	float lightOneColor[4];
	float lightTwoColor[4];
	float lightOnePosition[4];
	float lightTwoPosition[4];
	
	bool  bShowModels;
	bool  bShowTraces;
	bool  bShowAxes;
	bool  bShowImages;
};

#endif