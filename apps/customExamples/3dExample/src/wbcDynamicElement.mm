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


#include "wbcDynamicElement.h"

#pragma mark -
#pragma mark standard of stuff

wbcDynamicElement::wbcDynamicElement()
{
	bIsSelected			= false;
	bShowText			= true;
	bDrawFrame			= true;
	
	bIsZoomed			= false;
	
	bNeedsAnimateXY		= false;
	bNeedsAnimateColor	= false;
	bNeedsAnimateScale	= false;
	bIsToggle			= false;
	
	setPos(0.0f, ofGetHeight());
	
	setSize(256.0f, 256.0f);	
}

void wbcDynamicElement::setup()
{
	
	
}

void wbcDynamicElement::update()
{
	// do animations
	updateAnimation();
	
	
}

void wbcDynamicElement::draw()
{
	ofxPoint2f pos = getPosition();
	ofxPoint2f size = getSize();
	ofxPoint2f titlePos = pos + ofxPoint2f(4, 16);
	
	//int shadowOffset = 2;
	int frameOffset = 1;
	
	ofSetColor(0x999999);
	
	if (bIsSelected) {
		
		if (bDrawFrame && !bIsZoomed)
		{
			ofFill();
			ofRect(pos[0] - frameOffset, pos[1] - frameOffset, size[0] + 2*frameOffset, size[1] + 2*frameOffset);
			
		}
		
		float aspectRatio = (float)baseImage.width / (float)baseImage.height;
		
		ofxPoint2f drawpos = pos;
		ofxPoint2f drawsize = size;
		
		if (aspectRatio == 1) {
			
			
		} else if (aspectRatio < 1)
		{
			// height is long axis
			drawsize[0] = size[1] * aspectRatio;
			drawsize[1] = size[1];
			
			drawpos[0] += (size[0] - drawsize[0])/2;
			
			ofSetColor(0x000000);
			ofRect(pos[0], pos[1], size[0], size[1]);
			
		} else if (aspectRatio > 1) {
			// width is long axis			
			drawsize[0] = size[0];
			drawsize[1] = size[0] / aspectRatio;
			
			drawpos[1] += (size[1] - drawsize[1])/2;
			
			ofSetColor(0x000000);
			ofRect(pos[0], pos[1], size[0], size[1]);
			
			
			
		}
		
		
		if(bIsToggle)
		{
			ofSetColor(0xFFFFFF);
		}
		else {
			ofSetColor(0xFFFFFF);			
			
		}
		
		baseImage.draw(drawpos[0], drawpos[1], drawsize[0], drawsize[1]);
		
//		if(bShowText && !bIsZoomed)
//		{
//			ofSetColor(155,155,155,155);
//			sharedFont->drawString(title, titlePos[0] + shadowOffset, titlePos[1] + shadowOffset);
//			ofSetColor(255,255,255,255);
//			sharedFont->drawString(title, titlePos[0], titlePos[1]);
//		}
		
	}
	else {
		if (bDrawFrame && !bIsZoomed)
		{
			ofFill();
			ofSetColor(0x999999);
			ofRect(pos[0] - frameOffset, pos[1] - frameOffset, size[0] + 2*frameOffset, size[1] + 2*frameOffset);
		}
		
		ofSetColor(0xFFFFFF);
		
		ofxPoint2f drawpos = pos;
		ofxPoint2f drawsize = size;
		float aspectRatio = (float)baseImage.width / (float)baseImage.height;
		
		
		if (aspectRatio == 1) {
		} else if (aspectRatio < 1)
		{
			// height is long axis
			drawsize[0] = size[1] * aspectRatio;
			drawsize[1] = size[1];
			
			drawpos[0] += (size[0] - drawsize[0])/2;
			
			ofSetColor(0x000000);
			ofRect(pos[0], pos[1], size[0], size[1]);
			
		} else if (aspectRatio > 1) {
			
			// width is long axis			
			drawsize[0] = size[0];
			drawsize[1] = size[0] / aspectRatio;
			
			drawpos[1] += (size[1] - drawsize[1])/2;
			
			ofSetColor(0x000000);
			ofRect(pos[0], pos[1], size[0], size[1]);
			
		}
		
		if(bIsToggle)
		{
			ofSetColor(0xFFFFFF);			
		}
		else {
			ofSetColor(0xFFFFFF);			
		}

		baseImage.draw(drawpos[0], drawpos[1], drawsize[0], drawsize[1]);
		
	}
	
	ofSetColor(0xFFFFFF);
}

void wbcDynamicElement::exit()
{	
}

#pragma mark -
#pragma mark Animations

void wbcDynamicElement::animateXY(ofxPoint2f _target, float _rate, int _mode)
{
	targetPosition  = _target;
	xyRate			= _rate;
	xyMode			= _mode;
	//	printf("needs animate xy\n");
	bNeedsAnimateXY = true;
}

void wbcDynamicElement::animateXYandScale(ofxPoint2f _target, ofxPoint2f _size, float _rate, int _mode)
{
	targetPosition  = _target;
	targetSize		= _size;
	scaleMode		= _mode;
	xyMode			= _mode;
	scaleRate		= _rate;
	xyRate			= _rate;
	
	bNeedsAnimateXY = true;
	bNeedsAnimateScale = true;
}

void wbcDynamicElement::animateScale(ofxPoint2f _size, float _rate, int _mode)
{
	targetSize		= _size;
	scaleMode		= _mode;
	scaleRate		= _rate;
	
	bNeedsAnimateScale = true;
}

void wbcDynamicElement::animateFullView(float _rate, float _mode)
{
	
	// figure out which dimension is driving
	
	float imageAspectRatio = (float)baseImage.width / (float)baseImage.height;
	float displayAspectRatio = (float)ofGetWidth() / (float)ofGetHeight(); // 1.33333
	
	targetPosition = ofxPoint2f(0,0);
	targetSize	   = ofxPoint2f((float)ofGetWidth(), (float)ofGetHeight());
	
	ofxPoint2f _target = targetPosition;
	ofxPoint2f _size   = targetSize;
	
	if (imageAspectRatio == displayAspectRatio) {
		//		
		//		_size[0] = (float)ofGetWidth();
		//		_size[1] = (float)ofGetHeight();
		
	} else if (imageAspectRatio < displayAspectRatio)
	{
		// image is more square
		// height is longer axis
		
		_size[0] = _size[1] / imageAspectRatio;
		_target[0] -= (_size[0] - ofGetWidth())/2;
		
	} else if (imageAspectRatio > displayAspectRatio) {
		// image is more squat (bars above and below)
		// width is long axis
		
		_size[1] = _size[0] / imageAspectRatio;
		_target[1] -= (_size[1] - ofGetHeight())/2;
	}	
	
	targetPosition  = _target;
	targetSize		= _size;
	
	scaleMode		= _mode;
	xyMode			= _mode;
	scaleRate		= _rate;
	xyRate			= _rate;
	
	bNeedsAnimateXY = true;
	bNeedsAnimateScale = true;
	
	
}


void wbcDynamicElement::updateAnimation()
{
	ofxPoint2f currentPos = getPosition();
	ofxPoint2f currentSize = getSize();
	
	
	
	if (bNeedsAnimateXY) {
		
		//	printf("needs to animate xy:\n");
		
		ofxPoint2f startCentroid = currentPos + (currentSize / 2);
		ofxPoint2f targetCentroid = targetPosition + (targetSize / 2);
		ofxPoint2f xy_diff = targetCentroid - startCentroid;
		
		if (xy_diff.length() > 0.1) {
			
			currentPos[0] += xy_diff[0] * xyRate;
			currentPos[1] += xy_diff[1] * xyRate;
			
			setPos(currentPos[0], currentPos[1]);
			
		}
		else {
			//printf("done animating xy\n");
			
			currentPos = targetPosition;
			setPos(currentPos[0], currentPos[1]);
			
			bNeedsAnimateXY = false;
		}
	}
	
	if (bNeedsAnimateScale) {
		
		ofxPoint2f scale_diff = targetSize - currentSize;
		
		if (scale_diff.length() > 0.1) {
			currentSize[0] += scale_diff[0] * scaleRate;
			currentSize[1] += scale_diff[1] * scaleRate;
			
			setSize(currentSize[0], currentSize[1]);
			
		}
		else {
			//printf("done animating scale\n");
			currentSize = targetSize;
			
			
			setSize(currentSize[0], currentSize[1]);
			
			bNeedsAnimateScale = false;
		}
	}
	
	
	
	if (bNeedsAnimateColor) {
		
	}
}

void wbcDynamicElement::hideText()
{
	bShowText = false;
}

void wbcDynamicElement::showText()
{
	bShowText = true;
}




#pragma mark -
#pragma mark Handle touches

void wbcDynamicElement::onRollOut()
{
	//	bIsSelected = false;
}

void wbcDynamicElement::onRollOver(int x, int y)
{
	//	bIsSelected = true;
}
//void onRollOver(int x, int y);
//void onRollOut();


void wbcDynamicElement::onMouseMove(int x, int)
{
	//	if (bIsZoomed) {
	//		
	//	}
	//	else {
	//		bIsSelected = true;		
	//	}
}


void wbcDynamicElement::onDragOver(int x, int y, int button)
{
	//printf("drag over\n");
	//bIsSelected = true;
}

void wbcDynamicElement::onDragOutside(int x, int y, int button)
{
	//	if (bIsZoomed) {
	//		
	//	}
	//	else {
	//		bIsSelected = false;		
	//	}
}

void wbcDynamicElement::onPress(int x, int y, int button)
{
	//printf("pressed\n");
	
	
	if (bIsToggle) {
		
		if (bIsSelected) {
			mGlobals->mListener->handleGui(parameterID, 3, nil, 0);	
			mGlobals->mTap.play();
			
			bIsSelected = false;
			
			
		}
		else {
			
			mGlobals->mListener->handleGui(parameterID, 0, nil, 0);			
			mGlobals->mTap.play();
			
			bIsSelected = true;
		}
		
		
	}
	
	//	if (!bNeedsAnimateColor && !bNeedsAnimateXY && !bNeedsAnimateScale) {
	//
	//		if (bIsZoomed) {
	//			mGlobals->mTap.play();
	//			mGlobals->mListener->handleGui(parameterID, 2, nil, 0);	
	//			bIsSelected = true;	
	//			
	//		}
	//		else if (bIsSelected) 
	//		{
	//			if (bIsToggle) {
	//			
	//				mGlobals->mListener->handleGui(parameterID, 3, nil, 0);	
	//				mGlobals->mTap.play();
	//				bIsSelected = false;
	//				
	//			}
	//			else {
	//				
	//				//default behavior
	//				mGlobals->mTap.play();			
	//				mGlobals->mListener->handleGui(parameterID, 0, nil, 0);	
	//				bIsSelected = true;	
	//				bIsZoomed = true;				
	//			}
	//
	//
	//		} 
	//		else
	//		{
	//			if (bIsToggle) {
	//				mGlobals->mListener->handleGui(parameterID, 3, nil, 0);	
	//				mGlobals->mTap.play();
	//				bIsSelected = true;
	//				
	//			}
	//			else {
	//				mGlobals->mTap.play();
	//				bIsSelected = true;		
	//			}
	//
	//			
	//
	//		}
	//		
	//	}
}

void wbcDynamicElement::onPressOutside(int x, int y, int button)
{
	if( !bIsToggle)
	{
		if (bIsSelected) {
			
			bIsSelected = false;
			mGlobals->mListener->handleGui(parameterID, 1, nil, 0);	
		}
	}
}

void wbcDynamicElement::onRelease(int x, int y, int button)
{ 
}

void wbcDynamicElement::onReleaseOutside(int x, int y, int button)
{	
}

void wbcDynamicElement::onDoubleTap(int x, int y, int button)
{
	if(!bIsToggle)
	{
		
		if (bIsSelected) {
			printf("Displaying object: %s\n", title.c_str());
			mGlobals->mTap.play();
			mGlobals->mListener->handleGui(parameterID, 2, nil, 0);	
			
		}
		else {
			printf("Selected object: %s\n", title.c_str());
			mGlobals->mTap.play();
			
			bIsSelected = true;
			mGlobals->mListener->handleGui(parameterID, 0, nil, 0);			
		}	
	}
}