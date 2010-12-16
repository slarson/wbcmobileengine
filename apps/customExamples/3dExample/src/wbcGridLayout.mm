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


#include "wbcGridLayout.h"

#pragma mark ======== Constructors and definitions ========

wbcGridLayout::wbcGridLayout()
{
	mPadding				= 20; // 10 pixels
	
	mGridSpacingPixels		= 20; // 10 pixels between
	mGridSpacingPercentage	= 0.1;// 10% between
	
	mScale					= 1.0f;
	mSideLength				= 96;
	
	mPosition = ofxPoint2f(200,200);
	mSize = ofxPoint2f(400,400);
	
	bUseAbsoluteSpacing = true;
	
	
}

ofxPoint2f wbcGridLayout::getPositionForIndex(int _index)
{
	
	// we know bounding rectangle
	
	int widthminuspadding = mSize[0] - mPadding; // this only subtracts 1 equivalent padding distance, other is included in mgrid spacing
	int tilesperrow = widthminuspadding / (mSideLength*mScale + mGridSpacingPixels); // get integer # of tiles per row
	
	//
//	if (tilesperrow == 0) {
//		mScale = mSize[0] / mSideLength;
//	}
//	
	// find out which row this tile is in
	int actualRow		= _index / tilesperrow;  // integer row, 0 -> first row, etc
	int topposition		= mPadding + actualRow * (mSideLength * mScale + mGridSpacingPixels);
	
	int actualColumn	= _index % tilesperrow; // 0 = first column
	int leftposition	= mPadding + actualColumn * (mSideLength * mScale + mGridSpacingPixels);
	
	//printf("%d %d %d %d\n", actualRow, topposition, actualColumn, leftposition);
	
	ofxPoint2f topLeftPosition;
	topLeftPosition = ofxPoint2f(leftposition, topposition);
	
	topLeftPosition += mPosition;
	
//	printf("returning: %f %f\n", topLeftPosition[0], topLeftPosition[1]);
	
	return topLeftPosition;
}



ofxPoint2f wbcGridLayout::getSize()
{
	return ofxPoint2f(mSideLength * mScale, mSideLength*mScale);
}


void wbcGridLayout::setLayout(ofxPoint2f _position, ofxPoint2f _size)
{
	mPosition	= _position;
	mSize		= _size;
	
}


void wbcGridLayout::adjustScale(float _scale)
{

//	mScale = _scale;
	
	mScale -= 0.02 * (1 - _scale);
	
	if (mScale <= 0.2) {
		mScale = 0.2;
	}
	
	if (mScale >= 2) {
		mScale = 2;
	}
		
}
















