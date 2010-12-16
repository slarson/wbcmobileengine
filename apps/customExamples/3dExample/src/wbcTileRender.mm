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

#include "wbcTileRender.h"

#pragma mark Constructor

wbcTileRender::wbcTileRender()
{
	bNeedsToReload = false;
	bHasTileDescription = false;
	bHasAllocatedTiles	= false;
	bShouldUpdateTiles	= true;
	
	ofxWBCEvents.addListener(this);
	
}

#pragma mark -
#pragma mark OFX Core functions

void wbcTileRender::setup()
{
	
	
}

void wbcTileRender::setDownloadState(bool bPressDown)
{
	bShouldUpdateTiles = !bPressDown;	
}

void wbcTileRender::cleanHibernatedTiles()
{
	for( int i = 0; i < mTileSet.size(); i++)
	{
		ofxWBCGenericTile* temptile = mTileSet[i];
		
		temptile->cleanHibernatedTiles();
		
	}
	
	
}



void wbcTileRender::updateScene()
{
	// if the tilerender has a data description loaded
	
	if (bNeedsToReload) {
		
		//ofxWBCUtil.clearQueue();
		
		for( int i = 0; i < mTileSet.size(); i++)
		{
			ofxWBCGenericTile* _toDelete = mTileSet[i];
			
			_toDelete->clearTile();
			
			delete _toDelete;
		}
		
		mTileSet.clear();
		bNeedsToReload = false;
		bHasAllocatedTiles = false;
		
	}
	else {
		
		
		if (bHasTileDescription)
		{			
			// if there are no tiles loaded into the tileset, load from data description
			if (mTileSet.size() == 0) {
				
				for (int i = 0; i < fmin(mTileDescription->mSlideList.size(), 1); i++) {
					//printf("%d\n", i);
					
					ofxWBCSlideDescription* _description = mTileDescription->mSlideList[i];
					ofxVec3f _tiledimension = ofxVec3f(_description->mWidth_px, _description->mHeight_px, 0.0f);
					
					if (mTileDescription->mTileFormat == WBC_ZOOMIFY) {
						
						ofxWBCGenericTile* top = new ofxWBCGenericTile(_tiledimension, 
																	   _description->mNumberOfResolutions, 
																	   mTileDescription->mTileFormat, 
																	   _description->mTileSize_px,
																	   0, 0, 0,
																	   &_description->mSlidePath, &mTileDescription->mDataName, _description->mSlideID);
						// dataname will be the name that gets appended as prefix to local cache
						
						top->allocateTop();
						
						mTileSet.push_back(top);
						
						printf("[TILE] There are %d resolutions for index %d\n", _description->mNumberOfResolutions, i);
						
						mBoundingBox = ofxVec3f(_description->mWidth_px, _description->mHeight_px, 1.0f);
						mPosition =	ofxVec3f(0.0f,0.0f,0.0f);
						
						mOffsetPosition = mPosition - ofxVec3f(_description->mWidth_px/2, _description->mHeight_px/2, 0.0f);
						
						printf("Centered at: %f %f %f\n", mPosition[0], mPosition[1], mPosition[2]);
						
						bHasAllocatedTiles = true;
					}
					
					else if (mTileDescription->mTileFormat == WBC_BRAINMAPS){
						
						
						ofxWBCGenericTile* top = new ofxWBCGenericTile(_tiledimension, 
																	   _description->mNumberOfResolutions, 
																	   mTileDescription->mTileFormat, 
																	   _description->mTileSize_px,
																	   0, 0, 0,
																	   &_description->mSlidePath, &mTileDescription->mDataName, _description->mSlideID);			
						// dataname will be the name that gets appended as prefix to local cache
						
						//						ofxWBCGenericTile* top = new ofxWBCGenericTile(_tiledimension, 
						//																	   _description->mNumberOfResolutions, 
						//																	   mTileDescription->mTileFormat, 
						//																	   _description->mTileSize_px,
						//																	   0, 0, 0,
						//																	   &mTileDescription->mURL,
						//																	   _description->mSlidePath,
						//																	   &mTileDescription->mDataName);			
						//						
						
						
						top->allocateTop();
						mTileSet.push_back(top);
						
						printf("[TILE] There are %d resolutions for index %d\n", _description->mNumberOfResolutions, i);
						
						mBoundingBox = ofxVec3f(_description->mWidth_px, _description->mHeight_px, 1.0f);
						mPosition =	ofxVec3f(0.0f,0.0f, -300.0f);
						
						mOffsetPosition = mPosition - ofxVec3f(_description->mWidth_px/2, _description->mHeight_px/2, 0.0f);
						
						printf("Centered at: %f %f %f\n", mPosition[0], mPosition[1], mPosition[2]);
						
						bHasAllocatedTiles = true;						
					}
					else if (mTileDescription->mTileFormat == WBC_ZFISH){
						
						
						ofxWBCGenericTile* top = new ofxWBCGenericTile(_tiledimension, 
																	   _description->mNumberOfResolutions, 
																	   mTileDescription->mTileFormat, 
																	   _description->mTileSize_px,
																	   0, 0, 0,
																	   &_description->mSlidePath, &mTileDescription->mDataName, _description->mSlideID);
						top->allocateTop();
						mTileSet.push_back(top);
						
						printf("[TILE] There are %d resolutions for index %d\n", _description->mNumberOfResolutions, i);
						
						mBoundingBox = ofxVec3f(_description->mWidth_px, _description->mHeight_px, 1.0f);
						mPosition =	ofxVec3f(0.0f,0.0f,0.0f);
						
						mOffsetPosition = mPosition - ofxVec3f(_description->mWidth_px/2, _description->mHeight_px/2, 0.0f);
						
						printf("Centered at: %f %f %f\n", mPosition[0], mPosition[1], mPosition[2]);
						
						bHasAllocatedTiles = true;						
					}
				}
			}
			else {
				
				
				
				// tile set already has tiles, but no reload was called (may be needed later)
				
			}
		}
		
		else {
			
			
		}
		
	}
	
	
	
}

void wbcTileRender::drawBoundingBox()
{
	
}


void wbcTileRender::drawScene()
{
	// this determines draw order
	for( int i =  mTileSet.size()-1; i >= 0; i--)
//	for (int i = 0; i < mTileSet.s; i++) 
	{		
		glPushMatrix();
		
		glTranslatef(mOffsetPosition[0], mOffsetPosition[1], mOffsetPosition[2] -50*i);
	//	
//		ofSetColor(0, 0, 0);
//		ofFill();
//		ofRect(-50, -50, mTileDescription->mSlideList[i]->mWidth_px+100, mTileDescription->mSlideList[i]->mHeight_px+100);
//		
		ofSetColor(255, 255,255, 255);
		
		mTileSet[i]->draw(bShouldUpdateTiles);
		
//		for (int j = 0; j < mTileDescription->mTraceList.size(); j++) {
//			
//			ofSetColor(200, 0, 0,255);
//			MSA::drawInterpolatorSmooth(mTileDescription->mTraceList[j], 100, 1, 3);
//			
//			ofSetColor(255, 255, 255);
//			MSA::drawInterpolatorRaw(mTileDescription->mTraceList[j], 5, 0);
//		}
		
		
		glPopMatrix();
		
	}
}

void wbcTileRender::drawTraces()
{
	for (int i = 0; i < 1; i++) 
	{		
		glPushMatrix();
		
		glTranslatef(mOffsetPosition[0], mOffsetPosition[1], mOffsetPosition[2]);
		for (int j = 0; j < mTileDescription->mTraceList.size(); j++) {
			
			ofSetColor(200, 0, 0,255);
			MSA::drawInterpolatorSmooth(mTileDescription->mTraceList[j], 100, 1, 3);
			
			ofSetColor(255, 255, 255);
			MSA::drawInterpolatorRaw(mTileDescription->mTraceList[j], 5, 0);
		}
		glPopMatrix();
	}
}

void wbcTileRender::exit()
{
	
}

#pragma mark -
#pragma mark Frustum calling

void wbcTileRender::cullViewFrustum(ofxCamera* _camera)
{
	for( int i = 0; i < mTileSet.size(); i++)
	{
		//mTileSet[i]->cullFrustum(_camera);
		mTileSet[i]->cullFrustum(_camera, mOffsetPosition);
	}
}




#pragma mark -
#pragma mark Loading and Unloading of data

void wbcTileRender::setDataDescription(wbcDataDescription* _tileDescription)
{
	if (_tileDescription) {
		mTileDescription = _tileDescription;
		
		printf("[WBC TILE] Loaded %s into Tile Render\n", mTileDescription->mDataName.c_str());
		
		mPosition = ofxVec3f(0.0f, 0.0f, 0.0f);
		
		bHasTileDescription = true;
		bNeedsToReload = true;
	}
}


#pragma mark -
#pragma mark Handle downloads

void wbcTileRender::newResponse(ofxWBCResponse &response) {	
	
	//printf("[WBC] File received by tile engine!\n");
	
	if (response.contentType.compare("image/jpeg")==0)
	{
		//printf("[WBC] image/jpeg mime filetype received\n");
		size_t loc1 = response.url.find(mTileDescription->mDataName);
		
		if (loc1 != string::npos)
		{	
			printf("+");
			//	printf("[WBC ZOOMIFY] Downloaded tile belongs to: %s \n", mTileDescription->mDataName.c_str());
			
			string delim = "/";
			vector<string> tokens;
			size_t p0 = 0, p1 = string::npos;
			while(p0 != string::npos)
			{
				p1 = response.url.find_first_of(delim, p0);
				if(p1 != p0)
				{
					string token = response.url.substr(p0, p1 - p0);
					tokens.push_back(token);
				}
				p0 = response.url.find_first_not_of(delim, p1);
			}
			
			string dataOrIndex = tokens[tokens.size() - 3];
			size_t locOfName = dataOrIndex.find(mTileDescription->mDataName);
			
			int m = 0;			
			if ( locOfName != string::npos) {
				// found, 
			}
			else {
				for(m; m < mTileSet.size(); m++)
				{
					size_t whichSlide = mTileSet[m]->mURL->find(dataOrIndex);
					
					if (whichSlide != string::npos) {
						//						printf("found at slide %d\n", m);
						//						targetslide = m;
						break;
						
					}
				}
				
			}
			
			
			string filename = tokens[tokens.size() - 1];
			
			
			delim = "-";
		//	printf("filename: %s\n", filename.c_str());
			
			tokens.clear();
			
			p0 = 0, p1 = string::npos;
			
			while(p0 != string::npos)
			{
				p1 = filename.find_first_of(delim, p0);
				if(p1 != p0)
				{
					string token = filename.substr(p0, p1 - p0);
					tokens.push_back(token);
				}
				p0 = filename.find_first_not_of(delim, p1);
			}
			
			
			
			
			
			int res = ofToInt(tokens[0]);
			int row = ofToInt(tokens[1]);
			int col = ofToInt(tokens[2]);
			
			if(bHasAllocatedTiles)
			{
				
				ofxWBCGenericTile* tilePtr = mTileSet[m]->getByResRowCol(res,row, col);
				
				if (tilePtr) {
					
					if (tilePtr->mInViewFrustum) {
						
						if(!doesFileExist(tilePtr->mHibernateFilename))
						{
							
							NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
							
							NSError* error;
							downloadedBuffer = [NSData dataWithBytes:response.responseBody.data() length:response.responseBody.length()];
							paths = [NSArray arrayWithArray:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)];
							temporaryDirectory = [NSString stringWithString:[paths objectAtIndex:0]];
							path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:tilePtr->mHibernateFilename.c_str()]];
							
							[downloadedBuffer writeToFile:path options:NSAtomicWrite error:&error];
							//					[downloadedBuffer release];
							
							[pool release];
							
							
						}
						
					}
				}
				
			}
			

		}
		else {
			printf("?");
		}
	}
	else if (response.contentType.compare("application/xml")==0)
	{
		printf("[WBC] application/xml mime filetype received\n");
		
	}
	else if (response.contentType.compare("text/xml")==0)
	{	
		printf("[WBC] text/xml mime filetype received\n");
		
	}
	else if (response.contentType.compare("text/html")==0)
	{			
		printf("[WBC] text/html mime filetype received\n");
	}
	else {
		
		printf("unknown: %s\n", response.url.c_str());
		printf(".");
		//printf("[WBC] unhandled filetype received: %s\n", response.contentType.c_str());
	}
}



