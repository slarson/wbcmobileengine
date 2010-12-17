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


#include "wbcInteractiveScene.h"

#pragma mark Constructors

wbcInteractiveScene::wbcInteractiveScene()
{
	bIsLoaded = false;
	bShowAxes = false;
	bShowModels = false;
	bShowTraces = false;
	bShowImages = true;
	
	mCamera = new ofxCamera();
	mCamera->position(ofGetWidth()/2,ofGetHeight()/2,5000);
	mCamera->eye(ofGetWidth()/2,ofGetHeight()/2,0);
	
	mTileRender = new wbcTileRender();
	
		mModel = new ofx3DModelLoader();
		mModel->loadModel("neuron2.3ds", 3);
		mModel->setRotation(0, 180, 0, 0, 0);
		mModel->setRotation(1, -75, 0, 0, 0);
//	
	initializeLights();
}

void wbcInteractiveScene::loadResources(ofxGuiGlobals* guiPtr)
{
	bIsLoaded = true;
	
}

void wbcInteractiveScene::initializeLights()
{
	/* initialize lighting */
	
	lightOneColor[0] = 0.99;
	lightOneColor[1] = 0.0;
	lightOneColor[2] = 0.99; 
	lightOneColor[3] = 1.0;
	
	lightOneColor[0] = 0.99;
	lightTwoColor[1] = 0.0;
	lightTwoColor[2] = 0.99; 
	lightTwoColor[3] = 1.0;
	
	lightOnePosition[0] = 100.0;
	lightOnePosition[1] = 100.0;
	lightOnePosition[2] = 0.00;
	lightOnePosition[3] = 0.0;
	
	lightTwoPosition[0] = -100.0;
	lightTwoPosition[1] = 100.0;
	lightTwoPosition[2] = 0.0;
	lightTwoPosition[3] = 0.0;	
	
	//	GLfloat global_ambient[] = { 0.5f, 0.5f, 0.5f, 1.0f };
	//	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient);
	
    glLightfv (GL_LIGHT0, GL_POSITION, lightOnePosition);
    glLightfv (GL_LIGHT0, GL_DIFFUSE, lightOneColor);
    glEnable (GL_LIGHT0);
	
    glLightfv (GL_LIGHT1, GL_POSITION, lightTwoPosition);
    glLightfv (GL_LIGHT1, GL_DIFFUSE, lightTwoColor);
    glEnable (GL_LIGHT1);
	
	glEnable (GL_COLOR_MATERIAL);
}


void wbcInteractiveScene::linkToGui(ofxGuiGlobals* guiPtr)
{
	mGlobals = guiPtr;
}


#pragma mark -
#pragma mark Core Methods

void wbcInteractiveScene::updateScene(bool bPressDown)
{
	// do culling here
	
//	if(bIsLoaded)
//	{
//	if( mTileRender->bHasTileDescription)
//	{
	if(bIsLoaded)
	{
		mTileRender->setDownloadState(bPressDown);
		mTileRender->cullViewFrustum(mCamera);	
		mTileRender->updateScene();
	}
		
//	}
}


void wbcInteractiveScene::drawScene(bool _showModel)
{
	// reset flag, it increments after each bound texture, won't bind if value > 3?
	ofGetAppPtr()->baseAppTextureFlag = 0;
	
	ofBackground(255, 255,255);
	
	mCamera->place();
	
	if (mTileRender->bHasAllocatedTiles && bShowImages) {
		mTileRender->drawScene();
	}
	
	if (bShowTraces) {
		mTileRender->drawTraces();
	}
	
	if(_showModel)
	{
		ofSetColor(255, 255, 255, 150);
		glEnable(GL_LIGHTING);

		GLfloat eqn[4] = {0.0, 0.0, 1.0, 0.0};

//		GLdouble *eq
//		get_plane_equation(verts[0], verts[1], verts[2], eq);
		
		GLuint MY_CLIP_PLANE = GL_CLIP_PLANE0;
		glEnable(MY_CLIP_PLANE);
		glClipPlanef(MY_CLIP_PLANE, eqn);
	//	glClipPlanef(<#GLenum plane#>, <#const GLfloat *equation#>)
		
		
		mModel->draw();
		
		glDisable(MY_CLIP_PLANE);
		
		glDisable(GL_LIGHTING);
	}
	
	if (bShowAxes) {  renderAxes();	}
}

void wbcInteractiveScene::renderAxes()
{
	glLineWidth(3.0f);
	const GLfloat verticesX[] = {
		0,0,0,
		1000,0,0,
	};
	
	const GLfloat verticesY[] = {
		0,0,0,
		0,1000,0,
	};
	
	const GLfloat verticesZ[] = {
		0,0,0,
		0,0,1000,
	};
	
	glEnable(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, verticesX);
	glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
	glDrawArrays(GL_LINES, 0, 2);
	
	glVertexPointer(3, GL_FLOAT, 0, verticesY);
	glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
	glDrawArrays(GL_LINES, 0, 2);
	
	glVertexPointer(3, GL_FLOAT, 0, verticesZ);
	glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
	glDrawArrays(GL_LINES, 0, 2);
	glDisable(GL_VERTEX_ARRAY);	
	
	glLineWidth(1.0f);
}


#pragma mark -
#pragma mark Primitives that may be of use from cinder

void wbcInteractiveScene::drawCubeImpl( const ofxVec3f &c, const ofxVec3f &size, bool drawColors )
{
	GLfloat sx = size.x * 0.5f;
	GLfloat sy = size.y * 0.5f;
	GLfloat sz = size.z * 0.5f;
	GLfloat vertices[24*3]={c.x+1.0f*sx,c.y+1.0f*sy,c.z+1.0f*sz,	c.x+1.0f*sx,c.y+-1.0f*sy,c.z+1.0f*sz,	c.x+1.0f*sx,c.y+-1.0f*sy,c.z+-1.0f*sz,	c.x+1.0f*sx,c.y+1.0f*sy,c.z+-1.0f*sz,		// +X
		c.x+1.0f*sx,c.y+1.0f*sy,c.z+1.0f*sz,	c.x+1.0f*sx,c.y+1.0f*sy,c.z+-1.0f*sz,	c.x+-1.0f*sx,c.y+1.0f*sy,c.z+-1.0f*sz,	c.x+-1.0f*sx,c.y+1.0f*sy,c.z+1.0f*sz,		// +Y
		c.x+1.0f*sx,c.y+1.0f*sy,c.z+1.0f*sz,	c.x+-1.0f*sx,c.y+1.0f*sy,c.z+1.0f*sz,	c.x+-1.0f*sx,c.y+-1.0f*sy,c.z+1.0f*sz,	c.x+1.0f*sx,c.y+-1.0f*sy,c.z+1.0f*sz,		// +Z
		c.x+-1.0f*sx,c.y+1.0f*sy,c.z+1.0f*sz,	c.x+-1.0f*sx,c.y+1.0f*sy,c.z+-1.0f*sz,	c.x+-1.0f*sx,c.y+-1.0f*sy,c.z+-1.0f*sz,	c.x+-1.0f*sx,c.y+-1.0f*sy,c.z+1.0f*sz,	// -X
		c.x+-1.0f*sx,c.y+-1.0f*sy,c.z+-1.0f*sz,	c.x+1.0f*sx,c.y+-1.0f*sy,c.z+-1.0f*sz,	c.x+1.0f*sx,c.y+-1.0f*sy,c.z+1.0f*sz,	c.x+-1.0f*sx,c.y+-1.0f*sy,c.z+1.0f*sz,	// -Y
		c.x+1.0f*sx,c.y+-1.0f*sy,c.z+-1.0f*sz,	c.x+-1.0f*sx,c.y+-1.0f*sy,c.z+-1.0f*sz,	c.x+-1.0f*sx,c.y+1.0f*sy,c.z+-1.0f*sz,	c.x+1.0f*sx,c.y+1.0f*sy,c.z+-1.0f*sz};	// -Z
	
	
	static GLfloat normals[24*3]={ 1,0,0,	1,0,0,	1,0,0,	1,0,0,
		0,1,0,	0,1,0,	0,1,0,	0,1,0,
		0,0,1,	0,0,1,	0,0,1,	0,0,1,
		-1,0,0,	-1,0,0,	-1,0,0,	-1,0,0,
		0,-1,0,	0,-1,0,  0,-1,0,0,-1,0,
		0,0,-1,	0,0,-1,	0,0,-1,	0,0,-1};
	
	static GLubyte colors[24*4]={	255,0,0,255,	255,0,0,255,	255,0,0,255,	255,0,0,255,	// +X = red
		0,255,0,255,	0,255,0,255,	0,255,0,255,	0,255,0,255,	// +Y = green
		0,0,255,255,	0,0,255,255,	0,0,255,255,	0,0,255,255,	// +Z = blue
		0,255,255,255,	0,255,255,255,	0,255,255,255,	0,255,255,255,	// -X = cyan
		255,0,255,255,	255,0,255,255,	255,0,255,255,	255,0,255,255,	// -Y = purple
		255,255,0,255,	255,255,0,255,	255,255,0,255,	255,255,0,255 };// -Z = yellow
	
	static GLfloat texs[24*2]={	0,1,	1,1,	1,0,	0,0,
		1,1,	1,0,	0,0,	0,1,
		0,1,	1,1,	1,0,	0,0,							
		1,1,	1,0,	0,0,	0,1,
		1,0,	0,0,	0,1,	1,1,
		1,0,	0,0,	0,1,	1,1 };
	
	static GLubyte elements[6*6] ={	0, 1, 2, 0, 2, 3,
		4, 5, 6, 4, 6, 7,
		8, 9,10, 8, 10,11,
		12,13,14,12,14,15,
		16,17,18,16,18,19,
		20,21,22,20,22,23 };
	
	glEnableClientState( GL_NORMAL_ARRAY );
	glNormalPointer( GL_FLOAT, 0, normals );
	
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer( 2, GL_FLOAT, 0, texs );
	
	if( drawColors ) {
		glEnableClientState( GL_COLOR_ARRAY );	
		glColorPointer( 4, GL_UNSIGNED_BYTE, 0, colors );		
	}
	
	glEnableClientState( GL_VERTEX_ARRAY );	 
	glVertexPointer( 3, GL_FLOAT, 0, vertices );
	
	glDrawElements( GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, elements );
	
	glDisableClientState( GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );	 
	glDisableClientState( GL_NORMAL_ARRAY );
	if( drawColors )
		glDisableClientState( GL_COLOR_ARRAY );
	
}

void wbcInteractiveScene::drawCube( const ofxVec3f &center, const ofxVec3f &size )
{
	drawCubeImpl( center, size, false );
}

void wbcInteractiveScene::drawColorCube( const ofxVec3f &center, const ofxVec3f &size )
{
	drawCubeImpl( center, size, true );
}

// http://local.wasp.uwa.edu.au/~pbourke/texture_colour/spheremap/  Paul Bourke's sphere code
// We should weigh an alternative that reduces the batch count by using GL_TRIANGLES instead
void wbcInteractiveScene::drawSphere( const ofxVec3f &center, float radius, int segments )
{
	if( segments < 0 )
		return;
	
	float *verts = new float[(segments+1)*2*3];
	float *normals = new float[(segments+1)*2*3];
	float *texCoords = new float[(segments+1)*2*2];
	
	glEnableClientState( GL_VERTEX_ARRAY );
	glVertexPointer( 3, GL_FLOAT, 0, verts );
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
	glEnableClientState( GL_NORMAL_ARRAY );
	glNormalPointer( GL_FLOAT, 0, normals );
	
	for( int j = 0; j < segments / 2; j++ ) {
		float theta1 = j * 2 * 3.14159f / segments - ( 3.14159f / 2.0f );
		float theta2 = (j + 1) * 2 * 3.14159f / segments - ( 3.14159f / 2.0f );
		
		for( int i = 0; i <= segments; i++ ) {
			ofxVec3f e, p;
			float theta3 = i * 2 * 3.14159f / segments;
			
			e.x = cosf( theta1 ) * cosf( theta3 );
			e.y = sinf( theta1 );
			e.z = cosf( theta1 ) * sinf( theta3 );
			p = e * radius + center;
			normals[i*3*2+0] = e.x; normals[i*3*2+1] = e.y; normals[i*3*2+2] = e.z;
			texCoords[i*2*2+0] = 0.999f - i / (float)segments; texCoords[i*2*2+1] = 0.999f - 2 * j / (float)segments;
			verts[i*3*2+0] = p.x; verts[i*3*2+1] = p.y; verts[i*3*2+2] = p.z;
			
			e.x = cosf( theta2 ) * cosf( theta3 );
			e.y = sinf( theta2 );
			e.z = cosf( theta2 ) * sinf( theta3 );
			p = e * radius + center;
			normals[i*3*2+3] = e.x; normals[i*3*2+4] = e.y; normals[i*3*2+5] = e.z;
			texCoords[i*2*2+2] = 0.999f - i / (float)segments; texCoords[i*2*2+3] = 0.999f - 2 * ( j + 1 ) / (float)segments;
			verts[i*3*2+3] = p.x; verts[i*3*2+4] = p.y; verts[i*3*2+5] = p.z;
		}
		glDrawArrays( GL_TRIANGLE_STRIP, 0, (segments + 1)*2 );
	}
	
	glDisableClientState( GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
	glDisableClientState( GL_NORMAL_ARRAY );
	
	delete [] verts;
	delete [] normals;
	delete [] texCoords;
}

void wbcInteractiveScene::drawCoordinateFrame( float axisLength, float headLength, float headRadius )
{
	glColor4ub( 255, 0, 0, 255 );
	drawVector( ofxVec3f(0,0,0), ofxVec3f(1,0,0) * axisLength, headLength, headRadius );
	glColor4ub( 0, 255, 0, 255 );
	drawVector(ofxVec3f(0,0,0), ofxVec3f(0,1,0) * axisLength, headLength, headRadius );
	glColor4ub( 0, 0, 255, 255 );
	drawVector( ofxVec3f(0,0,0), ofxVec3f(0,0,1) * axisLength, headLength, headRadius );
}

void wbcInteractiveScene::drawVector( const ofxVec3f &start, const ofxVec3f &end, float headLength, float headRadius )
{
	const int NUM_SEGMENTS = 32;
	float lineVerts[3*2];
	ofxVec3f coneVerts[NUM_SEGMENTS+2];
	glEnableClientState( GL_VERTEX_ARRAY );
	glVertexPointer( 3, GL_FLOAT, 0, lineVerts );
	lineVerts[0] = start.x; lineVerts[1] = start.y; lineVerts[2] = start.z;
	lineVerts[3] = end.x; lineVerts[4] = end.y; lineVerts[5] = end.z;	
	glDrawArrays( GL_LINES, 0, 2 );
	
	// Draw the cone
	ofxVec3f axis = ( end - start ).normalized();
	ofxVec3f temp = ( axis.dot( ofxVec3f(0,1,0) ) > 0.999f ) ? axis.cross( ofxVec3f(1,0,0) ) : axis.cross( ofxVec3f(0,1,0) );
	ofxVec3f left = axis.cross( temp ).normalized();
	ofxVec3f up = axis.cross( left ).normalized();
	
	glVertexPointer( 3, GL_FLOAT, 0, &coneVerts[0].x );
	coneVerts[0] = ofxVec3f( end + axis * headLength );
	for( int s = 0; s <= NUM_SEGMENTS; ++s ) {
		float t = s / (float)NUM_SEGMENTS;
		coneVerts[s+1] = ofxVec3f( end + left * headRadius * cosf( t * 2 * 3.14159f )
								  + up * headRadius * sinf( t * 2 * 3.14159f ) );
	}
	glDrawArrays( GL_TRIANGLE_FAN, 0, NUM_SEGMENTS+2 );
	
	// draw the cap
	glVertexPointer( 3, GL_FLOAT, 0, &coneVerts[0].x );
	coneVerts[0] = end;
	for( int s = 0; s <= NUM_SEGMENTS; ++s ) {
		float t = s / (float)NUM_SEGMENTS;
		coneVerts[s+1] = ofxVec3f( end - left * headRadius * cosf( t * 2 * 3.14159f )
								  + up * headRadius * sinf( t * 2 * 3.14159f ) );
	}
	glDrawArrays( GL_TRIANGLE_FAN, 0, NUM_SEGMENTS+2 );
	
	glDisableClientState( GL_VERTEX_ARRAY );
}


