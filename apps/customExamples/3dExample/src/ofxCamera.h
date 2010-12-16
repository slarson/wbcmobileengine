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

#pragma once

#include "ofMain.h"
#include "ofxVectorMath.h"
#include "ofxQuat.h"
#include "glu.h"
#include "ofxWBCglobals.h"

class ofxCamera{
public:
	
	ofxCamera();

	void position(float x, float y, float z);
	void position(ofxVec3f _pos);
	void position(); //reset the position to initial values
	void lerpPosition(float _x, float _y, float _z, float _step); //step should be a value between 0 and 1
	void lerpPosition(ofxVec3f _pos, float _step); //step should be a value between 0 and 1
	void lerpEye(float _x, float _y, float _z, float _step); //step should be a value between 0 and 1
	void lerpEye(ofxVec3f _pos, float _step); //step should be a value between 0 and 1
	void slerpEye(ofxVec3f target, float time);

	//
	ofxVec3f convertToLocal(ofxVec3f _v);
	ofxVec3f convertToLocal(float _x, float _y, float _z);
	void tumble(float _px, float _py, float _x, float _y);
	ofxVec3f compArcBallVector(float _x, float _y);
	void track(float _px, float _py, float _x, float _y);
	void dolly(float _px, float _py, float _x, float _y);


	
	
	// frustum stuffs
	//
	void				extractFrustum();
//	bool				inFrustum(ofxVec3f _location);
	bool				inFrustum(ofxVec3f _location, float _distanceFromTileSize);

	float				frustum[6][4];
	int					mFrustReset;

	float				eProj[16];
	float				eModel[16];
	int					eViewport[4];
	
	void				updateViewport();
	void				updateModelandProjectMatrices();

	ofxVec3f			pointInSpaceFromScreenCoords(ofxPoint2f _point);

	void				pan(ofxPoint2f _previous, ofxPoint2f _current);
	void				panOld(ofxPoint2f _previous, ofxPoint2f _current);

	void				zoomProportional(float _scale);
	
	void eye(float _x, float _y, float _z);
	void eye(ofxVec3f _eye);
	void eye(); //reset eye psition to the initial values
	void up(float _x, float _y, float _z);
	void up(ofxVec3f _up);
	void up(); //reset up vector to initial values

	void perspective(float _fov, float _aspect, float _zNear, float _zFar);
	void perspective();//reset perspective to initial values

	void frameRegion(ofxPoint2f _origin, ofxPoint2f _size);

	
	void place(); //this must go in the draw function
	void remove(); //Removes the camera, so it returns as if there was no camera
	
	void moveLocal(float _x, float _y, float _z); //Moves the camera along it's own coordinatesystem
	void moveLocal(ofxVec3f move);
	void moveGlobal(float _x, float _y, float _z); //Moves the camera along the global coordinatesystem
	void moveGlobal(ofxVec3f move);

	void orbitAround(ofxVec3f target, ofxVec3f axis, float value);
    void qorbitAround(ofxVec3f target, ofxVec3f axis, float value);
	void rotate(ofxVec3f axis, float value);
	void qrotate(ofxVec3f axis, float value);
	void setViewByMouse(int MouseX, int MouseY);

	ofxVec3f getDir();
	ofxVec3f getPosition();
	ofxVec3f getEye();
	ofxVec3f getUp();
	
	float		getFarNearRatio();
	bool		isZooming();	
	void		setZooming(bool _shouldZoom); // sets zooming true

private:
	ofxVec3f posCoord;
	ofxVec3f eyeCoord;
	ofxVec3f upVec;

	//relative to defining the persperctive:
	float	fieldOfView;
	int	w;
	int	h;
	float	aspectRatio;
	float zNear, zFar;
	
	bool bOrthographic;
	
	bool		bZooming;
	ofxVec3f	initialZoomVector;
	ofxVec3f	baseDisplacementVector;
};



