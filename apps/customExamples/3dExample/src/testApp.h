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

/* WholeBrainCatalog Mobile Engine
 * This will serve as the core for the WBC mobile client and the Biosketch game

	Built on openframeworks for portability.  
	3D engine - openGL ES2.0 with 1.1 fallback 
	3D curve generation	(msainterpolator)
	2D gui with xml definitions - ofxgui with customizations
	Multiresolution tilerenderer - loosely based on stackvis (completely rewritten)
	XML parsing (wrapped TinyXML)
	Threaded downloading and event management (POCO)
	Central data management (WBCexchange)

 *	Engine
 *		Ambient and directional lighting
 *		Perspective and Orthogonal camera (from stackvis)
 *		CPU object culling (oolong engine)
 *		Render mesh, tiles, traces
 *
 *		Mesh
 *			Load model into scene (3ds, stl, obj, custom)
 *			Change render mode (point, wireframe, solid, transparent, future:shaders)
 *			Remove model from scene
 *			Define clip plane (user clip planes in ES1.1, shader in ES2.0)
 *			Optional: move model in 3D (not sure if this is needed)
 *
 *		Curves
 *			2D/3D interpolation for arbitrary precision
 *			linear and cubic interpolation methods
 *			Add/Remove points to curve 
 *			Select/Manipulate points with touch
 *		
 *		GUI
 *			Define/load from XML
 *			Animate control positions
 *			Toggle subgroups (panels)
 *			Controls available: panel, button, color slider, file list, knob, 
 *								matrix, points, radar, scope, slider, switch, xy pad
 *			
 *		Tile renderer
 *			Add tilegroup from URL
 *			sites supported: zoomify(general), brainmaps.org, ABA, ccdb
 *			recursive drawing
 *			multiple slides per tile group (equiv. to dataset from stackviz)
 *			support for multiple groups
 *			exclusive threaded tile downloader (does not interfere with WBCexchange download priorities)
 *
 *		Exchange (Data management)
 *			Handles interaction with data sources and local stores
 *			Populate list of data on brain-maps.org from local xml
 *			Populate list of zoomify reconstructions from ccdb via local xml
 *			Load zoomify data description from URL
 *			exclusive threaded file downloader (does not interfere with tile renderer)
 *			blocking downloader (pauses thread until file received)
 *			Can parse: 
 *				zoomify header (imageproperties.xml)
 *				ccdb traces (traces.xml)
 *				brainmaps tile list (slideslist)
 *				images
 */			

/* change log 

9/2/2010 configured local mercurial repo, created google code site 
 
 */

#pragma mark -
#pragma mark Includes

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxGui.h"
#include "ofxGuiTypes.h"
#include "ofxColorPicker.h"

//#include "ofxWBCengine.h"

#include "wbcMenu.h"
#include "wbcInteractiveScene.h"

#include "ofxALSoundPlayer.h"

// iphone specific, consider writing ifdefs
#include <MediaPlayer/MediaPlayer.h>


class testApp : public ofxiPhoneApp, public ofxGuiListener
{

public:
	
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);

	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	
	ofxGui*					activeGui;
	bool					bShowingOverlayGui;
	
	wbcScene				currentScene;
	wbcScene				previousScene;
	
	wbcMenu*				_Menu;
	wbcInteractiveScene*	_InteractiveScene;
	
	void					start2D();
	void					playDefaultVideoFullScreen();
	void					handleGui(int parameterId, int task, void* data, int length);
	void					handleZoom(float scale);
	void					handleRotation(float rotation);
	bool					isPressInROI(float touch_x, float touch_y, float x, float y, float width, float height);	
	bool					bPressDown;
	int						zoomResetCounter;
	
	bool					bShouldAttemptLoad;
	bool					bShowModel;
	
	ofxVec2f				touches[2];
	ofxVec2f				originalTouches[2];
	float					delta;
		
	wbcDynamicElement*		_homeButton; // wbc logo
	wbcDynamicElement*		_backButton; //
	wbcDynamicElement*		_creditsButton;
	wbcDynamicElement*		_resetViewButton;
	
	ofImage*				_creditsImage;
	
	int mTextureCount;
	void drawMetaData();

	int incrementTextureCount();
	int decrementTextureCount();
	
	// apple specific code here

	MPMoviePlayerController* _startMovie;
	

	
	
};
