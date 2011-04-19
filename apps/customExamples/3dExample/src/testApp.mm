
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


#include "testApp.h"

#pragma mark Setup

// add device-specific defines here, load gui according to device
void testApp::setup()
{	
	bShowModel = false;
	bShouldAttemptLoad = false;
	
	mTextureCount = 0;
	zoomResetCounter = 0;
	baseAppTextureFlag = 0;
	
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	
#pragma mark - Setup Iphone-specific calls
	
	ofRegisterTouchEvents(this);		// register touch events	
	ofxAccelerometer.setup();			// initialize the accelerometer
	ofxiPhoneAlerts.addListener(this);	// iPhoneAlerts will be sent to this.
	ofEnableAlphaBlending();
	ofSetVerticalSync(true);
	ofDisableSetupScreen();
	
#pragma mark - Setup OpenGL ES environment
	
	glDepthFunc ( GL_LESS );	
	glEnable(GL_DEPTH_TEST);
	glShadeModel(GL_SMOOTH);
	
	glCullFace  ( GL_FRONT 	);
	glFrontFace ( GL_CCW 	);
	
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	glHint( GL_GENERATE_MIPMAP_HINT		  , GL_NICEST );
	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	
	
	playDefaultVideoFullScreen();
	
#pragma mark - Device-specific calls
	
#pragma mark Iphone
	
	if (ofGetWidth() == 480) {
		
		// iphone
		
#pragma mark - Credits Image and location
		_creditsImage = new ofImage();
		_creditsImage->loadImage(ofToDataPath("creditsV2.png"));
		
#pragma mark - Load gui from xml
		
		activeGui =	ofxGui::Instance(this);
		activeGui->buildFromXml("ofxGuiIphone.xml");
		activeGui->mObjects[0]->disable(); // default menu setup
		bShowingOverlayGui = false;
		
		_homeButton = new wbcDynamicElement();
		_homeButton->title = "Home";
		_homeButton->setSize(50, 50);
		_homeButton->setPos(ofGetWidth() - 50, ofGetHeight() - 50);
		_homeButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_homeButton->disableAllEvents();
		_homeButton->enableTouchEvents();
		_homeButton->parameterID = 301;
		_homeButton->baseImage.loadImage(ofToDataPath("defaulthome.png"));
		_homeButton->hideText();
		_homeButton->bDrawFrame = false;
		_homeButton->mGlobals = activeGui->mGlobals;
		_homeButton->bIsToggle = true;
		_homeButton->enabled = false;		
		
		_backButton = new wbcDynamicElement();
		_backButton->title = "Back";
		_backButton->setSize(50, 50);
		_backButton->setPos(0, ofGetHeight()-50);
		_backButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_backButton->disableAllEvents();
		_backButton->enableTouchEvents();
		_backButton->parameterID = 302;
		_backButton->baseImage.loadImage(ofToDataPath("iconback.png"));
		_backButton->hideText();
		_backButton->bDrawFrame = false;
		_backButton->mGlobals = activeGui->mGlobals;
		_backButton->bIsToggle = true;
		_backButton->enabled = false;
		
		_creditsButton = new wbcDynamicElement();
		_creditsButton->title = "About";
		_creditsButton->setSize(50, 50);
		_creditsButton->setPos(0, ofGetHeight()-50);
		_creditsButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_creditsButton->disableAllEvents();
		_creditsButton->enableTouchEvents();
		_creditsButton->parameterID = 303;
		_creditsButton->baseImage.loadImage(ofToDataPath("about.png"));
		_creditsButton->hideText();
		_creditsButton->bDrawFrame = false;
		_creditsButton->mGlobals = activeGui->mGlobals;
		_creditsButton->bIsToggle = true;
		_creditsButton->enabled = true;
		
		_resetViewButton = new wbcDynamicElement();
		_resetViewButton->title = "ResetView";
		_resetViewButton->setSize(50, 50);
		_resetViewButton->setPos(ofGetWidth() - 120, ofGetHeight() - 50);
		_resetViewButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_resetViewButton->disableAllEvents();
		_resetViewButton->enableTouchEvents();
		_resetViewButton->parameterID = 304;
		_resetViewButton->baseImage.loadImage(ofToDataPath("resetView.png"));
		_resetViewButton->hideText();
		_resetViewButton->bDrawFrame = false;
		_resetViewButton->mGlobals = activeGui->mGlobals;
		_resetViewButton->bIsToggle = true;
		_resetViewButton->enabled = false;
	}
	else {
		// ipad
		
		
#pragma mark Ipad
		
#pragma mark - Credits Image and location
		_creditsImage = new ofImage();
		_creditsImage->loadImage(ofToDataPath("creditsV2.png"));
		
#pragma mark - Load gui from xml
		
		activeGui =	ofxGui::Instance(this);
		activeGui->buildFromXml("ofxGuiIpad.xml");
		activeGui->mObjects[0]->disable(); // default menu setup
		bShowingOverlayGui = false;
		
		_homeButton = new wbcDynamicElement();
		_homeButton->title = "Home";
		_homeButton->setSize(90, 90);
		_homeButton->setPos(ofGetWidth() - 90, ofGetHeight() - 90);
		_homeButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_homeButton->disableAllEvents();
		_homeButton->enableTouchEvents();
		_homeButton->parameterID = 301;
		_homeButton->baseImage.loadImage(ofToDataPath("defaulthome.png"));
		_homeButton->hideText();
		_homeButton->bDrawFrame = false;
		_homeButton->mGlobals = activeGui->mGlobals;
		_homeButton->bIsToggle = true;
		_homeButton->enabled = false;		
		
		_backButton = new wbcDynamicElement();
		_backButton->title = "Back";
		_backButton->setSize(90, 90);
		_backButton->setPos(0, ofGetHeight()- 90);
		_backButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_backButton->disableAllEvents();
		_backButton->enableTouchEvents();
		_backButton->parameterID = 302;
		_backButton->baseImage.loadImage(ofToDataPath("iconback.png"));
		_backButton->hideText();
		_backButton->bDrawFrame = false;
		_backButton->bIsToggle = true;
		_backButton->mGlobals = activeGui->mGlobals;
		_backButton->enabled = false;
		
		_creditsButton = new wbcDynamicElement();
		_creditsButton->title = "About";
		_creditsButton->setSize(90, 90);
		_creditsButton->setPos(0, ofGetHeight() - 90);
		_creditsButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_creditsButton->disableAllEvents();
		_creditsButton->enableTouchEvents();
		_creditsButton->parameterID = 303;
		_creditsButton->baseImage.loadImage(ofToDataPath("about.png"));
		_creditsButton->hideText();
		_creditsButton->bDrawFrame = false;
		_creditsButton->mGlobals = activeGui->mGlobals;
		_creditsButton->bIsToggle = true;
		_creditsButton->enabled = true;
		
		_resetViewButton = new wbcDynamicElement();
		_resetViewButton->title = "ResetView";
		_resetViewButton->setSize(90, 90);
		_resetViewButton->setPos(ofGetWidth() - 190, ofGetHeight() - 90);
		_resetViewButton->sharedFont = &activeGui->mGlobals->mHeadFont;
		_resetViewButton->disableAllEvents();
		_resetViewButton->enableTouchEvents();
		_resetViewButton->parameterID = 304;
		_resetViewButton->baseImage.loadImage(ofToDataPath("resetView.png"));
		_resetViewButton->hideText();
		_resetViewButton->bDrawFrame = false;
		_resetViewButton->mGlobals = activeGui->mGlobals;
		_resetViewButton->bIsToggle = true;
		_resetViewButton->enabled = false;
		
	}
	
	
	
#pragma mark - Set starting view
	
	currentScene =	WBC_Scene_IntroMovie; // this is a special case (0 = menu), 
	bPressDown = false;
	
#pragma mark - Load Menu resources
	
	_Menu = new wbcMenu(); // images, text, etc
	_Menu->linkToGui(activeGui->mGlobals);
	_Menu->loadResources(activeGui->mGlobals);
	
	//	_Menu->transitionTo(WBC_Scene_Menu);
	
#pragma mark - Load Interactive scene (previously called engine)
	
	_InteractiveScene = new wbcInteractiveScene();
	_InteractiveScene->bIsLoaded = false;
	_InteractiveScene->linkToGui(activeGui->mGlobals);
	
#pragma mark - Load sound environment 
	
	ofxALSoundPlayer::ofxALSoundPlayerSetListenerLocation(ofGetWidth()/2,0,ofGetHeight()/2);
	ofxALSoundPlayer::ofxALSoundPlayerSetReferenceDistance(10);
	ofxALSoundPlayer::ofxALSoundPlayerSetMaxDistance(500);
	ofxALSoundPlayer::ofxALSoundPlayerSetListenerGain(5.0);
	
	
}

void testApp::playDefaultVideoFullScreen()
{
	currentScene = WBC_Scene_IntroMovie;
	
	NSURL *myMovieURL;
	NSString *moviePath = [NSString	stringWithUTF8String:ofToDataPath("wbcmeintro44.mp4", true).c_str()];
	
	myMovieURL = [NSURL fileURLWithPath:moviePath];
	_startMovie = [[MPMoviePlayerController alloc] initWithContentURL:myMovieURL];
	_startMovie.controlStyle = MPMovieControlStyleNone;
	
	if (ofGetWidth() == 480) {
		[[_startMovie view] setFrame:CGRectMake(0, 0, 480, 320)];			
	}
	else {
		[[_startMovie view] setFrame:CGRectMake(0, 0, 1024, 768)];	
	}
	
	_startMovie.view.center = CGPointMake(ofGetHeight()/2, ofGetWidth()/2);
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI / 2);
	_startMovie.view.transform = transform;
	
	[ofxiPhoneGetGLView() addSubview:[_startMovie view]];
	
}

#pragma mark -
#pragma mark Update

int testApp::incrementTextureCount()
{
	mTextureCount++;
	return mTextureCount;
}


int testApp::decrementTextureCount()
{
	mTextureCount--;
	return mTextureCount;
}



//--------------------------------------------------------------
void testApp::update(){	
	
	switch (currentScene) {
		case WBC_Scene_IntroMovie:
			
			if (_startMovie.playbackState == MPMoviePlaybackStateStopped) {
				//		printf("called start play");
				[_startMovie play];
			}
			
			break;
			
		case WBC_Scene_Menu:
			
			ofxWBCUtil.clearMost();
			
		case WBC_Scene_Description:
			
			
			if (_Menu->bIsLoaded) {
				
				_Menu->update();
				
				if (_Menu->mItems.size() < 10)
				{
					if(bShouldAttemptLoad) 
					{	
						
						if(_Menu->loadCustomSitesIfPresent(true))
						{
							printf("loaded custom ok\n");
						}
						else {
							printf("could not find custom xml\n");
							_Menu->loadLocalSites(true);
							_Menu->loadBrainMapsFromLocalXML(5);
							
						}
						
						_Menu->transitionTo(WBC_Scene_Menu);	
						bShouldAttemptLoad = false;
					}
					
				}
			}
			
			
			break;
			
			
		case WBC_Scene_Detail:
			
			if(_InteractiveScene != NULL)
			{
				_InteractiveScene->updateScene(bPressDown);
			}
			
			if (zoomResetCounter < 5) {
				zoomResetCounter++;
			}
			else {
				bPressDown = false;
				zoomResetCounter = 0;
			}
			
			if(bShowingOverlayGui)
			{
				
				float tempbound = (float)mTextureCount;
				float tempqueue = (float)ofxWBCUtil.getQueueLength();
				activeGui->update(205, kofxGui_Set_Float, &tempbound, sizeof(float));
				activeGui->update(206, kofxGui_Set_Float, &tempqueue, sizeof(float));
			}
			
			break;
			
		default:
			break;
	}
}

#pragma mark -
#pragma mark Draw

//--------------------------------------------------------------
void testApp::draw(){
	ofEnableAlphaBlending();
	
	switch (currentScene) {
		case WBC_Scene_IntroMovie:
			break;
			
		case WBC_Scene_Menu:
			ofBackground(0, 0, 0);
			start2D();
		{
							
			_Menu->drawBaseMenu();
			
			if(_Menu->mItems.size() == 0)
			{
				
				ofSetColor(0xFF0000);
				activeGui->mGlobals->mParamFont.drawString("Attempting to load sets from network\n", 20, 50);
				ofSetColor(0xFFFFFF);
				
				bShouldAttemptLoad = true;
			}	
			
			_creditsButton->draw();
			
		}
			
			break;
			
		case WBC_Scene_Description:
			
			if (_Menu->bIsLoaded) {
				_Menu->drawDetailMenu();
			}
			
			break;
			
		case WBC_Scene_Detail:
			
			if (_InteractiveScene->bIsLoaded) {
				_Menu->getSelectedItem()->enabled = false;
				_InteractiveScene->drawScene(bShowModel);
			}			
			glLineWidth(1.0f);
			
			start2D();
		{
			_homeButton->draw();
			
			if (ofxWBCUtil.getQueueLength() > 10) {
				ofSetColor(0x00BB00);
				activeGui->mGlobals->mParamFont.drawString("Downloading...", 10, 10);
				ofSetColor(0xFFFFFF);
			}
			
			if (_backButton->enabled) {
				_backButton->draw();
				_resetViewButton->draw();
				
				drawMetaData();
				//	activeGui->mGlobals->mHeadFont.drawString("Textures bound: "+ ofToString(mTextureCount), 4, ofGetHeight()-24);
				//				activeGui->mGlobals->mHeadFont.drawString("Download queue: "+ ofToString(ofxWBCUtil.getQueueLength()), 4, ofGetHeight()-10);
				//				
				//
			}
			
			
			activeGui->draw();
			ofSetColor(0xCC0000);
			
			
			
		}
			
			break;
			
		case WBC_Scene_Credits:
			
			ofBackground(0, 0, 0);
			ofSetColor(0xFFFFFF);
			
			if (ofGetWidth()==480) {
				_creditsImage->draw(0, 0);				
			}
			else {
				_creditsImage->draw(0, 0, 1024, 683);
			}
			
			
			
			_creditsButton->draw();
			
			break;
			
			
		default:
			break;
	}
	
}



// sets the appropriate screen based on iphone orientation 
void testApp::start2D()
{
	//	glMatrixMode(GL_PROJECTION);
	//	glLoadIdentity();
	//	
	//	glOrthof(0.0f, ofGetHeight(), 0.0f, ofGetWidth(), -1.0f, 1.0f);
	//	glRotatef(-90.0f, 0, 0, 1);
	//	glScalef(-1, 1, 1); 
	//	
	//	glMatrixMode(GL_MODELVIEW);
	//	glLoadIdentity();
	
	int w = ofGetWidth();
	int h = ofGetHeight();
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glOrthof(0.0f, h, 0.0f, w, -1.0f, 1.0f);
	
	glRotatef(90.0f, 0, 0, 1);
	glTranslatef(w,-h,0);
	glScalef(-1, 1, 1); 
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
}

void testApp::drawMetaData()
{
	float strlength = activeGui->mGlobals->mHeadFont.stringWidth(_InteractiveScene->mTileRender->mTileDescription->mDisplayName);
	
	ofSetColor(0,0,0,255);
	ofFill();
	ofRect(ofGetWidth() - 20 - strlength, 10, strlength + 10, 30);
	
	ofSetColor(255,255,255,255);
	ofNoFill();
	ofRect(ofGetWidth() - 20 - strlength, 10, strlength + 10, 30);
	
	activeGui->mGlobals->mHeadFont.drawString(_InteractiveScene->mTileRender->mTileDescription->mDisplayName, ofGetWidth() - 15 - strlength, 28);
	
	ofSetColor(0,0,0,150);
	ofFill();
	ofRect(ofGetWidth() - 130, 44, 120, 75);
	
	ofSetColor(255,255,255,255);
	ofNoFill();
	ofRect(ofGetWidth() - 130, 44, 120, 75);
	
	activeGui->mGlobals->mHeadFont.drawString("Dimension", ofGetWidth() - 120, 64);
	
	ofSetColor(255, 240, 240);
	activeGui->mGlobals->mParamFont.drawString("Width: " + 
											   ofToString(_InteractiveScene->mTileRender->mTileDescription->mSlideList[0]->mWidth_px)
											   +"px",ofGetWidth() - 116, 85 );
	
	activeGui->mGlobals->mParamFont.drawString("Height: " + 
											   ofToString(_InteractiveScene->mTileRender->mTileDescription->mSlideList[0]->mHeight_px)
											   +"px",ofGetWidth() - 116, 106 );
}


#pragma mark -
#pragma mark Handle touch interaction

void testApp::handleGui(int parameterId, int task, void* data, int length)
{
	//	printf("handle gui called %d %d\n", parameterId, task);
	
	// data sets
	if (parameterId < 200) {
		
		switch (task) {
			case 0:
				
				if(currentScene == WBC_Scene_Menu)
				{
					
					
					_Menu->transitionTo(WBC_Scene_Description);
					
					currentScene = WBC_Scene_Description;
					
					_homeButton->enabled = false;
					
					_creditsButton->enabled = false;
					
				}
				break;
				
				
			case 1:
				
				
				_Menu->transitionTo(WBC_Scene_Menu);
				currentScene = WBC_Scene_Menu;
				
				
				if (_homeButton) {
					_homeButton->enabled = false;					
				}
				
				if (_creditsButton) {
					_creditsButton->enabled = true;					
				}
				
				
				
				
				
				break;
				
			case 2:
				
				if(currentScene == WBC_Scene_Description)
				{
					
					if (_Menu->getSelectedItem()->elementData->bHasMetaData) {
						
						if(_Menu->getSelectedItem()->parameterID == 2)
						{
							bShowModel = true;
						}
						else {
							bShowModel = false;
						}
						
						
						_Menu->transitionTo(WBC_Scene_Detail);
						
						_homeButton->enabled = true;
						_creditsButton->enabled = false;
						currentScene = WBC_Scene_Detail;
						
						
						try {
							_InteractiveScene->mTileRender->setDataDescription(_Menu->getSelectedItem()->elementData);
							_InteractiveScene->mCamera->frameRegion(ofxPoint2f(0,0), 
																	ofxPoint2f(_Menu->getSelectedItem()->elementData->mSlideList[0]->mWidth_px,
																			   _Menu->getSelectedItem()->elementData->mSlideList[0]->mHeight_px)
																	);
							
							_InteractiveScene->bIsLoaded = true;
							
						}
						catch (exception e) {
							printf("unable to set data description\n");
						}
						
						
						
					}
					else {
						
					}
				}
				
				
				break;				
			default:
				break;
		}
		
	}
	else if (parameterId < 300)
	{	
		switch (parameterId) {
				//aimt
			case 201:
				// axes
				if (_InteractiveScene) {
					_InteractiveScene->bShowAxes = *(bool*)data;					
				}
				
				
				//				animate1 = *(bool*)data;
				
				break;
			case 202:
				// images
				if (_InteractiveScene) {
					_InteractiveScene->bShowImages = *(bool*)data;
				}
				break;
			case 203:
				// meshes
				if (_InteractiveScene) {
					_InteractiveScene->bShowModels = *(bool*)data;				
				}
				break;
			case 204:
				if (_InteractiveScene) {
					_InteractiveScene->bShowTraces = *(bool*)data;
				}
				// traces
				
				break;
			default:
				break;
		}
		
		// active GUI range
		
		
	} 
	else if	(parameterId < 400)
	{
		switch (parameterId) {
			case 301:
				// home button
				if (!bShowingOverlayGui) {
					bShowingOverlayGui = true;
					for (int i = 0; i < activeGui->mObjects.size(); i++) 
					{
						activeGui->mObjects[i]->enable();
					}
					//activeGui->mObjects[0]->enable();
					_backButton->bIsSelected = false;
					_backButton->enabled = true;
					_resetViewButton->enabled = true;
				}
				else {
					
					bShowingOverlayGui = false;
					for (int i = 0; i < activeGui->mObjects.size(); i++) 
					{
						activeGui->mObjects[i]->disable();
					}
					//activeGui->mObjects[0]->disable();
					_backButton->enabled = false;
					_resetViewButton->enabled=false;
					
					
				}
				
				break;
				
			case 302:				
				// back button pressed
				
				
				_Menu->transitionTo(WBC_Scene_Description);
				currentScene = WBC_Scene_Description;
				
				_homeButton->enabled = false;
				_homeButton->bIsSelected = false;
				
				_backButton->enabled = false;
				_resetViewButton->enabled = false;
				
				bShowingOverlayGui = false;
				
				activeGui->mObjects[0]->disable();
				
				
				break;
				
			case 303:
				
				
				
				if (_creditsButton->bIsSelected)
				{
					
					currentScene = previousScene;
					_Menu->enableAllElements();
					
					
				}
				else {
					
					previousScene = currentScene;
					_Menu->disableAllElements();
					currentScene = WBC_Scene_Credits;
					
				}
				
				
				//
				//				
				//				// home button
				//				if (!bShowingCredits) {
				//					bShowingOverlayGui = true;
				//					activeGui->mObjects[0]->enable();
				//					_backButton->enabled = true;
				//				}
				//				else {
				//					
				//					bShowingOverlayGui = false;
				//					activeGui->mObjects[0]->disable();
				//					_backButton->enabled = false;
				//					
				//				}				
				break;
				
			case 304:
				
				// reset view selected
				
				if (_InteractiveScene) {
					
					_InteractiveScene->mCamera->frameRegion(ofxPoint2f(0,0), 
															ofxPoint2f(_Menu->getSelectedItem()->elementData->mSlideList[0]->mWidth_px,
																	   _Menu->getSelectedItem()->elementData->mSlideList[0]->mHeight_px)
															);
					
				}
				
				_resetViewButton->bIsSelected = false;
				
				break;
				
				
			default:
				break;
		}
		
		
	}
	
	
}

void testApp::handleRotation(float rotation)
{	
	//	switch (currentScene) {
	//		case WBC_Scene_Menu:
	//			if (_Menu) {				
	//				_Menu->scaleGrid(scale);
	//			}
	//			break;
	//		case WBC_Scene_Description:
	//			
	//			if (_Menu) {				
	//				_Menu->scaleGrid(scale);
	//			}
	//			break;
	//			
	//			
	//		case WBC_Scene_Detail:
	//			
	//			bPressDown = true;
	//			zoomResetCounter = 0;
	//			
	//			if (_InteractiveScene) {
	//				
	//				if (_InteractiveScene->mCamera->isZooming()) {
	//					_InteractiveScene->mCamera->zoomProportional(1/scale);
	//				}
	//				else {
	//					_InteractiveScene->mCamera->setZooming(true);
	//					_InteractiveScene->mCamera->zoomProportional(1/scale);
	//				}
	//			}
	//			
	//			break;
	//		default:
	//			break;
	//	}
}	

void testApp::handleZoom(float scale)
{	
	switch (currentScene) {
		case WBC_Scene_Menu:
			//			if (_Menu) {				
			//				_Menu->scaleGrid(scale);
			//			}
			break;
		case WBC_Scene_Description:
			
			//if (_Menu) {				
			//				_Menu->scaleGrid(scale);
			//			}
			break;
			
			
		case WBC_Scene_Detail:
			
			bPressDown = true;
			zoomResetCounter = 0;
			
			if (_InteractiveScene) {
				
				if (_InteractiveScene->mCamera->isZooming()) {
					_InteractiveScene->mCamera->zoomProportional(1/scale);
				}
				else {
					_InteractiveScene->mCamera->setZooming(true);
					_InteractiveScene->mCamera->zoomProportional(1/scale);
				}
			}
			
			break;
		default:
			break;
	}
}	


//--------------------------------------------------------------


void testApp::touchDown(ofTouchEventArgs &touch){
	//printf("numtouches: %d\n", touch.numTouches);
	
	bPressDown = true;
	
	bool handled = activeGui->mousePressed(touch);
	
	if(handled)
	{
		//do nothing
	}
	else 
	{
		
		switch (currentScene) {
			case WBC_Scene_Menu:
				break;
			case WBC_Scene_IntroMovie:
				
				[_startMovie stop];
				[[_startMovie view] removeFromSuperview];
				[_startMovie release];
				
				_Menu->transitionTo(WBC_Scene_Menu);
				currentScene = WBC_Scene_Menu;
				
				_homeButton->enabled = false;
				
				_creditsButton->enabled = true;
				_creditsButton->bIsSelected = false;
				_Menu->enableAllElements();
				
				
				break;
			case WBC_Scene_Description:
				break;
			case WBC_Scene_Detail:
				
				_InteractiveScene->mCamera->setZooming(false);
				
				break;
				
			case WBC_Scene_Credits:
				
				if (ofGetWidth() == 480) {
					
					if (isPressInROI(touch.x, touch.y, 262, 10, 197, 141))
					{
						activeGui->mGlobals->mTap.play();
						playDefaultVideoFullScreen();
						
						previousScene = WBC_Scene_Credits;
					}
					else if (isPressInROI(touch.x, touch.y, 281, 190, 54, 19))
					{
						activeGui->mGlobals->mTap.play();
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://www.wholebraincatalog.org/app"]];
						//					printf("WBC");
					}
					else if (isPressInROI(touch.x, touch.y, 317, 221, 54, 19))
					{
						activeGui->mGlobals->mTap.play();
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://ccdb.ucsd.edu"]];
						
						//					printf("CCDB");
					}
					else if (isPressInROI(touch.x, touch.y, 384, 250, 54, 19))
					{
						activeGui->mGlobals->mTap.play();				
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://brain-map.org"]];
						
						//					printf("aibs");
					}
					else if (isPressInROI(touch.x, touch.y, 223, 283, 54, 19))
					{
						activeGui->mGlobals->mTap.play();
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://brainmaps.org"]];
						//
						//					printf("brainmaps");
					}
					
					break;
				}
				else if(ofGetWidth()==1024) {
					//				(558, 21 416, 293
					//				
					//				 599 403 116 42
					//				 
					//				 677 473
					//				 
					//				 820 535
					//				 
					//				 478 601
					
					if (isPressInROI(touch.x, touch.y, 558, 21, 416, 293))
					{
						activeGui->mGlobals->mTap.play();
						playDefaultVideoFullScreen();
						
						previousScene = WBC_Scene_Credits;
					}
					else if (isPressInROI(touch.x, touch.y, 599, 403, 116, 42))
					{
						activeGui->mGlobals->mTap.play();
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://www.wholebraincatalog.org/app"]];
						//					printf("WBC");
					}
					else if (isPressInROI(touch.x, touch.y, 677, 473, 116, 42))
					{
						activeGui->mGlobals->mTap.play();
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://ccdb.ucsd.edu"]];
						
						//					printf("CCDB");
					}
					else if (isPressInROI(touch.x, touch.y, 820, 535, 116, 42))
					{
						activeGui->mGlobals->mTap.play();				
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://brain-map.org"]];
						
						//					printf("aibs");
					}
					else if (isPressInROI(touch.x, touch.y, 478, 601, 116, 42))
					{
						activeGui->mGlobals->mTap.play();
						[ofxiPhoneGetGLView() presentUIAlertWithURLnavigate:[NSURL URLWithString:@"http://brainmaps.org"]];
						//
						//					printf("brainmaps");
					}
					
					break;
					
					
					
				}
				
				
				
				
			default:
				break;
				
				
		}
		
		//		if (touch.numTouches == 1) {
		//			touches[touch.id-1] = 
		//		}
		//		
		
		touches[0] = ofxVec2f(touch.x, touch.y);			
	}
	
}											   


bool testApp::isPressInROI(float touch_x, float touch_y, float x, float y, float width, float height)
{
	bool inROI = false;
	
	inROI = (touch_x >= x && touch_y >= y) && (touch_x < x+width && touch_y < y+height);
	
	return inROI;
}	


//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
	
	bool handled = activeGui->mouseDragged(touch);
	
	bPressDown = true;
	
	
	if(handled) {}
	else {
		
		//int orientation = iPhoneGetOrientation();
		
		ofxVec2f currentTouch = ofxVec2f(touch.x, touch.y);
		
		//		float dx, dy;
		
		switch (touch.numTouches) {
			case 1:
				
				switch (currentScene) {
					case WBC_Scene_IntroMovie:
						break;
					case WBC_Scene_Menu:
						break;
					case WBC_Scene_Description:
						break;						
					case WBC_Scene_Detail:
						
						_InteractiveScene->mCamera->pan(touches[0], currentTouch);	
						
						
						//		dx = touches[touch.id-1].x - currentTouch.x;
						//						dy = touches[touch.id-1].y - currentTouch.y;
						//
						//						
						//						if(bShowingOverlayGui)
						//						{
						//							_InteractiveScene->mCamera->tumble(currentTouch.x, currentTouch.y,  touches[touch.id-1].x,  touches[touch.id-1].y);
						//						}
						//						else {
						//						
						//							_InteractiveScene->mCamera->track(currentTouch.x, currentTouch.y,  touches[touch.id-1].x,  touches[touch.id-1].y);
						//							
						//						//
						//						}
						
						
						//
						//
						
						//						tumble(prevMouseX, prevMouseY, event.x, event.y);
						
						//						_InteractiveScene->mCamera->tumble(dx, dy);
						//						
						////						
						
						//qorbitAround(ofxVec3f(0,0,0), ofxVec3f(0,1,0), dx);
						
						//						_InteractiveScene->mCamera->qorbitAround(ofxVec3f(0,0,0), ofxVec3f(1,0,0), dy);
						//						_InteractiveScene->mCamera->qorbitAround(ofxVec3f(0,0,0), ofxVec3f(0,1,0), dx);
						
						
						//						ofxVec3f rot = rely * (float)_dy + relx * -(float)_dx;
						
						//						_InteractiveScene->mCamera->qorbitAround(_InteractiveScene->mCamera->getEye(), 
						//																 ofxVec3f(1,0,0), dx);
						
						//						_InteractiveScene->mCamera->getUp().cross(_InteractiveScene->mCamera->getDir().normalize())
						//						
						//						_InteractiveScene->mCamera->qorbitAround(_InteractiveScene->mCamera->getEye(), _InteractiveScene->mCamera->getUp(), dx);
						//						
						touches[0] = currentTouch;
						
						
						break;
					default:
						break;
				}
				break;
				
				
				break;
			default:
				break;
		}
	}
	
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
	
	bool handled = activeGui->mouseReleased(touch);
	
	if(handled)
	{
		//do nothing
	}
	else {
		
	}
	
	
	if(currentScene == WBC_Scene_Detail)
	{
		if (!_InteractiveScene->mCamera->isZooming())
		{
			// no longer zooming
			bPressDown = false;
		}
	}
	else {
		bPressDown = false;
	}
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
	
	//bool handled = activeGui->mouseReleased(touch);
	bool handled = false;
	
	if(handled)
	{
		//do nothing
	}
	else {
		switch (currentScene) {
			case WBC_Scene_IntroMovie:
				
				break;
				
			case WBC_Scene_Menu:
				//
				//				currentScene = WBC_Scene_Menu;
				//				
				//				_homeButton->enabled = false;
				//				_creditsButton->enabled = true;
				
				break;
			case WBC_Scene_Description:
				
				// go to detail view
				
				//				if (_Menu->getSelectedItem()->elementData->bHasMetaData) {
				//					
				//					
				//					_Menu->getSelectedItem()->enabled = false;
				//					
				//					_Menu->transitionTo(WBC_Scene_Detail);
				//					currentScene = WBC_Scene_Detail;
				//					
				//					_InteractiveScene->mTileRender->setDataDescription(_Menu->getSelectedItem()->elementData);
				//					_InteractiveScene->mCamera->frameRegion(ofxPoint2f(0,0), 
				//															ofxPoint2f(_Menu->getSelectedItem()->elementData->mSlideList[0]->mHeight_px,
				//																	   _Menu->getSelectedItem()->elementData->mSlideList[0]->mWidth_px)
				//															);
				//					
				//					_InteractiveScene->bIsLoaded = true;
				//					_homeButton->enabled = true;
				//					
				//					
				//				}
				
				break;				
				
			case WBC_Scene_Detail:
				
				bPressDown = true;
				zoomResetCounter = 0;
				
				if (_InteractiveScene->mTileRender->bHasAllocatedTiles) {
					
					_InteractiveScene->mCamera->setZooming(true);
					_InteractiveScene->mCamera->zoomProportional(0.5f);
				}
				
				break;
				
				
				
			default:
				break;
		}
	}
}

#pragma mark -
#pragma mark Residual iphone methods

//--------------------------------------------------------------
void testApp::lostFocus(){
	
}

//--------------------------------------------------------------
void testApp::gotFocus(){
	
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
	
	bPressDown = true;
	
	if (_InteractiveScene) {
		for (int i =0; i < _InteractiveScene->mTileRender->mTileSet.size(); i++) {
			
			printf("[TESTAPP] Memory warning - clearing hibernated tiles...\n");
			
			_InteractiveScene->mTileRender->cleanHibernatedTiles();
			
		}
	}
	
	
	
}

//--------------------------------------------------------------
void testApp::exit()
{
	
	//delete _Menu;
	
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
	//	printf("[TESTAPP] New orientation is %d\n", newOrientation);
	
	switch (newOrientation) {
		case 1:
			
			//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_PORTRAIT);
			
			//portrait
			break;
		case 2:
			//portrait flipped
			//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_UPSIDEDOWN);
			break;
		case 3:
			//landscape right (home button on right)
			iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
			break;
		case 4:
			//landscape right (home button on left)
			iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
			break;
		case 5:
			//flat on table, facing up
		case 6:
			//flat on table, facing down			
		default:
			break;
	}
}