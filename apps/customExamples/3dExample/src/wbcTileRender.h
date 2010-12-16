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


#ifndef WBC_TILERENDER
#define WBC_TILERENDER

#include "ofxWBCGenericTile.h"
#include "wbcDataDescription.h"

class wbcTileRender : ofxWBCEventListener
{

public:
	//constructor
	wbcTileRender();		
	
	// ofx core
	void					setup();
	void					updateScene();
	void					drawScene();
	
	void					drawBoundingBox();
	void					exit();
	
	void					drawTraces();
	
	// downloader	
	void					newResponse(ofxWBCResponse &response);
		
	// data description (information describing tiles)
	void					setDataDescription(wbcDataDescription* _tileDescription);	
	wbcDataDescription*		mTileDescription;

	// download state
	void					setDownloadState(bool _shouldtilesdownload);
	
	// frustum culling
	void					cullViewFrustum(ofxCamera* _camera);
	
	// clean up (remove hibernated tiles)
	void					cleanHibernatedTiles();

	
	// data content (actual tiles)
	vector<ofxWBCGenericTile*>	mTileSet;
	
	// spatial values	
	ofxVec3f				mPosition;
	ofxVec3f				mOffsetPosition;
	
	ofxVec3f				mBoundingBox;
	
	bool					bHasTileDescription;
	bool					bHasAllocatedTiles;
	bool					bNeedsToReload;

	bool					bShouldUpdateTiles;

	
	// downloading needs
	NSError		*	error;
	NSData		*	downloadedBuffer; //= [[NSData dataWithBytes:response.responseBody.data() length:response.responseBody.length()] retain];
	NSArray		*	paths;  //[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) retain];
	NSString	*	temporaryDirectory; // = [[paths objectAtIndex:0] retain];
	NSString	*	path; //	= [[temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:tilePtr->mHibernateFilename.c_str()]] retain];
//	

};

#endif