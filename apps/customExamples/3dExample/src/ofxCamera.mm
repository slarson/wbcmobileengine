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


#include "ofxCamera.h"

#define FRUSTUM_RESET_LIMIT 5

#define ZSCALE_MIN			100.0f
#define ZSCALE_MAX			100.0f

#pragma mark -
#pragma mark Constructor

ofxCamera::ofxCamera(){
	perspective();
	position();
	eye();
	up();
	
	mFrustReset = 0; // reset triggered every 30 draws, calls extract
	bOrthographic = false;
	bZooming = false;
}


#pragma mark -

//void ofxCamera::startTumble()
//{
//	relx = getDir().getCrossed(getUp()).normalize();
//	rely = getDir().getCrossed(relx).normalize();
//}
//
//void ofxCamera::tumble(int _dx, int _dy)
//{
//	ofxVec3f rot = relx * (float)_dy + rely * -(float)_dx;
//
//	qorbitAround(getEye(), rot, rot.length());
//}
//	


ofxVec3f ofxCamera::convertToLocal(ofxVec3f _v)
{
	return convertToLocal(_v.x, _v.y, _v.z);
}

ofxVec3f ofxCamera::convertToLocal(float _x, float _y, float _z)
{
	ofxVec3f localZ = eyeCoord - posCoord;
	localZ.normalize();
	ofxVec3f localX = localZ.getCrossed(upVec).normalize();
	ofxVec3f localY = localZ.getCrossed(localX).normalize();
	
	ofxVec3f v = (localX * _x) + (localY * _y) + (localZ * _z);
	return v;
}

void ofxCamera::tumble(float _px, float _py, float _x, float _y)
{
	float tolerance = 0.01;
	
	if (fabs(_x - _px) < tolerance && fabs(_y - _py) < tolerance)
		return; // Not enough change to have an action.
	
	/* 
	 The arcball works by pretending that a ball encloses the 3D view.  
	 You roll this pretend ball with the mouse.  For example, if you click on 
	 the center of the ball and move the mouse straight to the right, you 
	 roll the ball around its Y-axis.  This produces a Y-axis rotation.  
	 You can click on the "edge" of the ball and roll it around in a circle 
	 to get a Z-axis rotation.
	 
	 The math behind the trackball is simple: start with a vector from the first
	 mouse-click on the ball to the center of the 3D view.  At the same time, set 
	 the radius of the ball to be the smaller dimension of the 3D view.  
	 As you drag the mouse around in the 3D view, a second vector is computed from 
	 the surface of the ball to the center.  The axis of rotation is the cross 
	 product of these two vectors, and the angle of rotation is the angle between 
	 the two vectors.
	 */
	
	ofxVec3f arcBallStart = compArcBallVector(_px, _py);
	ofxVec3f arcBallEnd = compArcBallVector(_x, _y);
	
	// Convert from screen position to world position
	arcBallStart = convertToLocal(arcBallStart);
	arcBallEnd = convertToLocal(arcBallEnd);
	
	//-------------------------------------------
	// Figure the axis and angle of rotation between the start and end point.
	
	float cosAng, sinAng, angle;
	float ls, le;
	
	// Take the cross product of the two vectors. r = s X e
	ofxVec3f axis = arcBallStart.getCrossed(arcBallEnd);
	
	// Use atan for a better angle.  If you use only cos or sin, you only get
	// half the possible angles, and you can end up with rotations that flip 
	// around near the poles.
	
	// cos(a) = (s . e) / (||s|| ||e||)
	cosAng = arcBallStart.dot(arcBallEnd); // (s . e)
	ls = arcBallStart.length();
	ls = 1.0 / ls; // 1 / ||s||
	le = arcBallEnd.length();
	le = 1.0 / le; // 1 / ||e||
	cosAng = cosAng * ls * le;
	
	// sin(a) = ||(s X e)|| / (||s|| ||e||)
	sinAng = axis.length(); // ||(s X e)||
	sinAng = sinAng * ls * le;
	
	angle = atan2f(sinAng, cosAng);
	
	// Normalize the rotation axis.
	axis.normalize();
	
	//-------------------------------------------
	// Apply the rotation to the eye.
	
	ofxQuat rotation, point, rotated;
	
	ofxVec3f p = posCoord - eyeCoord; // eye moved to rotate around 0, 0, 0.
	point.set(p.x, p.y, p.z, 0);
	
	rotation.makeRotate(angle, axis);
	
	rotated = (rotation*point)*rotation.conj();
	
	posCoord = eyeCoord + rotated.asVec3();
	
	
	// Apply the rotation to the up vector.
	
	point.set(upVec.x, upVec.y, upVec.z, 0);
	
	rotated = (rotation*point)*rotation.conj();
	
	upVec = rotated.asVec3();
	
}

ofxVec3f ofxCamera::compArcBallVector(float _x, float _y)
{
	ofxVec3f v;
	
	float arcBallRadi;
	float arcBallX, arcBallY;
	float xxyy;
	
	// Make the radius of the arcball slightly smaller than the smalest dimension of the screen.
	if (w > h)
		arcBallRadi = (h * .95) * 1; // 0.5
	else
		arcBallRadi = (w * .95) * 1; // 0.5
	
	// Figure the center of the view.
	arcBallX = w * 0.5;
	arcBallY = h * 0.5;
	
	// Compute the vector from the surface of the ball to its center.
	v.x = arcBallX - _x;
	v.y = arcBallY - _y;
	xxyy = v.x * v.x + v.y * v.y;
	if (xxyy > arcBallRadi * arcBallRadi) {
		// Outside the sphere.
		v.z = 0.0;
	} else
		v.z = sqrt(arcBallRadi * arcBallRadi - xxyy);
	
	return v;
}

void ofxCamera::track(float _px, float _py, float _x, float _y)
{
	float dx = _px - _x;
	float dy = _py - _y;
	
	ofxVec3f offset = convertToLocal(dx, dy, 0);
	
	posCoord += offset;
	eyeCoord += offset;
}

void ofxCamera::dolly(float _px, float _py, float _x, float _y)
{
	float dx = _px - _x;
	float dy = _py - _y;
	
	ofxVec3f offset = convertToLocal(0, 0, -dx - dy);
	
	posCoord += offset;
}

//void Camera::mousePressed(ofMouseEventArgs& event) 
//{
//	if(mouseClicked && event.button == 0)
//	{
//		if(ofGetElapsedTimeMillis() - millis < 300)
//			reset();
//		
//		mouseClicked = false;;
//	}
//	else if(event.button == 0)
//	{
//		mouseClicked = true;
//		millis = ofGetElapsedTimeMillis();
//	}
//	
//	prevMouseX = event.x;
//	prevMouseY = event.y;
//}

//void Camera::mouseDragged(ofMouseEventArgs& event) 
//{
//	if(event.button == 0)
//	{
//		tumble(prevMouseX, prevMouseY, event.x, event.y);
//	}
//	else if(event.button == 1)
//	{
//		track(prevMouseX, prevMouseY, event.x, event.y);
//	}
//	else if(event.button == 2)
//	{
//		dolly(prevMouseX, prevMouseY, event.x, event.y);
//		setClippingPlane();
//	}
//	
//	prevMouseX = event.x;
//	prevMouseY = event.y;
//	
//	mouseClicked = false;;
//	
//}









#pragma mark -
#pragma mark Initial position, settings

void ofxCamera::position(float x, float y, float z){
	posCoord.x = x;
	posCoord.y = y;
	posCoord.z = z;
}
void ofxCamera::position(ofxVec3f _pos){
	posCoord = _pos;
}
void ofxCamera::position(){
	posCoord.x = (float)w/2.0f;
	posCoord.y = (float)h/2.0f;
	float halfFovRad = M_PI * fieldOfView / 360.0f;
	float theTan = tanf(halfFovRad);
	posCoord.z = posCoord.y/theTan;
}

void ofxCamera::lerpPosition(float _targetX, float _targetY, float _targetZ, float _step){
	posCoord.x += (_targetX - posCoord.x) * _step;
	posCoord.y += (_targetY - posCoord.y) * _step;
	posCoord.z += (_targetZ - posCoord.z) * _step;
}

void ofxCamera::lerpPosition(ofxVec3f target, float step){
	lerpPosition(target.x, target.y, target.z, step);
}

void ofxCamera::lerpEye(float _targetX, float _targetY, float _targetZ, float _step){
	eyeCoord.x += (_targetX - eyeCoord.x) * _step;
	eyeCoord.y += (_targetY - eyeCoord.y) * _step;
	eyeCoord.z += (_targetZ - eyeCoord.z) * _step;
}

void ofxCamera::lerpEye(ofxVec3f target, float step){
	lerpEye(target.x, target.y, target.z, step);
}

void ofxCamera::slerpEye(ofxVec3f target, float time)
{
    ofxQuat toRot, fromRot;
	
    ofxVec3f view = -posCoord + eyeCoord;
    ofxVec3f final_view = -posCoord + target;
	
    toRot.makeRotate(view,final_view);
    fromRot.makeRotate(0,view.x,view.y,view.z);
	
    fromRot.slerp(time,fromRot,toRot);
	
    eyeCoord = posCoord + fromRot*view;
	
}

void ofxCamera::eye(float x, float y, float z){
	eyeCoord.x = x;
	eyeCoord.y = y;
	eyeCoord.z = z;
}

void ofxCamera::eye(ofxVec3f _pos){
	eyeCoord = _pos;
}

void ofxCamera::eye(){
	eyeCoord.x = (float)w/2.0f;
	eyeCoord.y = (float)h/2.0f;
	eyeCoord.z = 0;
}


void ofxCamera::up(float _nx, float _ny, float _nz){
	upVec.x = _nx;
	upVec.y = _ny;
	upVec.z = _nz;
}

void ofxCamera::up(ofxVec3f _up){
	upVec = _up;
}


void ofxCamera::up(){
	upVec.x = 0;
	upVec.y = 1;
	upVec.z = 0;
}

void ofxCamera::perspective(float _fov, float _aspect, float _zNear, float _zFar){
	fieldOfView = _fov;
	aspectRatio = _aspect;
	if(_zNear==0) _zNear = 1.0;
	zNear = _zNear;
	zFar = _zFar;
}

void ofxCamera::perspective(){
	fieldOfView = 60.0f;
	
	w = ofGetWidth(); 
	h = ofGetHeight();
	aspectRatio = (float)w/(float)h;
	zNear = 1.0f;
	zFar = 1e6;
}

#pragma mark -
#pragma mark WBC additions

float ofxCamera::getFarNearRatio()
{
	return zFar / zNear;
	
}

ofxVec3f ofxCamera::pointInSpaceFromScreenCoords(ofxPoint2f _point)
{
	// assuming a fixed plane with norm: 0,0,1 and offset (D) = 0
	
	float xnear, ynear, znear, xfar, yfar, zfar;
	
	wbcUnProject(_point[0], _point[1], 0.0f,
				 eModel,
				 eProj,
				 eViewport,
				 &xnear, &ynear, &znear);
	
	wbcUnProject(_point[0], _point[1], 1.0f,
				 eModel,
				 eProj,
				 eViewport,
				 &xfar, &yfar, &zfar);
	
	ofxVec3f origin = ofxVec3f(xnear, ynear, znear);
	ofxVec3f endpoint = ofxVec3f(xfar, yfar, zfar);
	ofxVec3f dir = endpoint - origin;
	dir.normalize();
	
	float planeD = 0.000001f; // may need to set this to 0 instead?
	ofxVec3f planeNormal = ofxVec3f(0,0,-1);
	
	float angle = planeNormal.dot(dir);
	float v1d;
	
	if (angle == 0) {
	//	printf("doesn't intersect!\n");
	}
	else {
		v1d = planeNormal.dot(origin);
	}
	
	ofxVec3f intersectionPoint = origin + dir * ((planeD - v1d) / angle);
	
	
	return intersectionPoint;
}




void ofxCamera::pan(ofxPoint2f _previous, ofxPoint2f _current)
{
	
	ofxVec3f prev3d = pointInSpaceFromScreenCoords(_previous);
	ofxVec3f current3d = pointInSpaceFromScreenCoords(_current);
	
	ofxVec3f delta = current3d - prev3d;
	
	moveGlobal(delta[1], delta[0], delta[2]);
	
}


void ofxCamera::panOld(ofxPoint2f _previous, ofxPoint2f _current)
{
	float xpre, ypre, zpre;
	float xcur, ycur, zcur;
	float dx,dy,dz;
	
	float zplane = 0.5;
	
	wbcUnProject(_previous[0], _previous[1], zplane,
				 eModel,
				 eProj,
				 eViewport,
				 &xpre, &ypre, &zpre);
	
	
	wbcUnProject(_current[0], _current[1], zplane,
				 eModel,
				 eProj,
				 eViewport,
				 &xcur, &ycur, &zcur);
	
	//	printf("viewport: %d %d %d %d\n",eViewport[0],
	//		   eViewport[1],
	//		   eViewport[2],
	//		   eViewport[3]);
	
	dx = (xcur - xpre);
	dy = (ycur - ypre);
	dz = (zcur - zpre);
	
	//	printf("x: %f y: %f \t\t gives: %f %f %f, %f\n", _current[0], _current[1], dx, dy, dz, zplane);

	moveGlobal(-dy, -dx, dz);
}




void ofxCamera::frameRegion(ofxPoint2f _origin, ofxPoint2f _size)
{
	up();
	
	float imageAspectRatio = _size[0] / _size[1];
	
//	printf("[OFXCAM] (still doesn't work!) Framing regions, aspect ratios: %f %f\n", imageAspectRatio, aspectRatio);
	
	if (imageAspectRatio >= aspectRatio) {
		
		//float baseViewDistance = (ofGetWidth()/2) * tanf(M_PI*fieldOfView/360.0f);
		float distance = ((_size[1])) * tanf(M_PI*(1.5*fieldOfView)/360.0f);
		
		zNear = distance / ZSCALE_MIN;
		zFar  = distance * ZSCALE_MAX;
		
//		printf("znear %f zfar %f dist %f\n", zNear, zFar, distance);
		

		eye(_origin[0], _origin[1], 0.0f);
		position(_origin[0], _origin[1], distance);
		
//		eye(_size[0]/2, _size[1]/2, zNear);		
//		position(_size[0]/2, _size[1]/2, distance); // camera position
		
	} else if (imageAspectRatio < aspectRatio)
	{
		float distance = ((_size[0]))  * tanf(M_PI*(1.5*fieldOfView)/360.0f);
		
		//		zNear = distance / ZSCALE_MIN;
		//		zFar  = distance * ZSCALE_MAX;
		
		zNear = distance / ZSCALE_MIN;
		zFar  = distance * ZSCALE_MAX;
		
		
//		printf("znear %f zfar %f dist %f\n", zNear, zFar, distance);
		
		eye(_origin[0], _origin[1], 0.0f);
		position(_origin[0], _origin[1], distance);
		
//		eye(_size[0]/2, _size[1]/2, zNear);
//		position(_size[0]/2, _size[1]/2, distance); // camera position
//		
	}
	
	extractFrustum();
	
	
	//	
	//		
	//		
	//		float halfFov = fieldOfView / 2;
	//		float tHalfFov = tanf(M_PI*halfFov/180.0);
	//		
	//		float halfHeight = _size[0] / 2;
	//		float distance = (halfHeight / tHalfFov) - baseViewDistance;
	//		
	//
	//		
	//		printf("squarier: expected x y z %f %f %f\n", posCoord.x, posCoord.y, posCoord.z);
	//		
	//	} else if (imageAspectRatio > aspectRatio) {
	//		
	//		float distance = (_size[0]/2) * tanf(M_PI*(fieldOfView)/360.0f) - baseViewDistance;
	//		
	//		zNear = distance / 10.0f;
	//		zFar  = distance * 10.0f;
	//		
	//		eye(_size[0]/2, _size[1]/2, zNear);
	//		position(_size[0]/2, _size[1]/2, distance); // camera position
	//		
	//		
	//		
	//		
	//		
	//		//		 ofGetWidth() / tanf(M_PI * fieldOfView / 360.0f);
	//		//
	//		//		
	//		//		float distance = baseViewDistance * (_size[1] / ofGetHeight()); 
	//		//		
	//
	//		//		eye(_size[0]/2, _size[1]/2, zNear);
	//		//		position(_size[0]/2, _size[1]/2, distance);
	//		
	//		
	//		
	//		// image is more squat (bars above and below)
	//		// width is long axis
	//
	////		_size[1] = _size[0] / imageAspectRatio;
	////		
	////		printf("size x: %f\n", _size[0]);
	////		printf("size y: %f\n", _size[1]);
	////		
	////		float halfFov = fieldOfView / 2;
	////		float tHalfFov = tanf(M_PI*halfFov/180.0f);
	////		
	////		float halfWidth = _size[0] / 2;
	////		float distance = (halfWidth / tHalfFov);
	////		
	////		
	////		
	////		zNear = distance / 10.0f;
	////		zFar  = distance * 10.0f;
	////		
	////		eye(_size[0]/2, _size[1]/2, zNear);
	//
	////		
	////		printf("%f %f %f %f %f\n", halfFov, tHalfFov, halfWidth, distance, zNear);
	//
	//		printf("Flatter than window: expected x y z %f %f %f\n", posCoord.x, posCoord.y, posCoord.z);		
	//	}
}

#pragma mark -
#pragma mark Render commands

void ofxCamera::place(){
	
	if (bOrthographic) {
		
		glMatrixMode(GL_PROJECTION);           
		glLoadIdentity();                      
		glOrthof( 0, 768, 1024, 0, 100000, 0 );               
		glMatrixMode(GL_MODELVIEW);             
		glLoadIdentity();
		gluLookAt(posCoord[0], posCoord[1], posCoord[2], eyeCoord[0], eyeCoord[1], eyeCoord[2], upVec[0], upVec[1], upVec[2]);

	}
	else {
		
	//	
//		int w = ofGetWidth();
//		int h = ofGetHeight();
		
		//glMatrixMode(GL_PROJECTION);
//		glLoadIdentity();
//		
//		glOrthof(0.0f, h, 0.0f, w, -1.0f, 1.0f);
//		
//		glRotatef(90.0f, 0, 0, 1);
//			
//		glScalef(-1, 1, 1); 
		
		glMatrixMode(GL_PROJECTION);	
		glLoadIdentity();

		glRotatef(90, 0, 0, 1);
//		glTranslatef(w,-h,0);
		glScalef(-1, 1, 1);//
		
		gluPerspective(fieldOfView, aspectRatio, zNear, zFar);
		
		
		glMatrixMode(GL_MODELVIEW);	
		glLoadIdentity();
		
		gluLookAt(posCoord[0], posCoord[1], posCoord[2], eyeCoord[0], eyeCoord[1], eyeCoord[2], upVec[0], upVec[1], upVec[2]);
		
	}
	
	// call extract frustum every 60 frames (~ 1 sec)
	if (mFrustReset > FRUSTUM_RESET_LIMIT) {
		extractFrustum();
		mFrustReset = 0;
	}
	else {
		mFrustReset++;
	}

}

//Removes the camera, so it returns as if there was no camera
void ofxCamera::remove(){
	
	
}

#pragma mark -
#pragma mark Frustum work


void ofxCamera::extractFrustum()
{
	updateModelandProjectMatrices();
	
	float   clip[16];
	float   t;
	
	/* Combine the two matrices (multiply projection by modelview) */
	clip[ 0] = eModel[ 0] * eProj[ 0] + eModel[ 1] * eProj[ 4] + eModel[ 2] * eProj[ 8] + eModel[ 3] * eProj[12];
	clip[ 1] = eModel[ 0] * eProj[ 1] + eModel[ 1] * eProj[ 5] + eModel[ 2] * eProj[ 9] + eModel[ 3] * eProj[13];
	clip[ 2] = eModel[ 0] * eProj[ 2] + eModel[ 1] * eProj[ 6] + eModel[ 2] * eProj[10] + eModel[ 3] * eProj[14];
	clip[ 3] = eModel[ 0] * eProj[ 3] + eModel[ 1] * eProj[ 7] + eModel[ 2] * eProj[11] + eModel[ 3] * eProj[15];
	
	clip[ 4] = eModel[ 4] * eProj[ 0] + eModel[ 5] * eProj[ 4] + eModel[ 6] * eProj[ 8] + eModel[ 7] * eProj[12];
	clip[ 5] = eModel[ 4] * eProj[ 1] + eModel[ 5] * eProj[ 5] + eModel[ 6] * eProj[ 9] + eModel[ 7] * eProj[13];
	clip[ 6] = eModel[ 4] * eProj[ 2] + eModel[ 5] * eProj[ 6] + eModel[ 6] * eProj[10] + eModel[ 7] * eProj[14];
	clip[ 7] = eModel[ 4] * eProj[ 3] + eModel[ 5] * eProj[ 7] + eModel[ 6] * eProj[11] + eModel[ 7] * eProj[15];
	
	clip[ 8] = eModel[ 8] * eProj[ 0] + eModel[ 9] * eProj[ 4] + eModel[10] * eProj[ 8] + eModel[11] * eProj[12];
	clip[ 9] = eModel[ 8] * eProj[ 1] + eModel[ 9] * eProj[ 5] + eModel[10] * eProj[ 9] + eModel[11] * eProj[13];
	clip[10] = eModel[ 8] * eProj[ 2] + eModel[ 9] * eProj[ 6] + eModel[10] * eProj[10] + eModel[11] * eProj[14];
	clip[11] = eModel[ 8] * eProj[ 3] + eModel[ 9] * eProj[ 7] + eModel[10] * eProj[11] + eModel[11] * eProj[15];
	
	clip[12] = eModel[12] * eProj[ 0] + eModel[13] * eProj[ 4] + eModel[14] * eProj[ 8] + eModel[15] * eProj[12];
	clip[13] = eModel[12] * eProj[ 1] + eModel[13] * eProj[ 5] + eModel[14] * eProj[ 9] + eModel[15] * eProj[13];
	clip[14] = eModel[12] * eProj[ 2] + eModel[13] * eProj[ 6] + eModel[14] * eProj[10] + eModel[15] * eProj[14];
	clip[15] = eModel[12] * eProj[ 3] + eModel[13] * eProj[ 7] + eModel[14] * eProj[11] + eModel[15] * eProj[15];
	
	/* Extract the numbers for the RIGHT plane */
	frustum[0][0] = clip[ 3] - clip[ 0];
	frustum[0][1] = clip[ 7] - clip[ 4];
	frustum[0][2] = clip[11] - clip[ 8];
	frustum[0][3] = clip[15] - clip[12];
	
	/* Normalize the result */
	t = sqrt( frustum[0][0] * frustum[0][0] + frustum[0][1] * frustum[0][1] + frustum[0][2] * frustum[0][2] );
	frustum[0][0] /= t;
	frustum[0][1] /= t;
	frustum[0][2] /= t;
	frustum[0][3] /= t;
	
	/* Extract the numbers for the LEFT plane */
	frustum[1][0] = clip[ 3] + clip[ 0];
	frustum[1][1] = clip[ 7] + clip[ 4];
	frustum[1][2] = clip[11] + clip[ 8];
	frustum[1][3] = clip[15] + clip[12];
	
	/* Normalize the result */
	t = sqrt( frustum[1][0] * frustum[1][0] + frustum[1][1] * frustum[1][1] + frustum[1][2] * frustum[1][2] );
	frustum[1][0] /= t;
	frustum[1][1] /= t;
	frustum[1][2] /= t;
	frustum[1][3] /= t;
	
	/* Extract the BOTTOM plane */
	frustum[2][0] = clip[ 3] + clip[ 1];
	frustum[2][1] = clip[ 7] + clip[ 5];
	frustum[2][2] = clip[11] + clip[ 9];
	frustum[2][3] = clip[15] + clip[13];
	
	/* Normalize the result */
	t = sqrt( frustum[2][0] * frustum[2][0] + frustum[2][1] * frustum[2][1] + frustum[2][2] * frustum[2][2] );
	frustum[2][0] /= t;
	frustum[2][1] /= t;
	frustum[2][2] /= t;
	frustum[2][3] /= t;
	
	/* Extract the TOP plane */
	frustum[3][0] = clip[ 3] - clip[ 1];
	frustum[3][1] = clip[ 7] - clip[ 5];
	frustum[3][2] = clip[11] - clip[ 9];
	frustum[3][3] = clip[15] - clip[13];
	
	/* Normalize the result */
	t = sqrt( frustum[3][0] * frustum[3][0] + frustum[3][1] * frustum[3][1] + frustum[3][2] * frustum[3][2] );
	frustum[3][0] /= t;
	frustum[3][1] /= t;
	frustum[3][2] /= t;
	frustum[3][3] /= t;
	
	/* Extract the FAR plane */
	frustum[4][0] = clip[ 3] - clip[ 2];
	frustum[4][1] = clip[ 7] - clip[ 6];
	frustum[4][2] = clip[11] - clip[10];
	frustum[4][3] = clip[15] - clip[14];
	
	/* Normalize the result */
	t = sqrt( frustum[4][0] * frustum[4][0] + frustum[4][1] * frustum[4][1] + frustum[4][2] * frustum[4][2] );
	frustum[4][0] /= t;
	frustum[4][1] /= t;
	frustum[4][2] /= t;
	frustum[4][3] /= t;
	
	/* Extract the NEAR plane */
	frustum[5][0] = clip[ 3] + clip[ 2];
	frustum[5][1] = clip[ 7] + clip[ 6];
	frustum[5][2] = clip[11] + clip[10];
	frustum[5][3] = clip[15] + clip[14];
	
	/* Normalize the result */
	t = sqrt( frustum[5][0] * frustum[5][0] + frustum[5][1] * frustum[5][1] + frustum[5][2] * frustum[5][2] );
	frustum[5][0] /= t;
	frustum[5][1] /= t;
	frustum[5][2] /= t;
	frustum[5][3] /= t;
}


bool ofxCamera::inFrustum(ofxVec3f _location, float _distanceFromTileSize){
	
	int p;
	float dist;
	bool res = true;
	
	// made this change, only care about the up down left right, front back can be handled by z buffer
	for( p = 0; p < 4; p++ )
	{
		dist = frustum[p][0] * _location[0] + frustum[p][1] * _location[1] + frustum[p][2] * _location[2] + frustum[p][3];
		
		// scaled based on tile resolution (this will only cull anything outside 1/2 tile length at whichever scale being compared)
#pragma mark !! - change prior to production build
		if (dist < - _distanceFromTileSize) {
//			printf("%f %f %f failed plane %d\n", _location[0], _location[1], _location[2], p);
			return false;
		}
	}
	
	return res;	
}

void ofxCamera::updateViewport() {
	//	glGetFloatv(GL_PROJECTION_MATRIX,eProj);
	//	glGetFloatv(GL_MODELVIEW_MATRIX,eModel);
	
	glGetIntegerv(GL_VIEWPORT,eViewport);
}

void ofxCamera::updateModelandProjectMatrices()
{
	glGetFloatv(GL_PROJECTION_MATRIX,eProj);
	glGetFloatv(GL_MODELVIEW_MATRIX,eModel);
	glGetIntegerv(GL_VIEWPORT,eViewport);
	
}


#pragma mark -
#pragma mark Camera Movements

void ofxCamera::zoomProportional(float _scale)
{	
	
	float zPos = 0.0f;
	
	ofxVec3f dir = baseDisplacementVector.normalized();
	float length = baseDisplacementVector.length() * _scale;
	
	if ((length - zPos) > 500.0f) {
		posCoord = eyeCoord + dir*length;		
	}
	
	
	
//	
//	
//	ofxVec3f displacement = posCoord - eyeCoord;
//	
//	
//	
//	displacement.rescale( _scale );
//	
//	ofxVec3f dir =  getDir().normalized();
//	posCoord += dir.rescaled(displacement.z);
////	eyeCoord += dir.rescaled(move.z);
//	
//	posCoord += upVec.rescaled(displacement.y);
////	eyeCoord += upVec.rescaled(move.y);
//	
//	posCoord += dir.cross(upVec).rescaled(displacement.x);
////	eyeCoord += dir.cross(upVec).rescaled(move.x);
	
}

void ofxCamera::setZooming(bool _shouldZoom) // sets zooming true
{
	bZooming = _shouldZoom;
	
	if (bZooming) {
		
		baseDisplacementVector = posCoord - eyeCoord;
	}
}

bool ofxCamera::isZooming()
{
	return bZooming;
}


void ofxCamera::moveLocal(float _x, float _y, float _z){
	moveLocal(ofxVec3f(_x, _y, _z));
}

void ofxCamera::moveLocal(ofxVec3f move){
	ofxVec3f dir =  getDir().normalized();
	posCoord += dir.rescaled(move.z);
	eyeCoord += dir.rescaled(move.z);
	
	posCoord += upVec.rescaled(move.y);
	eyeCoord += upVec.rescaled(move.y);
	
	posCoord += dir.cross(upVec).rescaled(move.x);
	eyeCoord += dir.cross(upVec).rescaled(move.x);
}

void ofxCamera::moveGlobal(float _x, float _y, float _z){
	posCoord.x += _x;
	posCoord.y += _y;
	posCoord.z += _z;
	eyeCoord.x += _x;
	eyeCoord.y += _y;
	eyeCoord.z += _z;
}
void ofxCamera::moveGlobal(ofxVec3f move){
	posCoord += move;
	eyeCoord += move;
}

void ofxCamera::orbitAround(ofxVec3f target, ofxVec3f axis, float value){
	ofxVec3f r = posCoord-target;
	posCoord = target + r.rotated(value, axis);
}

void ofxCamera::rotate(ofxVec3f axis, float value){
	ofxVec3f r = -posCoord+eyeCoord;
	eyeCoord = posCoord + r.rotated(value, axis);
}

void ofxCamera::qorbitAround(ofxVec3f target, ofxVec3f axis, float value)
{
    ofxQuat rot, view, result;
	
    //positive quaternion rotation is counter-clockwise so multiply by -1 to get clockwise
	
    float angle = (float)(-value*DEG_TO_RAD);
	
    ofxVec3f r = posCoord-target;
    view.set(r.x,r.y,r.z,0);
	
    rot.makeRotate(angle, axis.x, axis.y, axis.z);
	
    result = (rot*view)*rot.conj();
	
    posCoord = target + result.asVec3();
}

void ofxCamera::qrotate(ofxVec3f axis, float value)
{
    ofxQuat rot, view, result;
	
    //positive quaternion rotation is counter-clockwise so multiply by -1 to get clockwise
    float angle = (float)(-value*DEG_TO_RAD);
	
    ofxVec3f r = -posCoord+eyeCoord;
    view.set(r.x,r.y,r.z,0);
	
    rot.makeRotate(angle, axis.x, axis.y, axis.x);
	
    result = (rot*view)*rot.conj();
	
    eyeCoord = posCoord + result.asVec3();
}

void ofxCamera::setViewByMouse(int x, int y)
{
    ofxVec2f mouseDelta;
    float MouseSensitivity = 10.0f;
    float MiddleX = ofGetWidth()/2;
    float MiddleY = ofGetHeight()/2;
	
    if((x == MiddleX) && (y == MiddleY))
        return;
	
    // otherwise move the mouse back to the middle of the screen
	//    glutWarpPointer(MiddleX, MiddleY);
	
    mouseDelta.x = (MiddleX - x)/MouseSensitivity;
    mouseDelta.y = (MiddleY - y)/MouseSensitivity;
	
    // get the axis to rotate around the x-axis.
    ofxVec3f axis = eyeCoord - posCoord;
    axis.cross(upVec);
    // To be able to use the quaternion conjugate, the axis to
    // rotate around must be normalized.
    axis.normalize();
	
    // Rotate around the x axis
    qrotate(axis,mouseDelta.y);
    // Rotate around the y axis
    qrotate(ofxVec3f(0, 1, 0),mouseDelta.x);
}

#pragma mark -
#pragma mark Getters
//
ofxVec3f ofxCamera::getDir(){
	return eyeCoord-posCoord;
}

ofxVec3f ofxCamera::getPosition(){
	return posCoord;
}

ofxVec3f ofxCamera::getEye(){
	return eyeCoord;
}

ofxVec3f ofxCamera::getUp(){
	return upVec;
}


