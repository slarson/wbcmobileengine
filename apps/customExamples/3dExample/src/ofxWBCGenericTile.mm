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

#include "ofxWBCGenericTile.h"

#define TILESCALE 1.00f
#define MAX_TEX_COUNT 200
#define MAX_TEX_BIND  3
#define REQUEST_RESET 600 // resets after 100 frames... so we can remove tail of download queue!

#pragma mark Constructors

//default constructor
ofxWBCGenericTile::ofxWBCGenericTile()
{
}

ofxWBCGenericTile::ofxWBCGenericTile(ofxVec3f _size, int _numResolutions,
									 wbcTileFormat _format, int _tileSize,
									 int _nextZoom, int _I, int _J,
									 string* _url, string* _dataname, string _slideid)
{	
	mURL	  = _url; // full slide path!
	mDataName = _dataname;
	
	mInViewFrustum	= false;
	bInHibernation	= false;
	mHibernateFilename = "";
	
	mZoomLevel		= _nextZoom;
	mNumResolutions = _numResolutions; 
	
	mI				= _I;				// x position (corresponds to image height)
	mJ				= _J;				// y position (corresponds to image width)
	mZposition		= 0.0;
	
	mTileSize		= _tileSize;		// should always be 256
	
	mAllocated		= false;
	
	mTileFormat		= _format;
	mTileURL		= "";
	mRequestSent	= false;
	requestDelay	= 0;
	
	mSlideID		= _slideid;
	
	mSlideWidth		= _size[0];		// should be the maximum listed from image properties.xml
	mSlideHeight	= _size[1];		// should be the maximum listed from image properties.xml
	
	int scaled_size = mTileSize * pow(2.0, (mNumResolutions - mZoomLevel - 1 ));
	mScaledSize	= ofxVec3f(scaled_size, scaled_size, 0);
	
	int x_c = (scaled_size * mI) + (scaled_size / 2);
	int y_c = (scaled_size * mJ) + (scaled_size / 2);
	
	mCentroid	= ofxVec3f(x_c, y_c, mZposition);
	
	mTextureBound = false;
	mTexture = new ofTexture();
	
}


#pragma mark -
#pragma mark Tile creation and loading

// allocate child tile only
void ofxWBCGenericTile::allocateTile()
{
	calculateTileGroup();
	generateFileName();
	
	string tempfilename = *mDataName;
	size_t found;
	found = tempfilename.find(".");
	if (found !=string::npos) {
		
		tempfilename.erase(found);
		
	}

	mHibernateFilename = tempfilename + "_" + mSlideID + "_" + ofToString(mZoomLevel) + "-" + ofToString(mI) + "-" + ofToString(mJ) + ".jpg";
	mAllocated = true;
	
	//printf("[Tile] Allocated tile %d-%d-%d\n", mZoomLevel, mI, mJ);
}

// tile children -> recurse through EVERYTHING, allocates all tiles at a given zoom level
void ofxWBCGenericTile::allocateTop()
{
	// allocate this tile
	allocateTile();
	generateKids();
}

void ofxWBCGenericTile::generateKids()
{
	// if this tile is allocated, we need to at least populate the children
	if (mAllocated) 
	{
		int p_zoom = mZoomLevel + 1;
		
		int nextZoomRows = ceil(mSlideWidth / (mTileSize * pow(2.0,  mNumResolutions - p_zoom -1)));
		int nextZoomCols = ceil(mSlideHeight/ (mTileSize * pow(2.0,  mNumResolutions - p_zoom -1)));
		
		for(int i = 0; i < 2; i++)
		{
			for (int j = 0; j < 2; j++) 
			{
				int childind_x = ((2*mI)+i); // child row index
				int childind_y = ((2*mJ)+j);
				
				if ((childind_y >= nextZoomCols) || (childind_x >= nextZoomRows))
				{
					
					//	printf("Child shouldn't exist (tile not present) %d %d %d\n", p_zoom, childind_x, childind_y);
				}
				else {
					
					//printf("made kid at zoom %d with row %d and col %d\n");
					ofxWBCGenericTile* child = new ofxWBCGenericTile(ofxVec3f(mSlideWidth, mSlideHeight, 0), mNumResolutions,
																	 mTileFormat, mTileSize, p_zoom, childind_x, childind_y,
																	 mURL, mDataName, mSlideID);
					children.push_back(child);
					
				}
			}
		}
		//	printf("Generated %d kids\n", (int)children.size());
	}
}


void ofxWBCGenericTile::calculateTileGroup()
{
	float tilecount = 0;
	
//	printf("tiles added: ");
	
	// add up previous levels
	for (int i=0; i < mZoomLevel; i++) {
		
		// total tile count for each level = 
		int thisZoomRows = ceil(mSlideHeight	/ (mTileSize * pow(2.0, mNumResolutions - i-1)));
		int thisZoomCols = ceil(mSlideWidth		/ (mTileSize * pow(2.0, mNumResolutions - i-1))); 
		
		int total = thisZoomRows * thisZoomCols; 
		
//		printf("z:%d t:%d ", i, total);
		
		tilecount += total;
	}
	
	
	float finalCols = ceil(mSlideWidth / (mTileSize * pow(2.0, mNumResolutions - mZoomLevel-1)));
	
	tilecount += mJ * finalCols + mI;
	
//	printf("[hmm] %d %d %d - %f\n", mZoomLevel, mI, mJ, tilecount);
	
	mTileGroup = floor(tilecount / 256.0);
	
}



void ofxWBCGenericTile::generateFileName()
{	
	switch (mTileFormat) {
		case WBC_ZOOMIFY:
		case WBC_BRAINMAPS:
			
			mTileURL =  "/TileGroup" + ofToString(mTileGroup)
			+ "/" + ofToString(mZoomLevel) + "-" + ofToString(mI) + "-" + ofToString(mJ) + ".jpg"; 
			break;
			
			
		case WBC_CCDB:
			mTileURL =  "/TileGroup" + ofToString(mTileGroup)
			+ "/" + ofToString(mZoomLevel) + "-" + ofToString(mI) + "-" + ofToString(mJ) + ".jpg"; 
			break;
			
		case WBC_ABA:
			mTileURL =  "/TileGroup" + ofToString(mTileGroup)
			+ "/" + ofToString(mZoomLevel) + "-" + ofToString(mI) + "-" + ofToString(mJ) + ".jpg"; 
			break;	
		
		case WBC_ZFISH:
			//http://zfatlas.psu.edu/i.php?s=85&z=8&i=0
			
			mTileURL = "s=85&z=" + ofToString(mNumResolutions - mZoomLevel - 1 ) + "&i=" + ofToString(mI*mNumberOfRows + mJ);
			printf("%s\n", mTileURL.c_str());
			
			break;

			
		default:
			break;
	}
}

#pragma mark -
#pragma mark Hibernation (tile caching)


void ofxWBCGenericTile::hibernateTile()
{
	
	if(mAllocated && !bInHibernation)
	{
		clearTexture();
		bInHibernation = true;
	}
}


void ofxWBCGenericTile::unHibernateTile()
{
	mRequestSent = false;
	bInHibernation = false;
	
}



#pragma mark -
#pragma mark Culling and drawing utilities

// Step 1: draw call ->
//		check if allocated
//			check if this tile is a high enough resolution
//				if yes, draw this tile
//				if no, see if a) I have kids, b) should they draw
//					if the all of the kids answer true, draw them
//					else wait until they've all been loaded, bound, etc

// therefore, update texture should be called from 'should tile draw', otherwise it will never reach the kids

bool ofxWBCGenericTile::draw(bool _shouldUpdateTiles)
{
	bool tiledrawn = false;
	
	// Check me
	
	
	if (mAllocated) {
		if (!bInHibernation) {
			
			// I have a texture... draw me unless you need to draw kids
			float calculatedTSP = calcPTSP(); 			// get projected texel size

			// I am sharp enough, draw me!
			if (calculatedTSP <= 0.95f ) 
			{
				bool shoulddrawme = false;

				if (calculatedTSP > 0.8f) {
					
					for (int i = 0; i < children.size(); i++) {
						if(!children[i]->draw(_shouldUpdateTiles))
						{
							// however, if it doesn't draw because it's hibernated, thats fine
							if (!children[i]->bInHibernation) {
								shoulddrawme = true;														
							}
						}
					}
					
				}

				if (shoulddrawme) {
						tiledrawn = drawThisTile(_shouldUpdateTiles);
				}


			}
			else {
				
				// Check kids
				
				bool shoulddrawme = false;
				
				for (int i = 0; i < children.size(); i++) {
					
					//STOP TRYING TO BE CLEVER.
					
					if(!children[i]->draw(_shouldUpdateTiles))
					{
						// however, if it doesn't draw because it's hibernated, thats fine
						if (!children[i]->bInHibernation) {
							shoulddrawme = true;														
						}
					}
				}
				
				// After running kids, check if I still need to do me
				
				if (shoulddrawme) {
					tiledrawn = drawThisTile(_shouldUpdateTiles);
				}
				else {
					// meaning, all kids drew successfully
					tiledrawn = true;
				}
				
			} // me or kids
			
		}// hibernation?
	}
	else {
		
		if (mZoomLevel < mNumResolutions) {
			if (mInViewFrustum) {
				allocateTile();
				generateKids();
			}			
		}
	}
	
	if (!tiledrawn && mZoomLevel==0) {
		drawThisTile(_shouldUpdateTiles);
	}
	
	return tiledrawn;
}		


//
//			// i am not sharp enough, see if able to draw kids
//			bool shouldDrawKids = true;
//			
//			// for each kid
//			for (int i = 0; i < children.size(); i++)
//			{
//				// if any of the kids can't draw, then don't show kids
//					if (!children[i]->canTileDraw(_shouldUpdateTiles))
//					{
//						//tile in frustum, tile loaded
//						shouldDrawKids = false;
//					}
//				}
//			}	
//			
//			if (shouldDrawKids) {
//				
//				tiledrawn = true;
//				
//				for (int i = 0; i < children.size(); i++)
//				{
//						
//						if(!children[i]->draw(_shouldUpdateTiles))
//						{
//							tiledrawn = false;
//						}							
//
//					
//				}
//				
//			}
//			else {
//				drawThisTile();
//				tiledrawn = true;

//		}
//	}
//	
//	return tiledrawn;
//}
//

//bool ofxWBCGenericTile::canTileDraw(bool _shouldUpdateTiles)
//{	
//	// we previously asked if we should draw
//	// anything that responds true to that, then gets asked if it can draw
//	//	printf("called update texture: %d %d %d\n", mZoomLevel, mI, mJ);	
//	if (mTextureBound) {
//		return true;
//	}
//	else if (_shouldUpdateTiles)
//	{
//		requestTile();
//	}
//	return false;
//}


bool ofxWBCGenericTile::drawThisTile(bool _shouldUpdateTiles)
{
	if (mTextureBound) {
		
		float scale = TILESCALE;
		
//		switch (mTileGroup) {
//			case 0:
//				ofSetColor(0, 200, 0, 255);
//				break;
//			case 1:
//				ofSetColor(200, 200, 0, 255);
//				break;
//			case 2:
//				ofSetColor(200, 0, 200, 255);
//				break;			
//			case 3:
//				ofSetColor(0, 0, 200, 255);
//				break;		
//			case 4:
//				ofSetColor(200, 200, 200, 255);
//				break;
//			default:
//				break;
//		}
		
//		drawQuad(GL_TRIANGLE_STRIP, mCentroid, mScaledSize);
//		ofSetColor(255,255,255);
		
		mTexture->draw(mCentroid[0] - mScaledSize[0]/2, mCentroid[1] - mScaledSize[1]/2, round(scale*mScaledSize[0]), round(scale*mScaledSize[1]));
		
		return true;
	}
	else {
		
		if ((_shouldUpdateTiles) && (ofGetAppPtr()->baseAppTextureFlag <= MAX_TEX_BIND)) {
			requestTile();			
		}
		return false;
	}
}


//void ofxWBCGenericTile::updateTexture()
//{
//	// case 1: wImage doesn't have data -> need to download/load tile image
//	// case 2: wImage contains data, texture is not bound -> bind texture
//	// case 3: wImage contains data, texture is bound -> save jpg, clear image
//	
//	
////	if (bContainsImageData) {
////		
////		//	printf("Image contains data\n");
////		
////		if (!mTextureBound) {
////			// case 2: wImage contains data, texture is not bound -> bind texture
////			//	printf("case 2: wImage contains data, texture is not bound -> bind texture\n");
////			
////			int pixSize = 256*256*3;
////			int yi,xi,ci;
////			unsigned char * pixArr = new unsigned char[pixSize];
////			
////			for (yi = 0; yi < 256; yi++)
////			{
////				for (xi = 0; xi < 256; xi++) {
////					for (ci = 0; ci < 3; ci++)
////					{
////						pixArr[ci+3*(xi+256*yi)] = (xi >= wImage->width || yi >= wImage->height)?0:wImage->getPixels()[ci+3*(xi+wImage->width*yi)];
////					}
////				}
////			}
////			
////			//			wImage->getTextureReference().allocate(256, 256, GL_RGB);				
////			//			wImage->getTextureReference().loadData(pixArr, 256, 256, GL_RGB);
////			
////			mTexture->allocate(256, 256, GL_RGB);
////			mTexture->loadData(pixArr, 256, 256, GL_RGB);
////			
////			// only save if it doesn't exist
////			if(!doesFileExist(mHibernateFilename))
////			{
////				
////				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
////				NSString *temporaryDirectory = [paths objectAtIndex:0];
////				NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:mHibernateFilename.c_str()]];
////				
////				
////				//				NSLog(@"File doesn't exist, saving to file: %@\n", path);
////				
////				//				printf("%s\n", [path UTF8String]);
////				
////				wImage->saveImage([path UTF8String]);
////				
////				
////			}
////			
////			free(pixArr);
////			mTextureBound = true;
////		}
////		else {
////			
////			webImageLoader* tempimg = wImage;
////			wImage = new webImageLoader();
////			
////			wImage->setUseTexture(false);
////			
////			tempimg->clear();
////			free(tempimg);
////			
////			bContainsImageData = false;
////			//	case 3: wImage contains data, texture is bound -> save jpg, clear image
////		}
////	}
////	else {
////		
////		// if the tile is hibernating, don't worry about it
////		if (!bInHibernation)
////		{
////			if(!mTextureBound)
////			{
////				//printf("case 1: wImage doesn't have data -> need to download/load tile image\n");
////				// case 1: wImage doesn't have data -> need to download/load tile image
////				
////				requestTile();
////			}
////			else {
////				// case 4: wImage doesn't have data, texture already bound -> do nothing			
////			}
////		}
////		else {
////			
////			//printf("out of hibernation - now what?");
////			
////		}
////		
////	}
//}

#pragma mark -
#pragma mark Texture

void ofxWBCGenericTile::clearTexture() 
{
	if (mTextureBound) {
		
		mTexture->clear();
		ofTexture* toDelete = mTexture;
		
		mTexture = new ofTexture();
		free(toDelete);

		ofGetAppPtr()->decrementTextureCount();

		
		//printf("clear tex: (%d %d %d)\n", mZoomLevel, mI, mJ);
		
		mTextureBound = false;
		mRequestSent = false;
	}
}



void ofxWBCGenericTile::cleanHibernatedTiles()
{
	// are my kids
	for (int i = 0; i < children.size(); i++)
	{
		children[i]->cleanHibernatedTiles();
	}
	
	if (bInHibernation) {
		
		children.clear();
		mAllocated = false; 

		
	}
	


}

void ofxWBCGenericTile::clearTile()
{
	// are my kids
	for (int i = 0; i < children.size(); i++)
	{
		children[i]->clearTile();
		
	}	

	if (mTextureBound) {
		mTexture->clear();
		free(mTexture);

		ofGetAppPtr()->decrementTextureCount();
		
		mTextureBound = false;
		mRequestSent = false;
		
	}
}
	


void ofxWBCGenericTile::loadFileFromDisk()
{
	
	if (!mTextureBound) {
		// case 2: wImage contains data, texture is not bound -> bind texture
		//	printf("case 2: wImage contains data, texture is not bound -> bind texture\n");
		

		if(ofGetAppPtr()->incrementTextureCount() >= MAX_TEX_COUNT)
		{
			ofGetAppPtr()->decrementTextureCount();
			printf("bounced off texture limit!\n");

		} 
		else
		{
			int height, width;
			int pixSize = 256*256*4;
			int yi,xi,ci;
			
			// unpadded pixels
			unsigned char* pixels = readImagefile(mHibernateFilename, &width, &height);
			
			if (!pixels) {
				printf("problem reading file: %s\n", mHibernateFilename.c_str());
				return;
			}
			
			// where padded pixels go
			unsigned char * pixArr = new unsigned char[pixSize];
			
			for (yi = 0; yi < 256; yi++)
			{
				for (xi = 0; xi < 256; xi++) {
					for (ci = 0; ci < 4; ci++)
					{
						pixArr[ci+4*(xi+256*yi)] = (xi >= width || yi >= height)?0:pixels[ci+4*(xi+width*yi)];
					}
				}
			}
			
			ofGetAppPtr()->baseAppTextureFlag++;			
			
			mTexture->allocate(256, 256, GL_RGBA);
			mTexture->loadData(pixArr, 256, 256, GL_RGBA);
			
			
			mTextureBound = true;
			
			free(pixArr);
			free(pixels);
			
		}

	}
}

void ofxWBCGenericTile::requestTile()
{
	if (doesFileExist(mHibernateFilename)) {
		
		loadFileFromDisk();			
	}
	else {
		
		string request = *mURL + mTileURL;
		
		if (mTextureBound || bInHibernation) {
			
			// do nothing
		}
		else {
			if (mRequestSent && !bInHibernation) {
				
				requestDelay++;
				
				if (requestDelay > REQUEST_RESET) {

					mRequestSent = false;
					requestDelay = 0;
				}
				// do nothing
			}
			else {
			//	printf("sending %s\n", request.c_str());
				
//				if (ofxWBCUtil.getQueueLength() < 200) {
					// yep, only add to queue if it's less than 100

					ofxWBCUtil.addUrl(request, &mInViewFrustum);
					mRequestSent = true;					
//				}
			}
		}
		
	}		
}

//void ManipulateImagePixelData(CGImageRef inImage)
unsigned char* ofxWBCGenericTile::readImagefile(string filename, int *width, int *height)
{
	unsigned char* data = NULL;
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *temporaryDirectory = [paths objectAtIndex:0];
	NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:filename.c_str()]];
	
	//	NSLog(@"Loading file: %@\n", path);
	
	//	BOOL isDirectory = NO;
	
	if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) {
		//	NSString* path = [NSString stringWithUTF8String:ofToDataPath(filename,true).c_str()];
		//[documentsDirectory stringByAppendingPathComponent:[NSString stringWithCString:filename.c_str()]];
		
		//		NSLog(@"Loading file: %@\n", path);
		
		UIImage* image = [UIImage imageWithContentsOfFile:path];
		
		//- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
		//	UIColor* color = nil;
		
		CGImageRef inImage = image.CGImage;
		// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
		//	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
		
		CGContextRef cgctx = createARGBBitmapContextFromImage(inImage);
		
		if (cgctx == NULL) { return nil; /* error */ }
		
		size_t w = CGImageGetWidth(inImage);
		size_t h = CGImageGetHeight(inImage);
		CGRect rect = {{0,0},{w,h}}; 
		
		//	CGPoint point = CGPointMake(100.0f, 100.0f);
		//	
		// Draw the image to the bitmap context. Once we draw, the memory
		// allocated for the context for rendering will then contain the
		// raw image data in the specified color space.
		CGContextDrawImage(cgctx, rect, inImage); 
		
		// Now we can get a pointer to the image data associated with the bitmap
		// context.
		data = (unsigned char*) CGBitmapContextGetData (cgctx);
		
		//	if (data != NULL) {
		//		//offset locates the pixel in the data from x,y.
		//		//4 for 4 bytes of data per pixel, w is width of one row of data.
		//		int offset = 4*((w*round(point.y))+round(point.x));
		//		int alpha =  data[offset];
		//		int red = data[offset+1];
		//		int green = data[offset+2];
		//		int blue = data[offset+3];
		//		NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
		//		//color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
		//	}
		
		// When finished, release the context
		CGContextRelease(cgctx);
		// Free image data memory for the context
		//if (data) { free(data); }
		
		*width = w;
		*height = h;
		
	}
	else {
		
		printf("%s not found in tmp directory\n", filename.c_str());
	}
	
	
	[pool release];
	
	return data;
}



CGContextRef ofxWBCGenericTile::createARGBBitmapContextFromImage(CGImageRef inImage)
{
	
	//- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	//	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}












float ofxWBCGenericTile::calcPTSP()
{
	GLfloat cx,cy,tw,th;
	//calc_tile_region_mm(res,row,col, &cx,&cy,&tw,&th);
	
	cx = mCentroid[0];
	cy = mCentroid[1];
	tw = mScaledSize[0];
	th = mScaledSize[1];
	
	GLfloat proj[16],model[16];
	GLint view[4];
	glGetFloatv(GL_PROJECTION_MATRIX, proj);
	glGetFloatv(GL_MODELVIEW_MATRIX, model);
	
	glGetIntegerv(GL_VIEWPORT,view);
	
	GLfloat winx1,winy1,winz1;
	GLfloat winx2,winy2,winz2;
	GLfloat winx3,winy3,winz3;
	GLfloat max_tsp = 0.0; // max (projected) texel size in pixels
	GLfloat tsp;
	
	// How large is the projection of a texel in the center of the tile?
	{
		
		wbcProject(cx        ,cy        ,0.0, model,proj,view, &winx1,&winy1,&winz1);
		wbcProject (cx+tw/256.,cy        ,0.0, model,proj,view, &winx2,&winy2,&winz2);
		wbcProject (cx        ,cy+th/256.,0.0, model,proj,view, &winx3,&winy3,&winz3);
		tsp = 0.5*(sqrt(pow((winx2-winx1),2)+pow((winy2-winy1),2))+
				   sqrt(pow((winx3-winx1),2)+pow((winy3-winy1),2)));
		max_tsp=tsp;
	}
	
	// How large is are the projections of texels on the corners of the tile?
	{
		int i,j;
		for(i=0;i<2;i++) {
			GLfloat ox=cx+(i==0?1.0:-1.0)*tw/2;
			for(j=0;j<2;j++) {
				GLfloat oy=cy+(j==0?1.0:-1.0)*th/2;
				wbcProject (ox        ,oy        ,0.0, model,proj,view, &winx1,&winy1,&winz1);
				wbcProject (ox+tw/256.,oy        ,0.0, model,proj,view, &winx2,&winy2,&winz2);
				wbcProject (ox        ,oy+th/256.,0.0, model,proj,view, &winx3,&winy3,&winz3);
				tsp = 0.5*(sqrt(pow((winx2-winx1),2)+pow((winy2-winy1),2))+ sqrt(pow((winx3-winx1),2)+pow((winy3-winy1),2)));;
				if(winz1>0) { max_tsp=max(max_tsp,tsp); }
			}
		}
	}
	
	return max_tsp;
}


//void ofxWBCGenericTile::bindTexture()
//{
//	printf("binding %d %d %d\n", mZoomLevel, mI, mJ);
//	
//	// image was loaded
//	if (!mTextureBound) {
//		
//		//image loaded, but texture not created
//		int pixSize = 256*256*3;
//		int yi,xi,ci;
//		unsigned char * pixArr = new unsigned char[pixSize];
//		
//		for (yi = 0; yi < 256; yi++)
//		{
//			for (xi = 0; xi < 256; xi++) {
//				for (ci = 0; ci < 3; ci++)
//				{
//					pixArr[ci+3*(xi+256*yi)] = (xi >= wImage->width || yi >= wImage->height)?0:wImage->getPixels()[ci+3*(xi+wImage->width*yi)];
//				}
//			}
//		}
//		
//		wImage->getTextureReference().allocate(256, 256, GL_RGB);				
//		wImage->getTextureReference().loadData(pixArr, 256, 256, GL_RGB);
//		
//		free(pixArr);
//		
//		mTextureBound = true;
//	}
//}


float ofxWBCGenericTile::calculateMaximumDistance(ofxVec3f _camPosition)
{
	ofxVec3f tempvec;
	float dist_array[4];
	float maxdist = 0.0f;
	
	tempvec = mCentroid + ofxVec3f(-mScaledSize[0]/2, -mScaledSize[1]/2,0.0) - _camPosition;
	dist_array[0] = tempvec.length();
	
	tempvec = mCentroid + ofxVec3f(-mScaledSize[0]/2, mScaledSize[1]/2,0.0f) - _camPosition;
	dist_array[1] = tempvec.length();
	
	tempvec = mCentroid + ofxVec3f(mScaledSize[0]/2, -mScaledSize[1]/2,0.0f) - _camPosition;
	dist_array[2] = tempvec.length();
	
	tempvec = mCentroid + ofxVec3f(mScaledSize[0]/2, mScaledSize[1]/2,0.0f) - _camPosition;
	dist_array[3] = tempvec.length();
	
	// find longest length from point for this tile
	for (int i =0; i<4; i++) {
		if (dist_array[i] > maxdist) {
			maxdist = dist_array[i];
		}
	}
	
	return maxdist;
	
	
}



bool ofxWBCGenericTile::cullFrustum(ofxCamera* _camera, ofxVec3f _position)
{
	bool inFrustum = false;
	
	// am I?
	inFrustum = _camera->inFrustum(mCentroid + _position, mScaledSize[0]);
	
	// are my kids
	for (int i = 0; i < children.size(); i++)
	{
		if (children[i]->cullFrustum(_camera, _position)) {
			
			inFrustum = true;
		}
	}	
	
		// by default the root tile is
		if (mZoomLevel == 0) {
			inFrustum = true;
		}
	
	mInViewFrustum = inFrustum;
	
	if (!mInViewFrustum) {
		// not in view frustum
		hibernateTile();
		
	}
	else if	(bInHibernation)
	{
		// tile has been previously hibernated, and is in view frustum
		unHibernateTile();
		
	}
	
	return inFrustum;
}



float ofxWBCGenericTile::calculateTexelSize()
{
	float texelSize = -1.0f;
	
	if (mAllocated) {
		
		texelSize = pow(2.0f, mNumResolutions - mZoomLevel);
		return texelSize;
	}
	
	return texelSize;	
}



void ofxWBCGenericTile::drawQuad(int mode, ofxVec3f _center, ofxVec3f _size)
{
	
	//GLfloat w2=w/2.0, h2=h/2.0;
	GLfloat w2 = _size[0]/2;
	GLfloat h2 = _size[1]/2;
	GLfloat cx = _center[0];
	GLfloat cy = _center[1];
	GLfloat z = _center[2];
	
	
	const GLfloat vertices1[] = {
		cx-w2, cy-h2, z,
		cx+w2, cy-h2, z,
		cx-w2, cy+h2, z,
		cx+w2, cy+h2, z,
	};
	
	//	GLfloat	 coordinates1[] = { 
	//		0,	   1.0,		
	//		1.0,   1.0,
	//		0.0,   0.0,
	//		1.0,   0.0,
	//	};
	
	glEnable(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, vertices1);
	
	glEnable(GL_BLEND);	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
	glCullFace( GL_BACK);
	glDrawArrays(mode, 0, 4);
	glCullFace( GL_FRONT );
	glDrawArrays(mode, 0, 4);
	
	// Now we are done drawing disable blending
	glDisable(GL_BLEND);
	glDisable(GL_VERTEX_ARRAY);
}

void ofxWBCGenericTile::drawQuad(GLenum mode, GLfloat cx, GLfloat cy, GLfloat z, GLfloat w, GLfloat h)
{
	GLfloat w2=w/2.0, h2=h/2.0;
	
	const GLfloat vertices1[] = {
		cx-w2, cy-h2, z,
		cx+w2, cy-h2, z,
		cx-w2, cy+h2, z,
		cx+w2, cy+h2, z,
	};
	
	//	GLfloat	 coordinates1[] = { 
	//		0,	   1.0,		
	//		1.0,   1.0,
	//		0.0,   0.0,
	//		1.0,   0.0,
	//	};
	
	glEnable(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, vertices1);
	
	glEnable(GL_BLEND);	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
	glCullFace( GL_BACK);
	glDrawArrays(mode, 0, 4);
	glCullFace( GL_FRONT );
	glDrawArrays(mode, 0, 4);
	
	glDisable(GL_BLEND);
	glDisable(GL_VERTEX_ARRAY);
	
}


#pragma mark -
#pragma mark Populate with image 

ofxWBCGenericTile* ofxWBCGenericTile::getByResRowCol(int _res, int _row, int _col)
{
	// returns a pointer to the tile corresponding to res/row/column
	
	ofxWBCGenericTile* toReturn = NULL;
	
	if ( mZoomLevel == _res )
	{
		if ( mI == _row) {
			if ( mJ == _col) {
				// foundit 
				if (mAllocated) {
					toReturn = this;					
				}
			}
			else {
			}
		}
		else {
		}
		
	}
	else {
		
		for (int i = 0; i < children.size(); i++) {
			
			ofxWBCGenericTile* tempTile = children[i]->getByResRowCol(_res, _row, _col);
			
			if (tempTile != NULL) {
				toReturn = tempTile;
			}
		}
	}
	
	return toReturn;
}




//
//			//printf("hibernate file exists\n");
//			
//			Tile* tile = &levels[res].tiles[row][col];
//			unsigned char* pixels = this->load_fetched_tile_from_disk(res,row,col);
//			if(!pixels) { 
//				printf("ISSUE HERE");
//				tile->is_bad=GL_TRUE;
//			}
//			else {
//				tile->pixels = pixels;
//				//should_segment = false	;
//				if(should_segment) {     
//					if(!segmenter) {
//						segmenter = new Segmenter(pixels,256,256);
//						//				printf("made a segmenter");
//					}
//					segmenter->segmentRGBAImage(pixels,256,256);
//				}
//				
//				this->make_tile_texture(res,row,col);
//				tile->is_active=GL_TRUE;
//				
//				
//				
//				// 256x256 RGBA pixels are returned
//			GLubyte* MultiresSlide::load_fetched_tile_from_disk(int res, int row, int col)
//			{
//				GLubyte *padded_pixels;
//				int width,height;
//				char filename[80];
//				Tile* tile = &levels[res].tiles[row][col];
//				snprintf(filename,sizeof(filename),"%i-%i-%i.jpg",res,col,row);
//				
//				unsigned char* pixels = readImagefile(filename, &width, &height);
//				
//				if(res==0) {
//					this->thumb_width_px=width;
//					this->thumb_height_px=height;
//				}
//				
//				if(unlinking_tiles) { 
//					unlink(filename); // remove the jpeg file
//				}
//				
//				if(!pixels) { 
//					if(verbosity>=2) { fprintf(stderr,"Failed to read %s\n",filename); }
//					tile->is_bad=1;
//					return NULL; 
//				}
//				if(width>256 || height>256) {
//					fprintf(stderr,
//							"== Warning: Tile too large at res %i, row %i, col %i: %ix%i\n"
//							"   Expected 256x256 or less. ==\n",
//							res,row,col, width,height);
//					// return NULL;
//				}
//				if(width<256 || height<256) {
//					// Pad the image to be 256x256.
//					int yi,xi,ci;
//					padded_pixels = (GLubyte*)malloc(256*256*4);
//					for(yi=0;yi<256;yi++) {
//						for(xi=0;xi<256;xi++) {
//							for(ci=0;ci<4;ci++) {
//								padded_pixels[ci+4*(xi+256*yi)] = 
//								(xi>=width||yi>=height)
//								?should_pad_with_noise
//								?(drand48()*255)
//								:(ci==3?0:255)
//								:pixels[ci+4*(xi+width*yi)];
//							}
//						}
//					}
//					free(pixels);
//				}
//				else {
//					assert(width==256&&height==256);
//					padded_pixels=pixels;
//				}
//				
//				
//				return padded_pixels;




