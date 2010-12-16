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

#include "ofxGuiGlobals.h"
#include "wbcDataDescription.h"

class wbcDynamicElement : public ofxMSAInteractiveObject {

public:

	wbcDynamicElement();
		
	webImageLoader baseImage;
	
	string	title;				// name that gets displayed
	int		parameterID;
	
	string	websiteURL;
	string	imageURL;
	
	wbcDataDescription*		elementData;
	ofTrueTypeFont*			sharedFont;
	ofxGuiGlobals*			mGlobals;	// houses callbacks to tell app what to do
	
	void setup();
	void draw();
	void update();
	void exit();
	
	bool bIsSelected;			// if selected, highlight and show title
	bool bIsZoomed;				// if zoomed, load details and display
	
	bool bShowText;				// toggles text display
	void showText();			// ''
	void hideText();			// ''

	bool bDrawFrame;			// outline
	
	bool bNeedsAnimateXY;		// translate
	bool bNeedsAnimateScale;	// scale
	bool bNeedsAnimateColor;	// opacity
	
	bool bIsToggle;			// is toggle button only
	
	ofColor targetColor;		
	ofPoint targetPosition;
	ofPoint targetSize;
	
	float	scaleRate;
	int		scaleMode;
	float	xyRate;
	int		xyMode;
	float	colorRate;
	int		colorMode;
	
	void animateXY(ofxPoint2f _target, float _rate, int _mode);
	void animateXYandScale(ofxPoint2f _target, ofxPoint2f _size, float _rate, int _mode);
	void animateCentroidandScale(ofxPoint2f _target, ofxPoint2f _size, float _rate, int _mode);
	void animateScale(ofxPoint2f _size, float _rate, int _mode);
	void animateFullView(float _rate, float _mode);

	void updateAnimation();

	void onRollOver(int x, int y);
	void onRollOut();
	void onMouseMove(int x, int);
	
	void onDragOver(int x, int y, int button);
	void onDragOutside(int x, int y, int button);
	
	void onPress(int x, int y, int button);
	void onPressOutside(int x, int y, int button);
	void onRelease(int x, int y, int button);
	void onReleaseOutside(int x, int y, int button);
	
	void onDoubleTap(int x, int y, int button);

};