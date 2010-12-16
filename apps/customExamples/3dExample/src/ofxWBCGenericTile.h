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


/* logic -> this is to be done by the tilerender class
 
 initialize: 
	 allocate the first 3 resolutions -> 1, 4, 8 : have to generate 13 urls, 13 tile groups
		allocateAll(2) 
	 
	 from this point, allocate is called whenever the tile DRAW depth is within 1 (?) 
		allocateByResRowCol
 
 
 cull cache:
	
	need to write function: pass in ofxvec3 position of camera (or arbitrary to test) and shape -> sphere?
 
	recursively traverse through all allocated tiles
		if centroid within frustum, 
			set InCacheFrustrum (if not already)

		if centroid not within frustum, 
			set inCacheFrustum = false

 
 cull view:

	need to write function passing ofxvec3 camera position and ... frustum matrix?
 
	recursively traverse through all allocated tiles

		if tile centroid is within frustum
			set inViewFrustum = true
				ask children		

		tile centroid not in view frustum 
			ask children if they're in view
 
			if any children in view frustum, set this.inViewFrustm = true as well
 
			if no children are in view frustum, set this.inviewFrustum = false
 
	
 draw view:
 
	need to write function passing ofxvec3 camera position?
 
	if this.inviewfrustum
		
		check distance from centroid to camera position
 
			if distance is small ie the current tile would be blurry
 
				then draw children
			
			else distance is not small (ie the current tile is close enough to have multiple pixels per texel)
	
				"this tile should draw"
				does this tile have data?
 
					yes: previous download request passed and image loaded
							draw me.
 
					no: no download request has been sent yet
							send download request (with distance priority)
							set downloadrequest sent = true
							
							allocate children (generates their TilegroupID and filename)
							
							draw place holder
			
			
 
 (nothing allocated)
 
 Call draw to top level tile ->
 
 */


#ifndef OFX_WBC_GENERICTILE
#define OFX_WBC_GENERICTILE

#include "ofxWBCglobals.h"
#include "fstream.h"

class ofxWBCGenericTile
{

public:
	
	
#pragma mark Constructors
	
	ofxWBCGenericTile();
	ofxWBCGenericTile(ofxVec3f _size, int _numResolutions,
					  wbcTileFormat _format, int _tileSize,
					  int _nextZoom, int _I, int _J,
					  string* _url, string* _dataname, string _slideID);

#pragma mark Tile creation and loading

	void		allocateTop();		// recursively allocate all tiles, generating tilegroup, unique URL, etc 
	void		allocateTile(); // allocate children only
	void		calculateTileGroup();	// calculates the zoomify tilegroup (folder) and stores to tile
	void		generateFileName();  // generates filename from tilegroup, res, row, col
	void		generateKids();

#pragma mark Culling and drawing utilities

	bool		cullFrustum(ofxCamera* _camera, ofxVec3f _position);
	
//	void		updateTexture();

	float		calcPTSP();
	void		bindTexture();
	float		calculateMaximumDistance(ofxVec3f _camPosition);
	float		calculateTexelSize();
	
//	bool		shouldTileDraw();
//	bool		canTileDraw(bool _shouldUpdateTiles);
	
	bool		drawThisTile(bool _shouldUpdateTiles);
	bool		draw(bool _shouldUpdateTiles);
	
	void		drawQuad(int mode, ofxVec3f _center, ofxVec3f _size);
	void		drawQuad(GLenum mode, GLfloat cx, GLfloat cy, GLfloat z, GLfloat w, GLfloat h);

#pragma mark Populate with image 

	ofxWBCGenericTile* getByResRowCol(int _res, int _row, int _col);
	
	void			requestTile();
	
	void			loadFileFromDisk();
	unsigned char*	readImagefile(string filename, int *width, int *height);
	CGContextRef	createARGBBitmapContextFromImage(CGImageRef inImage);	
	
	void			clearTile();

	void			cleanHibernatedTiles();
	void			clearTexture();

	void			hibernateTile();		// sends tile to hibernate mode (cached to disk, not allocated)
	void			unHibernateTile();

	
#pragma mark Member Variables
	
	ofxVec3f	mCentroid;			// position in space -> needed for distance/culling/
	ofxVec3f	mNormal;			// not used, yet	

	int			mSlideWidth;		 
	int			mSlideHeight;

	ofxVec3f		mScaledSize;	// scaled tile size, if full image is 400 pixels, mSize is next power of two above, so 512
	int				mTileSize;		// usually 256
	wbcTileFormat	mTileFormat;	// format of tile URL to generate

	
	int			mZoomLevel;			// LEVEL (or res), uses 0 as lowest zoom level
	int			mNumResolutions;	// possible levels
	
	int			mNumberOfRows;		// maximum number of rows at give res
	int			mNumberOfCols;		// maximum number of columns at given res
	
	int			mZposition;			// z depth, initially 0
	
	int			mI;					// row index (height)
	int			mJ;					// column index (width)
	
	int			mTileGroup;			// corresponding tilegroup (for zoomify, etc)
	string		mTileURL;			// high level URL -> not informed of data name

	string		mSlideID;
	
	
	string*		mURL;
	string*		mDataName;

	
	bool		mAllocated;			// tilegroup is calculated, url is calculated
	bool		mInViewFrustum;		// determines if tile should be drawn

	bool		bContainsImageData;
	bool		mRequestSent;		// prevents resending download request
	int			requestDelay;
	
	bool		mTextureBound;		// may contain pixels, but won't display until bound
	ofTexture*  mTexture;
	
	vector<ofxWBCGenericTile*>	children;	// contains children at mZoomLevel + 1
			
		
	bool		bInHibernation;		//	
	string		mHibernateFilename;
	
};



#endif