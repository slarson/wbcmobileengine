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

//#include "wbcMenu.h"
#include "DemoItemView.h"

#pragma mark Constructors and destructors

wbcMenu::wbcMenu()
{
	//	bWebEnabled			= false;
	bIsLoaded			= false;
	
	mXmlFile			= "";
	mXmlDone			= true;
	
	mBMcount			= 25; // never used
	mBMstartindex		= 90; // nope, never used either
	
	ofxHttpEvents.addListener(this);
	
	//	if(ofGetWidth() == 480)
	//	{
	//		descriptionView	= [[UIWebView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];		
	//		descriptionView.scalesPageToFit = true;
	//		descriptionView.backgroundColor = [UIColor blackColor];
	//		descriptionView.hidden = true;
	//		
	//	}
	//	else {
	//		descriptionView	= [[UIWebView alloc] initWithFrame:CGRectMake(130, -130, 512, 768)];
	//		descriptionView.scalesPageToFit = true;
	//		descriptionView.backgroundColor = [UIColor blackColor];
	//		descriptionView.hidden = true;
	//	}
	//	
	//	[ofxiPhoneGetGLView() addSubview:descriptionView];
	//	

				//mGrid.setLayout(ofxPoint2f(400, 55), ofxPoint2f(615, 708));
	_arrayView = [[ATArrayView alloc] initWithFrame:CGRectMake(50,355,615,708)];

	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI / 2);
	_arrayView.transform = transform;
	
	[ofxiPhoneGetGLView() addSubview:_arrayView];
	[_arrayView release];
}



#pragma mark -
#pragma mark Core

void wbcMenu::update()
{	
	
	for (int i = 0; i < mItems.size(); i++) {
		wbcDynamicElement* tempObject = mItems.at(i);
		
		if(tempObject->enabled)
		{
			tempObject->update();
		}
	}
}

void wbcMenu::disableAllElements()
{
	for (int i = 0; i < mItems.size(); i++) {
		wbcDynamicElement* tempObject = mItems.at(i);
		tempObject->disableAllEvents();
		//		if(tempObject->enabled)
		//		{
		//			tempObject->update();
		//		}
	}
	
	[_arrayView hide:YES];
	[_arrayView interact:NO];
}

void wbcMenu::enableAllElements()
{
	for (int i = 0; i < mItems.size(); i++) {
		wbcDynamicElement* tempObject = mItems.at(i);
		tempObject->enableTouchEvents();
		//		if(tempObject->enabled)
		//		{
		//			tempObject->update();
		//		}
		
	}
	
	[_arrayView hide:NO];
	[_arrayView interact:YES];
}

void wbcMenu::linkToGui(ofxGuiGlobals* guiPtr)
{
	mGlobals = guiPtr;
	
}

void wbcMenu::loadResources(ofxGuiGlobals* guiPtr)
{
	
	switch (ofGetWidth()) {
		case 480:
			mDetailPosition			= ofxPoint2f(80.0, 0.0);
			mDetailSize				= ofxPoint2f(320,320);
			
			mDescriptionPosition	= ofxPoint2f(ofGetWidth() - 250,10);
			mDescriptionSize		= ofxPoint2f(240,240);
			
			mGrid.mScale = 0.5;
			mGrid.mSideLength = 128;
			mGrid.setLayout(ofxPoint2f(20, 20), ofxPoint2f(440, 300));
			
			break;
			
		case 1024:
			
			mDetailPosition			= ofxPoint2f(25, ofGetHeight() - 266);
			mDetailSize				= ofxPoint2f(256,256);
			
			mDescriptionPosition    = ofxPoint2f(20, 70.0f);
			mDescriptionSize		= ofxPoint2f(340, 340);
			
			mGrid.mScale = 1.33;
			mGrid.setLayout(ofxPoint2f(400, 55), ofxPoint2f(615, 708));
			
			break;
			
		default:
			break;
	}
	
	bIsLoaded = true;
	
}

#pragma mark -
#pragma mark Populate menu with data 

bool wbcMenu::loadCustomSitesIfPresent(bool _withNetwork)
{
	// check for file
	
	string customfilename = "customsites.xml";
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *temporaryDirectory = [paths objectAtIndex:0];
	NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:customfilename.c_str()]];
	
	
	// file already exists! : good, load it, and the rest:
	if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
	{
		
		int _start = 0;
		int _count = 100;
		int tic = ofGetElapsedTimeMillis();
		
		mXmlFile			= ofxNSStringToString(path);
		if(!mXmlDone)
		{
			return false;
		}
		
		printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
		
		if(!mXml.loadFileAbsolute(mXmlFile))
		{
			printf("[WBC - XML] XML Error in load\n");
			return false;
		}
		
		int	numberOfTags = mXml.getNumTags("site");	
		int _itemsToLoad = 0;
		if (numberOfTags == 0 ) { return false; }
		
		if (_start >= numberOfTags) { return false; }
		
		if ((_start + _count) >= numberOfTags)
		{ 
			_itemsToLoad = numberOfTags - _start; 
		}
		else {
			_itemsToLoad = _count;
		}
		
		
		mXmlDone = false;
		
		
		for (int i = _start; i < _start + _itemsToLoad; i++)
		{
			mXml.pushTag("site", i);
			
			//printf("site %d\n", i);
			
			
			// check to see if the site is available, if yes then load, if no, try cache, if no cache then skip
			
			wbcDynamicElement* tempElement = new wbcDynamicElement();
			tempElement->elementData = new wbcDataDescription();
			tempElement->elementData->loadFromZoomifyURL(mXml.getAttribute("url", "address", ""));
			
			string tempfilename = tempElement->elementData->mDataName;
			
			// remove any misc periods in filename... stupid .aff formats ;)
			size_t found;
			found = tempfilename.find(".");
			if (found !=string::npos) {
				tempfilename.erase(found);
			}
			
			string mHibernateFilename = tempfilename + "_thumb.jpg";
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *temporaryDirectory = [paths objectAtIndex:0];
			NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:mHibernateFilename.c_str()]];
			
			bool shouldAddItem = false;
			
			// option 1, file already exists! : good, load it, and the rest:
			if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
			{
				printf("Thumbnail exists, loading.\n");
				tempElement->baseImage.loadImage([path UTF8String]);
				shouldAddItem = true;
				
			}
			else {
				// option 2: check network and load it
				
				if([ ofxiPhoneGetGLView() reachable])
				{
					tempElement->imageURL = mXml.getAttribute("url", "address", "") + "TileGroup0/0-0-0.jpg";
					tempElement->baseImage.loadFromUrl(tempElement->imageURL);
					tempElement->baseImage.saveImage([path UTF8String]);
					
					shouldAddItem = true;
				}
				else {
					// file does not exist and network is unreachable... sorry not loading this today.
				}
			}
			
			if(shouldAddItem)
			{
				tempElement->title = mXml.getValue("title","");
				tempElement->setSize(mGrid.getSize());
				tempElement->sharedFont = &mGlobals->mParamFont;
				tempElement->disableAllEvents();
				tempElement->enableTouchEvents();
				tempElement->mGlobals = mGlobals;
				tempElement->parameterID = mItems.size();
				tempElement->enabled = true;
				tempElement->websiteURL = mXml.getAttribute("websiteURL", "address","");
				
				tempElement->elementData->mSite = mXml.getValue("site", "");
				tempElement->elementData->mAttribution = mXml.getValue("attribution", "");
				tempElement->elementData->mSpecies = mXml.getValue("species","");
				
				int _width		= mXml.getAttribute("IMAGE_PROPERTIES", "WIDTH", 0);
				int _height		= mXml.getAttribute("IMAGE_PROPERTIES", "HEIGHT", 0);
				int _tileSize	= mXml.getAttribute("IMAGE_PROPERTIES", "TILESIZE", 0);
				
				// assume 1 slide exists, populate it from the local xml file
				
				ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
				tempslide->mWidth_px		= _width;
				tempslide->mHeight_px		= _height;
				tempslide->mTileSize_px		= _tileSize;
				tempslide->mSlidePath		= mXml.getAttribute("url", "address", "");  //directory containing imageproperties.xml
				tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
				
				// push to slide list
				tempElement->elementData->mSlideList.push_back(tempslide);
				tempElement->elementData->bHasMetaData = true;
				tempElement->elementData->mDisplayName = mXml.getValue("displayName", "");
				
			//	
//				// load any existing traces...doesn't really get used, yet.
//				int numTraces = mXml.getNumTags("traces");
//				for(int j = 0; j < numTraces; j++)
//				{
//					mXml.pushTag("traces"); // change relative root to <feed>
//					int numEntries = mXml.getNumTags("trace");
//					
//					wbcAnnotation* tempContour = new wbcAnnotation();
//					tempContour->label = mXml.getAttribute("trace", "name", "", 0);
//					//				tempContour->label = "loaded";
//					
//					for (int i = 0; i < numEntries; i++) {
//						
//						mXml.pushTag("trace", i);
//						
//						int point_count = mXml.getNumTags("point");
//						
//						//	printf("[WBC] Found %d points to add\n", point_count);
//						
//						for (int j = 0; j < point_count; j++)
//						{
//							ofxVec3f temppoint;
//							temppoint[0] = mXml.getAttribute("point", "x", 0.0, j); 
//							temppoint[1] = mXml.getAttribute("point", "y", 0.0, j);
//							temppoint[2] = mXml.getAttribute("point", "z", 0.0, j);		
//							
//							tempContour->contour.push_back(temppoint);
//							tempContour->containsData = true;					
//						}
//						mXml.popTag();
//					}
//					tempElement->elementData->mTraceList.push_back(tempContour);
//					mXml.popTag(); 
//				}
				
				mItems.push_back(tempElement);
				[_arrayView insert:path];
				setupItemInArrayView();
			}
												
			else {
				
				printf("no network or cache found, not loading\n");
				
				// clear the allocated components
				delete tempElement->elementData;			
				delete tempElement;
				tempElement = NULL; //probably redundant
				
			}
			
			mXml.popTag();
		}
		
		mXmlDone = true;
		
		int toc = ofGetElapsedTimeMillis() - tic;
		
		printf("[WBC - XML] Successfully parsed %d zoomify URLS from CUSTOM xml in %d ms\n", (int)mItems.size(), toc);
		
		return true;
		
		
	}
	else {
		
		// file doesn't exist, return false
		
		
		return false;
		
	}
	
	return false;
}


bool wbcMenu::loadLocalSites(bool _withNetwork)
{
	return loadLocalSites(_withNetwork, 0, 100);
}

bool wbcMenu::loadLocalSites(bool _withNetwork, int _start, int _count)
{
	// read xml file
	// loop through, adding files as needed
	
	int tic = ofGetElapsedTimeMillis();
	
	mXmlFile			= "localData.xml";
	if(!mXmlDone)
	{
		return false;
	}
	
	printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
	
	if(!mXml.loadFile(mXmlFile))
	{
		printf("[WBC - XML] XML Error in load\n");
		return false;
	}
	
	int	numberOfTags = mXml.getNumTags("site");	
	int _itemsToLoad = 0;
	if (numberOfTags == 0 ) { return false; }
	
	if (_start >= numberOfTags) { return false; }
	
	if ((_start + _count) >= numberOfTags)
	{ 
		_itemsToLoad = numberOfTags - _start; 
	}
	else {
		_itemsToLoad = _count;
	}
	
	
	mXmlDone = false;
	
	
	for (int i = _start; i < _start + _itemsToLoad; i++)
	{
		mXml.pushTag("site", i);
		
		//printf("site %d\n", i);
		
		
		// check to see if the site is available, if yes then load, if no, try cache, if no cache then skip
		
		wbcDynamicElement* tempElement = new wbcDynamicElement();
		tempElement->elementData = new wbcDataDescription();
		tempElement->elementData->loadFromZoomifyURL(mXml.getAttribute("url", "address", ""));
		
		string tempfilename = tempElement->elementData->mDataName;
		
		// remove any misc periods in filename... stupid .aff formats ;)
		size_t found;
		found = tempfilename.find(".");
		if (found !=string::npos) {
			tempfilename.erase(found);
		}
		
		string mHibernateFilename = tempfilename + "_thumb.jpg";
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *temporaryDirectory = [paths objectAtIndex:0];
		NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:mHibernateFilename.c_str()]];
		
		bool shouldAddItem = false;
		
		// option 1, file already exists! : good, load it, and the rest:
		if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
		{
			printf("Thumbnail exists, loading.\n");
			tempElement->baseImage.loadImage([path UTF8String]);
			shouldAddItem = true;
			
		}
		else {
			// option 2: check network and load it
			
			if([ ofxiPhoneGetGLView() reachable])
			{
				tempElement->imageURL = mXml.getAttribute("url", "address", "") + "TileGroup0/0-0-0.jpg";
				tempElement->baseImage.loadFromUrl(tempElement->imageURL);
				tempElement->baseImage.saveImage([path UTF8String]);
				shouldAddItem = true;
				
			}
			else {
				// file does not exist and network is unreachable... sorry not loading this today.
			}
		}
		
		if(shouldAddItem)
		{
			tempElement->title = mXml.getValue("title","");
			tempElement->setSize(mGrid.getSize());
			tempElement->sharedFont = &mGlobals->mParamFont;
			tempElement->disableAllEvents();
			tempElement->enableTouchEvents();
			tempElement->mGlobals = mGlobals;
			tempElement->parameterID = mItems.size();
			tempElement->enabled = true;
			tempElement->websiteURL = mXml.getAttribute("websiteURL", "address","");
			
			tempElement->elementData->mSite = mXml.getValue("site", "");
			tempElement->elementData->mAttribution = mXml.getValue("attribution", "");
			tempElement->elementData->mSpecies = mXml.getValue("species","");
			
			int _width		= mXml.getAttribute("IMAGE_PROPERTIES", "WIDTH", 0);
			int _height		= mXml.getAttribute("IMAGE_PROPERTIES", "HEIGHT", 0);
			int _tileSize	= mXml.getAttribute("IMAGE_PROPERTIES", "TILESIZE", 0);
			
			// assume 1 slide exists, populate it from the local xml file
			
			ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
			tempslide->mWidth_px		= _width;
			tempslide->mHeight_px		= _height;
			tempslide->mTileSize_px		= _tileSize;
			tempslide->mSlidePath		= mXml.getAttribute("url", "address", "");  //directory containing imageproperties.xml
			tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
			
			// push to slide list
			tempElement->elementData->mSlideList.push_back(tempslide);
			tempElement->elementData->bHasMetaData = true;
			tempElement->elementData->mDisplayName = mXml.getValue("displayName", "");
			
//			
//			// load any existing traces...doesn't really get used, yet.
//			int numTraces = mXml.getNumTags("traces");
//			for(int j = 0; j < numTraces; j++)
//			{
//				mXml.pushTag("traces"); // change relative root to <feed>
//				int numEntries = mXml.getNumTags("trace");
//				
//				wbcAnnotation* tempContour = new wbcAnnotation();
//				tempContour->label = mXml.getAttribute("trace", "name", "", 0);
//				//				tempContour->label = "loaded";
//				
//				for (int i = 0; i < numEntries; i++) {
//					
//					mXml.pushTag("trace", i);
//					
//					int point_count = mXml.getNumTags("point");
//					
//					//	printf("[WBC] Found %d points to add\n", point_count);
//					
//					for (int j = 0; j < point_count; j++)
//					{
//						ofxVec3f temppoint;
//						temppoint[0] = mXml.getAttribute("point", "x", 0.0, j); 
//						temppoint[1] = mXml.getAttribute("point", "y", 0.0, j);
//						temppoint[2] = mXml.getAttribute("point", "z", 0.0, j);		
//						
//						tempContour->contour.push_back(temppoint);
//						tempContour->containsData = true;					
//					}
//					mXml.popTag();
//				}
//				tempElement->elementData->mTraceList.push_back(tempContour);
//				mXml.popTag(); 
//			}
			
			mItems.push_back(tempElement);
			[_arrayView insert:path];
			setupItemInArrayView();
		}
		else {
			
			printf("no network or cache found, not loading\n");
			
			// clear the allocated components
			delete tempElement->elementData;			
			delete tempElement;
			tempElement = NULL; //probably redundant
			
		}
		
		mXml.popTag();
	}
	
	mXmlDone = true;
	
	int toc = ofGetElapsedTimeMillis() - tic;
	
	printf("[WBC - XML] Successfully parsed %d zoomify URLS from local xml in %d ms\n", (int)mItems.size(), toc);
	
	return true;
}



bool wbcMenu::loadBrainMapsFromLocalXML(int _count)
{
	loadBrainMapsFromLocalXML(0, _count);
	return true;
}


bool wbcMenu::loadBrainMapsFromLocalXML(int _start, int _count)
{
	
	
	int tic = ofGetElapsedTimeMillis();
	mXmlFile = "brainmaps-pretty.xml";
	if(!mXmlDone) {return false;}
	
	if(!mXml.loadFile(mXmlFile))
	{
		printf("[WBC] XML Error in load\n");
		return false;
	}
	
	int numberOfTags = mXml.getNumTags("table");	
	if (numberOfTags != 1) { return false; }
	
	mXmlDone = false;
	mXml.pushTag("table", 0);
	
	numberOfTags = mXml.getNumTags("record");
	
	if (_count == -1) {
		_count = numberOfTags;
	}
	else {
	}
	
	int _itemsToLoad = 0;
	if (numberOfTags == 0 ) { return false; }
	
	if (_start >= numberOfTags) { return false; }
	
	if ((_start + _count) >= numberOfTags)
	{ 
		_itemsToLoad = numberOfTags - _start; 
	}
	else {
		_itemsToLoad = _count;
	}
	
	
	for (int i = _start; i < _start + _itemsToLoad; i++)
	{
		mXml.pushTag("record", i + _start);
		
		// load 
		
		wbcDynamicElement* tempElement = new wbcDynamicElement();
		tempElement->elementData = new wbcDataDescription();
		tempElement->title = mXml.getValue("dataset","");
		tempElement->elementData->loadFromBrainMaps(tempElement->title);
		tempElement->elementData->bmDirectory = mXml.getValue("dirname", "");		
		
		string thumbFileName = tempElement->title + "_0-0-0.jpg";
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *temporaryDirectory = [paths objectAtIndex:0];
		NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
		
		bool shouldAddItem = false;
		
		if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
		{
			printf("Thumbnail exists, loading.\n");
			tempElement->baseImage.loadImage([path UTF8String]);
			shouldAddItem = true;
		}
		else
		{
			if([ ofxiPhoneGetGLView() reachable])
			{
				tempElement->imageURL = tempElement->elementData->mURL + tempElement->elementData->bmDirectory + mXml.getValue("thumb_url", "");
				printf("Thumb url: %s\n", tempElement->imageURL.c_str());
				
				if(	tempElement->baseImage.loadFromUrl(tempElement->imageURL))
				{
					tempElement->baseImage.saveImage([path UTF8String]);
					shouldAddItem = true;
				}
			}
			else {
				// file does not exist and network is unreachable... sorry not loading this today.
			}
			
		}
		
		if(shouldAddItem)
		{
			tempElement->setSize(mGrid.getSize());
			tempElement->sharedFont = &mGlobals->mParamFont;
			tempElement->disableAllEvents();
			tempElement->enableTouchEvents();
			tempElement->mGlobals = mGlobals;
			
			tempElement->parameterID = mItems.size();
			tempElement->enabled = true;
			tempElement->elementData->loadFromBrainMaps(tempElement->title);
			tempElement->elementData->bmID = mXml.getValue("Id", 0);
			tempElement->elementData->bmOrganSpecies = mXml.getValue("species", "");
			tempElement->elementData->bmStain = mXml.getValue("stain", "");
			tempElement->elementData->bmMethod = mXml.getValue("method", "");
			tempElement->elementData->bmPlane = mXml.getValue("plane", "");
			tempElement->elementData->bmArea = mXml.getValue("area", "");
			tempElement->elementData->bmSource = mXml.getValue("source", "");
			tempElement->elementData->bmSlides = mXml.getValue("slides", 0);
			tempElement->elementData->bmDateAdded = mXml.getValue("date_added", "");
			tempElement->elementData->bmResolution = mXml.getValue("res", 0.0f);
			tempElement->elementData->bmThickness = mXml.getValue("thick", 0.0f);
			tempElement->elementData->bmDirectory = mXml.getValue("dirname", "");
			
			tempElement->elementData->mAttribution = mXml.getValue("source", "");
			tempElement->elementData->mSpecies = mXml.getValue("species", "");
			tempElement->elementData->mSite = "Brainmaps.org";
			tempElement->elementData->mDisplayName = tempElement->title;
			
			mItems.push_back(tempElement);		
			[_arrayView insert:path];
			setupItemInArrayView();
		}
		else {
			
			printf("no network or cache found, not loading\n");
			
			// clear the allocated components
			delete tempElement->elementData;			
			delete tempElement;
			tempElement = NULL; //probably redundant
			
		}
		
		mXml.popTag();
	}
	
	mXml.popTag();
	mXmlDone = true;
	int toc = ofGetElapsedTimeMillis() - tic;
	
	//	printf("[WBC] Successfully parsed %d datasets from Brainmaps.org local xml in %d ms.\n", (int)brainmapsList.size(), toc);
	
	return true;
}


//#pragma mark -
//#pragma mark Populate menu with data 
//
//bool wbcMenu::loadLocalSites(bool _withNetwork)
//{
//	return loadLocalSites(_withNetwork, 0, 100);
//}
//
//bool wbcMenu::loadLocalSites(bool _withNetwork, int _start, int _count)
//{
//	// read xml file
//	// loop through, adding files as needed
//	
//	int tic = ofGetElapsedTimeMillis();
//	
//	mXmlFile			= "localData.xml";
//	if(!mXmlDone)
//	{
//		return false;
//	}
//	
//	printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
//	
//	if(!mXml.loadFile(mXmlFile))
//	{
//		printf("[WBC - XML] XML Error in load\n");
//		return false;
//	}
//	
//	int	numberOfTags = mXml.getNumTags("site");	
//	int _itemsToLoad = 0;
//	if (numberOfTags == 0 ) { return false; }
//	
//	if (_start >= numberOfTags) { return false; }
//	
//	if ((_start + _count) >= numberOfTags)
//	{ 
//		_itemsToLoad = numberOfTags - _start; 
//	}
//	else {
//		_itemsToLoad = _count;
//	}
//	
//	
//	mXmlDone = false;
//	
//	
//	for (int i = _start; i < _start + _itemsToLoad; i++)
//	{
//		mXml.pushTag("site", i);
//		
//		//printf("site %d\n", i);
//		
//		
//		// check to see if the site is available, if yes then load, if no, try cache, if no cache then skip
//		
//		wbcDynamicElement* tempElement = new wbcDynamicElement();
//		tempElement->elementData = new wbcDataDescription();
//		tempElement->elementData->loadFromZoomifyURL(mXml.getAttribute("url", "address", ""));
//		
//		string tempfilename = tempElement->elementData->mDataName;
//		
//		// remove any misc periods in filename... stupid .aff formats ;)
//		size_t found;
//		found = tempfilename.find(".");
//		if (found !=string::npos) {
//			tempfilename.erase(found);
//		}
//		
//		string mHibernateFilename = tempfilename + "_thumb.jpg";
//		
//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		NSString *temporaryDirectory = [paths objectAtIndex:0];
//		NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:mHibernateFilename.c_str()]];
//		
//		bool shouldAddItem = false;
//		
//		// option 1, file already exists! : good, load it, and the rest:
//		if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
//		{
//			printf("Thumbnail exists, loading.\n");
//			tempElement->baseImage.loadImage([path UTF8String]);
//			shouldAddItem = true;
//			
//		}
//		else {
//			// option 2: check network and load it
//			
//			if([ ofxiPhoneGetGLView() reachable])
//			{
//				tempElement->imageURL = mXml.getAttribute("url", "address", "") + "TileGroup0/0-0-0.jpg";
//				tempElement->baseImage.loadFromUrl(tempElement->imageURL);
//				tempElement->baseImage.saveImage([path UTF8String]);
//				shouldAddItem = true;
//			}
//			else {
//				// file does not exist and network is unreachable... sorry not loading this today.
//			}
//		}
//		
//		
//		
//		
//		if(shouldAddItem)
//		{
//			tempElement->title = mXml.getValue("title","");
//			tempElement->setSize(mGrid.getSize());
//			tempElement->sharedFont = &mGlobals->mParamFont;
//			tempElement->disableAllEvents();
//			tempElement->enableTouchEvents();
//			tempElement->mGlobals = mGlobals;
//			tempElement->parameterID = mItems.size();
//			tempElement->enabled = true;
//			tempElement->websiteURL = mXml.getAttribute("websiteURL", "address","");
//			
//			tempElement->elementData->mSite = mXml.getValue("site", "");
//			tempElement->elementData->mAttribution = mXml.getValue("attribution", "");
//			tempElement->elementData->mSpecies = mXml.getValue("species","");
//			
//			int _width		= mXml.getAttribute("IMAGE_PROPERTIES", "WIDTH", 0);
//			int _height		= mXml.getAttribute("IMAGE_PROPERTIES", "HEIGHT", 0);
//			int _tileSize	= mXml.getAttribute("IMAGE_PROPERTIES", "TILESIZE", 0);
//			
//			// assume 1 slide exists, populate it from the local xml file
//			
//			ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
//			tempslide->mWidth_px		= _width;
//			tempslide->mHeight_px		= _height;
//			tempslide->mTileSize_px		= _tileSize;
//			tempslide->mSlidePath		= mXml.getAttribute("url", "address", "");  //directory containing imageproperties.xml
//			tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
//			
//			// push to slide list
//			tempElement->elementData->mSlideList.push_back(tempslide);
//			tempElement->elementData->bHasMetaData = true;
//			tempElement->elementData->mDisplayName = mXml.getValue("displayName", "");
//			
//			
//			// load any existing traces...doesn't really get used, yet.
//			int numTraces = mXml.getNumTags("traces");
//			for(int j = 0; j < numTraces; j++)
//			{
//				mXml.pushTag("traces"); // change relative root to <feed>
//				int numEntries = mXml.getNumTags("trace");
//				
//				MSA::Interpolator3D tempContour;
//				
//				for (int i = 0; i < numEntries; i++) {
//					
//					mXml.pushTag("trace", i);
//					
//					int point_count = mXml.getNumTags("point");
//					
//					//	printf("[WBC] Found %d points to add\n", point_count);
//					
//					for (int j = 0; j < point_count; j++)
//					{
//						ofxVec3f temppoint;
//						temppoint[0] = mXml.getAttribute("point", "x", 0.0, j); 
//						temppoint[1] = mXml.getAttribute("point", "y", 0.0, j);
//						temppoint[2] = mXml.getAttribute("point", "z", 0.0, j);		
//						tempContour.push_back(temppoint);
//						
//					}
//					mXml.popTag();
//				}
//				tempElement->elementData->mTraceList.push_back(tempContour);
//				mXml.popTag(); 
//			}
//			
//			mItems.push_back(tempElement);
//		}
//		else {
//			
//			printf("no network or cache found, not loading\n");
//			
//			// clear the allocated components
//			delete tempElement->elementData;			
//			delete tempElement;
//			tempElement = NULL; //probably redundant
//			
//		}
//		
//		mXml.popTag();
//	}
//	
//	mXmlDone = true;
//	
//	int toc = ofGetElapsedTimeMillis() - tic;
//	
//	printf("[WBC - XML] Successfully parsed %d zoomify URLS from local xml in %d ms\n", (int)mItems.size(), toc);
//	
//	return true;
//}
//
//
//
//bool wbcMenu::loadBrainMapsFromLocalXML(int _count)
//{
//	loadBrainMapsFromLocalXML(0, _count);
//	return true;
//}
//
//
//bool wbcMenu::loadBrainMapsFromLocalXML(int _start, int _count)
//{
//	
//	
//	int tic = ofGetElapsedTimeMillis();
//	mXmlFile = "brainmaps-pretty.xml";
//	if(!mXmlDone) {return false;}
//	
//	if(!mXml.loadFile(mXmlFile))
//	{
//		printf("[WBC] XML Error in load\n");
//		return false;
//	}
//	
//	int numberOfTags = mXml.getNumTags("table");	
//	if (numberOfTags != 1) { return false; }
//	
//	mXmlDone = false;
//	mXml.pushTag("table", 0);
//	
//	numberOfTags = mXml.getNumTags("record");
//	
//	if (_count == -1) {
//		_count = numberOfTags;
//	}
//	else {
//	}
//	
//	int _itemsToLoad = 0;
//	if (numberOfTags == 0 ) { return false; }
//	
//	if (_start >= numberOfTags) { return false; }
//	
//	if ((_start + _count) >= numberOfTags)
//	{ 
//		_itemsToLoad = numberOfTags - _start; 
//	}
//	else {
//		_itemsToLoad = _count;
//	}
//	
//	
//	for (int i = _start; i < _start + _itemsToLoad; i++)
//	{
//		mXml.pushTag("record", i + _start);
//		
//		// load 
//		
//		wbcDynamicElement* tempElement = new wbcDynamicElement();
//		tempElement->elementData = new wbcDataDescription();
//		tempElement->title = mXml.getValue("dataset","");
//		tempElement->elementData->loadFromBrainMaps(tempElement->title);
//		tempElement->elementData->bmDirectory = mXml.getValue("dirname", "");		
//		
//		string thumbFileName = tempElement->title + "_0-0-0.jpg";
//		
//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		NSString *temporaryDirectory = [paths objectAtIndex:0];
//		NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
//		
//		bool shouldAddItem = false;
//		
//		if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
//		{
//			printf("Thumbnail exists, loading.\n");
//			tempElement->baseImage.loadImage([path UTF8String]);
//			shouldAddItem = true;
//			
//		}
//		else
//		{
//			if([ ofxiPhoneGetGLView() reachable])
//			{
//				tempElement->imageURL = tempElement->elementData->mURL + tempElement->elementData->bmDirectory + mXml.getValue("thumb_url", "");
//				printf("Thumb url: %s\n", tempElement->imageURL.c_str());
//
//				if(	tempElement->baseImage.loadFromUrl(tempElement->imageURL))
//				{
//					tempElement->baseImage.saveImage([path UTF8String]);
//					shouldAddItem = true;
//				}
//			}
//			else {
//				// file does not exist and network is unreachable... sorry not loading this today.
//			}
//			
//		}
//		
//		
//		if(shouldAddItem)
//		{
//			tempElement->setSize(mGrid.getSize());
//			tempElement->sharedFont = &mGlobals->mParamFont;
//			tempElement->disableAllEvents();
//			tempElement->enableTouchEvents();
//			tempElement->mGlobals = mGlobals;
//			
//			tempElement->parameterID = i;
//			tempElement->enabled = true;
//			tempElement->elementData->loadFromBrainMaps(tempElement->title);
//			tempElement->elementData->bmID = mXml.getValue("Id", 0);
//			tempElement->elementData->bmOrganSpecies = mXml.getValue("species", "");
//			tempElement->elementData->bmStain = mXml.getValue("stain", "");
//			tempElement->elementData->bmMethod = mXml.getValue("method", "");
//			tempElement->elementData->bmPlane = mXml.getValue("plane", "");
//			tempElement->elementData->bmArea = mXml.getValue("area", "");
//			tempElement->elementData->bmSource = mXml.getValue("source", "");
//			tempElement->elementData->bmSlides = mXml.getValue("slides", 0);
//			tempElement->elementData->bmDateAdded = mXml.getValue("date_added", "");
//			tempElement->elementData->bmResolution = mXml.getValue("res", 0.0f);
//			tempElement->elementData->bmThickness = mXml.getValue("thick", 0.0f);
//			tempElement->elementData->bmDirectory = mXml.getValue("dirname", "");
//			
//			tempElement->elementData->mAttribution = mXml.getValue("source", "");
//			tempElement->elementData->mSpecies = mXml.getValue("species", "");
//			tempElement->elementData->mSite = "Brainmaps.org";
//			tempElement->elementData->mDisplayName = tempElement->title;
//			
//			mItems.push_back(tempElement);		
//		}
//		else {
//			
//			printf("no network or cache found, not loading\n");
//			
//			// clear the allocated components
//			delete tempElement->elementData;			
//			delete tempElement;
//			tempElement = NULL; //probably redundant
//			
//		}
//		
//		mXml.popTag();
//	}
//	
//	mXml.popTag();
//	mXmlDone = true;
//	int toc = ofGetElapsedTimeMillis() - tic;
//	
////	printf("[WBC] Successfully parsed %d datasets from Brainmaps.org local xml in %d ms.\n", (int)brainmapsList.size(), toc);
//	
//	return true;
//}
//
//
//
//


















//
//bool wbcMenu::loadLocalSites(bool _withNetwork)
//{
//	// read xml file
//	// loop through, adding files as needed
//	
//	int tic = ofGetElapsedTimeMillis();
//	
//	mXmlFile			= "localData.xml";
//	if(!mXmlDone)
//	{
//		return false;
//	}
//	
////	printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
//	
//	if(!mXml.loadFile(mXmlFile))
//	{
//	//	printf("[WBC - XML] XML Error in load\n");
//		return false;
//	}
//	
//	
//	int	numberOfTags = mXml.getNumTags("site");	
//	if (numberOfTags == 0 ) { return false; }
//	
//	mXmlDone = false;
//	
//	for (int i = 0; i < numberOfTags; i++)
//	{
//		mXml.pushTag("site", i);
//		
//		//		printf("site %d\n", i);
//		
//		wbcDynamicElement* tempElement = new wbcDynamicElement();
//		tempElement->elementData = new wbcDataDescription();
//		
//		tempElement->title = mXml.getValue("title","");
//		tempElement->setSize(mGrid.getSize());
//		tempElement->sharedFont = &mGlobals->mParamFont;
//		tempElement->disableAllEvents();
//		tempElement->enableTouchEvents();
//		tempElement->mGlobals = mGlobals;
//		//		tempElement->parameterID = mXml.getValue("parameterID",0);
//		tempElement->parameterID = i;
//		tempElement->enabled = true;
//		
//		int tempSiteFormat = mXml.getValue("siteFormat", 0);
//		
//		if (tempSiteFormat == 0) {
//			
//			tempElement->elementData->loadFromZoomifyURL(mXml.getAttribute("url", "address", ""));
//			tempElement->websiteURL = mXml.getAttribute("websiteURL", "address","");
//			
//			tempElement->elementData->mSite = mXml.getValue("site", "");
//			tempElement->elementData->mAttribution = mXml.getValue("attribution", "");
//			tempElement->elementData->mSpecies = mXml.getValue("species","");
//			
//			string thumbFileName = mXml.getValue("localThumbnail", "");
//	//		printf("thumbnail name: %s\n", thumbFileName.c_str());
//			
//			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//			NSString *temporaryDirectory = [paths objectAtIndex:0];
//			NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
//			
//			if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
//			{
//				tempElement->baseImage.loadImage([path UTF8String]);
//				
//				//bool loaded = tempElement->baseImage.loadImage(thumbFileName);
//				
//				
//			}
//			else {
//				
//				if(_withNetwork)
//				{
//					string requestURL = mXml.getAttribute("url", "address", "") + "TileGroup0/0-0-0.jpg";
//		//		printf("request url %s\n", requestURL.c_str());
//					tempElement->baseImage.loadFromUrl(requestURL);
//					tempElement->baseImage.saveImage([path UTF8String]);
//				}
//			}
//			
//			
//			
//			int _width		= mXml.getAttribute("IMAGE_PROPERTIES", "WIDTH", 0);
//			int _height		= mXml.getAttribute("IMAGE_PROPERTIES", "HEIGHT", 0);
//			int _tileSize	= mXml.getAttribute("IMAGE_PROPERTIES", "TILESIZE", 0);
//			
//		//	printf("%d %d %d\n", _width, _height, _tileSize);
//			
//			ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
//			tempslide->mWidth_px		= _width;
//			tempslide->mHeight_px		= _height;
//			tempslide->mTileSize_px		= _tileSize;
//			tempslide->mSlidePath		= mXml.getAttribute("url", "address", "");  //directory containing imageproperties.xml
//			tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
//			
//			tempElement->elementData->mSlideList.push_back(tempslide);
//			tempElement->elementData->bHasMetaData = true;
//			tempElement->elementData->mDisplayName = mXml.getValue("displayName", "");
//			
//		}
//		
//		
//		
//		
//		int numTraces = mXml.getNumTags("traces");
//		
//		for(int j = 0; j < numTraces; j++)
//		{
//			mXml.pushTag("traces"); // change relative root to <feed>
//			
//			int numEntries = mXml.getNumTags("trace");
//			
//			MSA::Interpolator3D tempContour;
//			
//			for (int i = 0; i < numEntries; i++) {
//				
//				mXml.pushTag("trace", i);
//				
//				int point_count = mXml.getNumTags("point");
//				
//				//	printf("[WBC] Found %d points to add\n", point_count);
//				
//				for (int j = 0; j < point_count; j++)
//				{
//					ofxVec3f temppoint;
//					temppoint[0] = mXml.getAttribute("point", "x", 0.0, j); 
//					temppoint[1] = mXml.getAttribute("point", "y", 0.0, j);
//					temppoint[2] = mXml.getAttribute("point", "z", 0.0, j);		
//					tempContour.push_back(temppoint);
//					
//				}
//				
//				mXml.popTag();
//			}
//			
//			tempElement->elementData->mTraceList.push_back(tempContour);
//			
//			//		printf("[WBC] loaded entry to contourlist %d\n", (int)tempElement->elementData->mTraceList.size());
//			
//			mXml.popTag(); 
//		}
//		
//		
//		
//		mItems.push_back(tempElement);
//		
//		
//		mXml.popTag();
//	}
//	
//	mXmlDone = true;
//	
//	int toc = ofGetElapsedTimeMillis() - tic;
//	
////	printf("[WBC - XML] Successfully parsed %d zoomify URLS from local xml in %d ms\n", (int)mItems.size(), toc);
//	
//	return true;
//}

bool wbcMenu::loadZebraFish(int _count)
{
	int tic		= ofGetElapsedTimeMillis();
	mXmlFile	= "zebrafish.xml";
	if(!mXmlDone)
	{ return false; }
	
	//	printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
	
	if(!mXml.loadFile(mXmlFile))
	{
		//		printf("[WBC - XML] XML Error in load\n");
		return false;
	}
	
	int	numberOfTags = mXml.getNumTags("site");	
	if (numberOfTags == 0 ) { return false; }
	
	mXmlDone = false;
	
	int totalItemCount = _count + mItems.size();
	for (int i = mItems.size(); i < totalItemCount; i++)	
	{
		mXml.pushTag("site", i);
		
		wbcDynamicElement* tempElement = new wbcDynamicElement();
		tempElement->elementData = new wbcDataDescription();
		
		tempElement->title = mXml.getValue("title","");
		tempElement->setSize(mGrid.getSize());
		tempElement->sharedFont = &mGlobals->mParamFont;
		tempElement->disableAllEvents();
		tempElement->enableTouchEvents();
		tempElement->mGlobals = mGlobals;
		tempElement->parameterID = i;
		tempElement->enabled = true;
		
		int tempSiteFormat = WBC_ZFISH;
		
		if (tempSiteFormat == WBC_ZFISH) {
			
			tempElement->elementData->loadFromZebraFishURL(mXml.getAttribute("url", "address", ""));
			
			string thumbFileName = tempElement->title + ".jpg";
			
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *temporaryDirectory = [paths objectAtIndex:0];
			NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
			
			if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
			{
				tempElement->baseImage.loadImage([path UTF8String]);
			}
			else
			{
				// http://zfatlas.psu.edu/i.php?
				//				http://zfatlas.psu.edu/i.php?s=85&z=5&i=0
				string requestURL = mXml.getAttribute("url", "address", "") + "s=85&z=5&i=0";
				
				printf("request url %s\n", requestURL.c_str());
				tempElement->baseImage.loadFromUrl(requestURL);
				tempElement->baseImage.saveImage([path UTF8String]);
			}
			
			int _width		= mXml.getAttribute("IMAGE_PROPERTIES", "WIDTH", 0);
			int _height		= mXml.getAttribute("IMAGE_PROPERTIES", "HEIGHT", 0);
			int _tileSize	= mXml.getAttribute("IMAGE_PROPERTIES", "TILESIZE", 0);
			
			ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
			tempslide->mWidth_px		= _width;
			tempslide->mHeight_px		= _height;
			tempslide->mTileSize_px		= _tileSize;
			tempslide->mSlidePath		= mXml.getAttribute("url", "address", "");  //directory containing imageproperties.xml
			tempslide->mNumberOfResolutions = 6;
			//tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
			//		printf("%d\n", tempslide->mNumberOfResolutions);
			tempElement->elementData->mSlideList.push_back(tempslide);
			tempElement->elementData->bHasMetaData = true;
			
			[_arrayView insert:path];
			setupItemInArrayView();
		}
		
		mItems.push_back(tempElement);

		
		mXml.popTag();
	}
	mXml.popTag();
	mXmlDone = true;
	
	int toc = ofGetElapsedTimeMillis() - tic;
	
	return true;
	
	
	
}




























bool wbcMenu::loadCCDBZoomifiesFromLocalXML(int _count)
{
	int tic = ofGetElapsedTimeMillis();
	
	mXmlFile			= "CCDB_reconZoomify.xml";
	if(!mXmlDone)
	{
		return false;
	}
	
	printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
	
	if(!mXml.loadFile(mXmlFile))
	{
		printf("[WBC - XML] XML Error in load\n");
		return false;
	}
	
	int numberOfTags = mXml.getNumTags("zoomifylist");
	
	if (numberOfTags != 1) { return false; }
	
	mXmlDone = false;
	mXml.pushTag("zoomifylist", 0);
	
	numberOfTags = mXml.getNumTags("zoomifyItem");
	
	//printf("[WBC - XML] Found %d zoomifylist tags\n",  numberOfTags);
	
	if (_count == -1) {
		//	printf("loading all ccdb sites!\n");
		_count = numberOfTags;
	}
	else {
		//	printf("only loading %d ccdb sites\n", _count);
	}
	
	int totalItemCount = _count + mItems.size();
	for (int i = mItems.size(); i < totalItemCount; i++)		
	{
		mXml.pushTag("zoomifyItem", i);
		
		wbcDynamicElement* tempElement = new wbcDynamicElement();
		tempElement->elementData = new wbcDataDescription();
		
		tempElement->title = mXml.getValue("dataname","");
		tempElement->setSize(mGrid.getSize());
		tempElement->sharedFont = &mGlobals->mParamFont;
		tempElement->disableAllEvents();
		tempElement->enableTouchEvents();
		tempElement->mGlobals = mGlobals;
		tempElement->parameterID = i;
		tempElement->enabled = true;
		
		int tempSiteFormat = WBC_CCDB;
		
		if (tempSiteFormat == WBC_CCDB) {
			
			tempElement->elementData->loadFromCCDB(mXml.getValue("url", "") + tempElement->title);
			
			string thumbFileName = tempElement->title + "_0-0-0.jpg";
			
			//		printf("thumbnail name: %s\n", thumbFileName.c_str());
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *temporaryDirectory = [paths objectAtIndex:0];
			NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
			
			if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
			{
				tempElement->baseImage.loadImage([path UTF8String]);
				//bool loaded = tempElement->baseImage.loadImage(thumbFileName);
			}
			else
			{
				string requestURL = mXml.getValue("url", "") + tempElement->title + "/TileGroup0/0-0-0.jpg";
				printf("request url %s\n", requestURL.c_str());
				tempElement->baseImage.loadFromUrl(requestURL);
				tempElement->baseImage.saveImage([path UTF8String]);
			}
			
			[_arrayView insert:path];
			setupItemInArrayView();
		}
		
		mItems.push_back(tempElement);
		
		mXml.popTag();
	}
	mXml.popTag();
	mXmlDone = true;
	
	//int toc = ofGetElapsedTimeMillis() - tic;
	
	return true;
}







bool wbcMenu::loadCCDBZoomifiesFromLocalXML(int _startIndex, int _count)
{
	int tic = ofGetElapsedTimeMillis();
	
	mXmlFile			= "CCDB_reconZoomify.xml";
	if(!mXmlDone)
	{
		return false;
	}
	
	printf("[WBC - XML] Reading %s\n", mXmlFile.c_str());
	
	if(!mXml.loadFile(mXmlFile))
	{
		printf("[WBC - XML] XML Error in load\n");
		return false;
	}
	
	int numberOfTags = mXml.getNumTags("zoomifylist");
	
	if (numberOfTags != 1) { return false; }
	
	mXmlDone = false;
	mXml.pushTag("zoomifylist", 0);
	
	numberOfTags = mXml.getNumTags("zoomifyItem");
	
	if (_count == -1) {
		_count = numberOfTags;
	}
	else {
	}
	
	int totalItemCount = _count + mItems.size();
	for (int i = mItems.size(); i < totalItemCount; i++)		
	{
		mXml.pushTag("zoomifyItem", i + _startIndex);
		
		wbcDynamicElement* tempElement = new wbcDynamicElement();
		tempElement->elementData = new wbcDataDescription();
		
		tempElement->title = mXml.getValue("dataname","");
		tempElement->setSize(mGrid.getSize());
		tempElement->sharedFont = &mGlobals->mParamFont;
		tempElement->disableAllEvents();
		tempElement->enableTouchEvents();
		tempElement->mGlobals = mGlobals;
		tempElement->parameterID = i;
		tempElement->enabled = true;
		
		int tempSiteFormat = WBC_CCDB;
			
		if (tempSiteFormat == WBC_CCDB) {
			
			tempElement->elementData->loadFromCCDB(mXml.getValue("url", "") + tempElement->title);
			
			string thumbFileName = tempElement->title + "_0-0-0.jpg";
			//		printf("thumbnail name: %s\n", thumbFileName.c_str());
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *temporaryDirectory = [paths objectAtIndex:0];
			NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
			
			if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
			{
				tempElement->baseImage.loadImage([path UTF8String]);
				//bool loaded = tempElement->baseImage.loadImage(thumbFileName);
			}
			else
			{
				string requestURL = mXml.getValue("url", "") + tempElement->title + "/TileGroup0/0-0-0.jpg";
				//			printf("request url %s\n", requestURL.c_str());
				tempElement->baseImage.loadFromUrl(requestURL);
				tempElement->baseImage.saveImage([path UTF8String]);
			}
			
			[_arrayView insert:path];
			setupItemInArrayView();
		}
		
		mItems.push_back(tempElement);
		
		mXml.popTag();
	}
	mXml.popTag();
	mXmlDone = true;
	
	//	int toc = ofGetElapsedTimeMillis() - tic;
	
	return true;
}




//	int tic = ofGetElapsedTimeMillis();
//	mXmlFile			= "brainmaps-pretty.xml";
//	if(!mXmlDone) {return false;}
//	
////	printf("[WBC] Reading %s\n", mXmlFile.c_str());
//	
//	if(!mXml.loadFile(mXmlFile))
//	{
//		printf("[WBC] XML Error in load\n");
//		return false;
//	}
//	
//	int numberOfTags = mXml.getNumTags("table");	
//	if (numberOfTags != 1) { return false; }
//	
//	mXmlDone = false;
//	mXml.pushTag("table", 0);
//	
//	numberOfTags = mXml.getNumTags("record");
//	
////	printf("[WBC] Found %d datasets from the Brainmaps list\n",  numberOfTags);
//	
//	if (_count == -1) {
////		printf("loading all brain maps sites!\n");
//		_count = numberOfTags;
//	}
//	else {
////		printf("only loading %d brain maps sites\n", _count);
//	}
//	
//	
//	
//	
//	for (int i = 0; i < _count; i++)
//	{
//		mXml.pushTag("record", i);
//		
//		wbcDynamicElement* tempElement = new wbcDynamicElement();
//		tempElement->elementData = new wbcDataDescription();
//		
//		tempElement->title = mXml.getValue("dataset","");
//		
//		
//	//	printf("%s\n", tempElement->title.c_str());
//		
//		tempElement->setSize(mGrid.getSize());
//		tempElement->sharedFont = &mGlobals->mParamFont;
//		tempElement->disableAllEvents();
//		tempElement->enableTouchEvents();
//		tempElement->mGlobals = mGlobals;
//		
//		tempElement->parameterID = i+100;
//		tempElement->enabled = true;
//		
//		int tempSiteFormat = WBC_BRAINMAPS; //brain maps
//		
//		if (tempSiteFormat == WBC_BRAINMAPS) {
//			// eventually combine all xml loading into 1			
//			tempElement->elementData->loadFromBrainMaps(tempElement->title);
//			tempElement->elementData->bmID = mXml.getValue("Id", 0);
//			tempElement->elementData->bmOrganSpecies = mXml.getValue("species", "");
//			tempElement->elementData->bmStain = mXml.getValue("stain", "");
//			tempElement->elementData->bmMethod = mXml.getValue("method", "");
//			tempElement->elementData->bmPlane = mXml.getValue("plane", "");
//			tempElement->elementData->bmArea = mXml.getValue("area", "");
//			tempElement->elementData->bmSource = mXml.getValue("source", "");
//			tempElement->elementData->bmSlides = mXml.getValue("slides", 0);
//			tempElement->elementData->bmDateAdded = mXml.getValue("date_added", "");
//			tempElement->elementData->bmResolution = mXml.getValue("res", 0.0f);
//			tempElement->elementData->bmThickness = mXml.getValue("thick", 0.0f);
//			tempElement->elementData->bmDirectory = mXml.getValue("dirname", "");
//			
//			tempElement->elementData->mAttribution = mXml.getValue("source", "");
//			tempElement->elementData->mSpecies = mXml.getValue("species", "");
//			tempElement->elementData->mSite = "Brainmaps.org";
//			tempElement->elementData->mDisplayName = tempElement->title;
//			
//			
//			//g12a/TileGroup0/0-0-0.jpg
//			
//			//			string thumbFileName = mXml.getValue("localThumbnail", "");			
//			
//			string thumbFileName = tempElement->title + "_0-0-0.jpg";
//			
//			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//			NSString *temporaryDirectory = [paths objectAtIndex:0];
//			NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:thumbFileName.c_str()]];
//			
//			if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
//			{
//				tempElement->baseImage.loadImage([path UTF8String]);
//				
//				//bool loaded = tempElement->baseImage.loadImage(thumbFileName);
//			}
//			else
//			{
//				string requestURL = tempElement->elementData->mURL + tempElement->elementData->bmDirectory + mXml.getValue("thumb_url", "");
//				
////				printf("request url %s\n", requestURL.c_str());
//				tempElement->baseImage.loadFromUrl(requestURL);
//				tempElement->baseImage.saveImage([path UTF8String]);
//			}
//			
//		}
//		
//		mItems.push_back(tempElement);		
//		
//		
//		mXml.popTag();
//	}
//	
//	mXml.popTag();
//	mXmlDone = true;
////	int toc = ofGetElapsedTimeMillis() - tic;
//	//	printf("[WBC] Successfully parsed %d datasets from Brainmaps.org local xml in %d ms.\n", (int)brainmapsList.size(), toc);
//	return true;
//}




void wbcMenu::transitionTo(wbcScene _sceneMode)
{
	switch (_sceneMode) {
			
		case WBC_Scene_Menu:
			
			[_arrayView hide:NO];
			[_arrayView interact:YES];
			
			for (int i = 0; i < mItems.size(); i++) {
				wbcDynamicElement* tempObject = mItems.at(i);
				
				tempObject->enabled = true;
				tempObject->enableTouchEvents();
				tempObject->animateXYandScale(ofxPoint2f(mDescriptionPosition.x-200, mDescriptionPosition.y), 
																			mDescriptionSize, 1.0, 0);
				//tempObject->animateXYandScale(mGrid.getPositionForIndex(i), mGrid.getSize(), 0.11, 0);
				
			}
			break;
			
			
		case WBC_Scene_Description:
			[_arrayView hide:NO];
			[_arrayView interact:NO];
			
			for (int i = 0; i < mItems.size(); i++) {
				
				wbcDynamicElement* tempObject = mItems.at(i);
				
				if (tempObject->bIsSelected) {
					
					tempObject->elementData->populate(); // calls appropriate method to request data
					//tempObject->setPosition(mDescriptionPosition.x, mDescriptionPosition.y);
					//tempObject->setSize(mDescriptionSize.x, mDescriptionSize.y);
					tempObject->animateXYandScale(mDescriptionPosition, mDescriptionSize, 0.11, 0);
					tempObject->enabled = true;
				}
			}
			
			break;
			
		case WBC_Scene_Detail:
			[_arrayView hide:YES];
			[_arrayView interact:NO];
			
			for (int i = 0; i < mItems.size(); i++) {
				wbcDynamicElement* tempObject = mItems.at(i);
				
				if (tempObject->bIsSelected) {
					tempObject->animateXYandScale(mDetailPosition, mDetailSize, 0.08, 0);
					tempObject->animateFullView(0.11, 0);
				}
				else {
					tempObject->enabled = false;
					tempObject->disableTouchEvents();
					
				}
			}
			
			
			break;
			
			
		default:
			break;
	}
}

bool wbcMenu::bHasAnimations()
{
	bool _selectedItemAnimateStatus = (getSelectedItem()->bNeedsAnimateXY || getSelectedItem()->bNeedsAnimateColor || getSelectedItem()->bNeedsAnimateScale);
	return _selectedItemAnimateStatus;	
}

wbcDynamicElement*	wbcMenu::getSelectedItem()
{
	// this ensures that the selected object is drawn over top of the background objects
	for (int i = 0; i < mItems.size(); i++) {
		
		wbcDynamicElement* tempObject = mItems.at(i);
		if (tempObject->bIsSelected) {
			//printf("selected object index:%d", i);
			
			return tempObject;
			
		}
	}
	
	return NULL;
}

void wbcMenu::setupItemInArrayView()
{
	DemoItemView* temp = (DemoItemView*)[_arrayView viewItemInArrayViewAtIndex:(_arrayView.itemCount-1)];
	temp.Menu = this;
	temp.Globals = mGlobals;
}

#pragma mark -
#pragma mark Drawing

void wbcMenu::set2D()
{
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



void wbcMenu::drawBaseMenu()
{
	set2D();
	
	if (ofGetWidth() == 1024) {
		
		ofBackground(0, 0, 0);
		
		ofSetColor(255,255,255,255);
		ofFill();
		ofRect(10.0f, 35.0f, ofGetWidth()-20, 4.0f);		
		
		ofSetColor(0xFFFFFF);
		mGlobals->mHeadFont.drawString("Whole Brain Catalog Mobile", 10, 20);
		
		for (int i = 0; i < mItems.size(); i++) {
			
			wbcDynamicElement* tempObject = mItems.at(i);
			if (tempObject->enabled && !tempObject->bIsSelected) {
				
				//tempObject->update();
				//tempObject->draw();
				
			}
		}

		// do ipad
		ofSetColor(0, 200, 0, 255);
		mGlobals->mHeadFont.drawString("Double tap to select", 50, 70);
		ofSetColor(0xFFFFFF);
		
		wbcDynamicElement* tempObject = getSelectedItem();
		if (tempObject) {
			//tempObject->draw();			
		}
	}
	
	else 
	{		
		ofBackground(0, 0, 0);
		
		ofSetColor(0x222222);
		ofRect(mGrid.mPosition[0], mGrid.mPosition[1], mGrid.mSize[0], mGrid.mSize[1]);
		
		ofSetColor(0xFFFFFF);
		mGlobals->mHeadFont.drawString("Whole Brain Catalog Mobile", 10, 20);
		
		
		for (int i = 0; i < mItems.size(); i++) {
			
			wbcDynamicElement* tempObject = mItems.at(i);
			if (tempObject->enabled && !tempObject->bIsSelected) {
				
				//tempObject->update();
				//tempObject->draw();
				
			}
		}
		
		ofSetColor(0xFFFFFF);
		mGlobals->mParamFont.drawString("Double tap to select", 330, 300);
		
		ofSetColor(0xFFFFFF);
		
		wbcDynamicElement* tempObject = getSelectedItem();
		if (tempObject) {
			//tempObject->draw();			
		}
	}
}

void wbcMenu::drawDetailMenu()
{
	//	set2D();
	
	if (ofGetWidth() == 1024) {
		
		ofBackground(0, 0, 0);
		
		ofSetColor(0xFFFFFF);
		mGlobals->mHeadFont.drawString("Whole Brain Catalog Mobile", 10, 20);
		
		ofSetColor(255,255,255,255);
		
		mGlobals->mParamFont.drawString("Double tap to view detail\n\nTap outside to go back", 30, 675);
		
		
		ofFill();
		ofRect(10.0f, 35.0f, ofGetWidth()-20, 4.0f);		
		
		for (int i = 0; i < mItems.size(); i++) {
			wbcDynamicElement* tempObject = mItems.at(i);
			if (tempObject->enabled && !tempObject->bIsSelected) {
				//tempObject->draw();
			}
		}
		
		ofSetColor(0xFFFFFF);
		wbcDynamicElement* tempObject = getSelectedItem();
		if (tempObject) {
			
			tempObject->draw();
			
			if (tempObject->elementData->bHasMetaData && tempObject->bIsSelected)
			{			
				//	int strOffset = 0;
				
				switch (tempObject->elementData->mTileFormat) {
					case WBC_ZOOMIFY:
					case WBC_CCDB:
					case WBC_BRAINMAPS:
						
						mGlobals->mHeadFont.drawString(tempObject->elementData->mDisplayName, 30, 440);
						
						
						ofSetColor(0xDDDDDD);
						mGlobals->mParamFont.drawString("Species: " + 
														tempObject->elementData->mSpecies,33, 462 );
						
						// species
						
						mGlobals->mParamFont.drawString("Width: " + 
														ofToString(tempObject->elementData->mSlideList[0]->mWidth_px)
														+"px",33, 484 );
						
						mGlobals->mParamFont.drawString("Height: " + 
														ofToString(tempObject->elementData->mSlideList[0]->mHeight_px)
														+"px",33, 506 );
						
						mGlobals->mParamFont.drawString("Attribution: " + 
														tempObject->elementData->mAttribution,33, 528 );
						
						mGlobals->mParamFont.drawString("Site: " + 
														tempObject->elementData->mSite,33, 550 );
						
						//case WBC_ZOOMIFY:
						//						
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString(tempObject->title, 30, 450);
						//						strOffset++;
						//						
						//						
						//						ofSetColor(0xBBBBBB);
						//
						//						mGlobals->mHeadFont.drawString("Zoomify format", 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Slide count: " + 
						//													   ofToString((int)tempObject->elementData->mSlideList.size())
						//													   , 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset) ;
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Slide resolution (px): " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mWidth_px, 0)
						//													   + " x " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mHeight_px, 0)
						//													   , 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;						
						//		
						//	
						//						
						//						break;
						//					case WBC_BRAINMAPS:
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString(tempObject->title, 30, 450);
						//						strOffset++;
						//						
						//						
						//						ofSetColor(0xBBBBBB);
						//						
						//						mGlobals->mHeadFont.drawString("Species: " + tempObject->elementData->bmOrganSpecies, 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Host: Brainmaps.org", 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Source: " + tempObject->elementData->bmSource, 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Data Added: " + tempObject->elementData->bmDateAdded, 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset+=2;
						//						
						//						
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString("Image Details", 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						ofSetColor(0xBBBBBB);
						//						mGlobals->mHeadFont.drawString("Slide Count: " + 
						//													   ofToString((int)tempObject->elementData->mSlideList.size())
						//													   , 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset) ;
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("First Slide resolution (px): " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mWidth_px, 0)
						//													   + " x " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mHeight_px, 0)
						//													   , 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;			
						//						
						//						mGlobals->mHeadFont.drawString("Slice plane: " + tempObject->elementData->bmPlane, 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Resolution (micron / px): " + ofToString(tempObject->elementData->bmResolution,2), 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Slice Thickness (micron): " + ofToString(tempObject->elementData->bmThickness,2), 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Stain: " + tempObject->elementData->bmStain, 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//
						//						mGlobals->mHeadFont.drawString("Method: " + tempObject->elementData->bmMethod, 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;						
						//						
						//						break;
						//						
						//					case WBC_CCDB:
						//						
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString(tempObject->title, 30, 450);
						//						strOffset++;
						//						
						//						
						//						ofSetColor(0xBBBBBB);
						//						
						//						mGlobals->mHeadFont.drawString("CCDB format", 30, 450+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						
						//						break;
						
						
					default:
						break;
				}
			}
			else {
				ofSetColor(0xFF0000);
				mGlobals->mHeadFont.drawString("Loading metadata. Please wait.", 50, 60);
				ofSetColor(0xFFFFFF);
				
			}
			
		}		
		
	}
	else {
		
		ofSetColor(0xFFFFFF);
		
		wbcDynamicElement* tempObject = getSelectedItem();
		if (tempObject) {
			
			tempObject->draw();
			
			ofSetColor(0xFFFFFF);
			mGlobals->mParamFont.drawString("Double tap to view detail\n\nTap outside to go back", 300, 275);
			
			if (tempObject->elementData->bHasMetaData && tempObject->bIsSelected)
			{			
				int strOffset = 0;
				
				switch (tempObject->elementData->mTileFormat) {
					case WBC_ZOOMIFY:
					case WBC_CCDB:
					case WBC_BRAINMAPS:
						
						mGlobals->mHeadFont.drawString(tempObject->elementData->mDisplayName, 15, 30);
						
						
						ofSetColor(0xDDDDDD);
						mGlobals->mParamFont.drawString("Species: " + 
														tempObject->elementData->mSpecies,17, 52 );
						
						// species
						
						mGlobals->mParamFont.drawString("Width: " + 
														ofToString(tempObject->elementData->mSlideList[0]->mWidth_px)
														+"px",17, 74 );
						
						mGlobals->mParamFont.drawString("Height: " + 
														ofToString(tempObject->elementData->mSlideList[0]->mHeight_px)
														+"px",17, 96 );
						
						mGlobals->mParamFont.drawString("Attribution: " + 
														tempObject->elementData->mAttribution,17, 118 );
						
						mGlobals->mParamFont.drawString("Site: " + 
														tempObject->elementData->mSite,17, 140 );
						
						
						// attribution
						// site
						
						
						
						//						
						//						ofSetColor(0xFFFFFF);
						//						strOffset++;
						//						
						//						ofSetColor(0xBBBBBB);
						//						
						//						
						//						
						//						mGlobals->mHeadFont.drawString("Zoomify format", 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Slide count: " + 
						//													   ofToString((int)tempObject->elementData->mSlideList.size())
						//													   , 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset) ;
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Slide resolution (px): " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mWidth_px, 0)
						//													   + " x " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mHeight_px, 0)
						//													   , 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						break;
						//					case WBC_BRAINMAPS:
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString(tempObject->title, 30, 30);
						//						strOffset++;
						//						
						//						
						//						ofSetColor(0xBBBBBB);
						//						
						//						mGlobals->mHeadFont.drawString("Species: " + tempObject->elementData->bmOrganSpecies, 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Host: Brainmaps.org", 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Source: " + tempObject->elementData->bmSource, 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Data Added: " + tempObject->elementData->bmDateAdded, 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset+=2;
						//						
						//						
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString("Image Details", 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						ofSetColor(0xBBBBBB);
						//						mGlobals->mHeadFont.drawString("Slide Count: " + 
						//													   ofToString((int)tempObject->elementData->mSlideList.size())
						//													   , 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset) ;
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("First Slide resolution (px): " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mWidth_px, 0)
						//													   + " x " + 
						//													   ofToString(tempObject->elementData->mSlideList[0]->mHeight_px, 0)
						//													   , 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;			
						//						
						//						mGlobals->mHeadFont.drawString("Slice plane: " + tempObject->elementData->bmPlane, 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Resolution (micron / px): " + ofToString(tempObject->elementData->bmResolution,2), 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Slice Thickness (micron): " + ofToString(tempObject->elementData->bmThickness,2), 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Stain: " + tempObject->elementData->bmStain, 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						mGlobals->mHeadFont.drawString("Method: " + tempObject->elementData->bmMethod, 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;						
						//						
						//						break;
						//						
						//					case WBC_CCDB:
						//						
						//						ofSetColor(0xFFFFFF);
						//						mGlobals->mHeadFont.drawString(tempObject->title, 30, 30);
						//						strOffset++;
						//						
						//						
						//						ofSetColor(0xBBBBBB);
						//						
						//						mGlobals->mHeadFont.drawString("CCDB format", 30, 30+mGlobals->mHeadFont.getLineHeight()*strOffset);
						//						strOffset++;
						//						
						//						
						//						break;
						
						
					default:
						break;
				}
				
			}
			else {
				
				// loading meta data
				
				ofSetColor(0xFF0000);
				mGlobals->mHeadFont.drawString("Loading metadata. Please wait.", 15, 30);
				
			}
			
		}	
		
	}
	
}

#pragma mark -
#pragma mark Interfaces

void wbcMenu::scaleGrid(float _scale)
{
	mGrid.adjustScale(_scale);
	
	for (int i = 0; i < mItems.size(); i++) {
		wbcDynamicElement* tempObject = mItems.at(i);
		tempObject->animateXYandScale(mGrid.getPositionForIndex(i), mGrid.getSize(), 1, 0);
	}
}


#pragma mark -
#pragma mark Network handler

//void ofxWBCexchange::newResponse(ofxHttpResponse &response) {	

void wbcMenu::newResponse(ofxHttpResponse &response) 
{
#pragma mark XML
	if (response.contentType.compare("application/xml")==0)
	{
		printf("[WBC] application/xml mime filetype received\n");
		
		requestParser.loadFromBuffer(response.responseBody);
		int i_count = requestParser.getNumTags("IMAGE_PROPERTIES");
		int t_count = requestParser.getNumTags("traces");
		int bm_count = requestParser.getNumTags("table");
		
		//printf("[WBC] XML parse. i: %d t: %d bm: %d\n", i_count, t_count, bm_count);
		
		if (i_count >= 1) {
			printf("[WBC ZOOMIFY] Returned an imageproperties.xml\n");
			
			int _width		= requestParser.getAttribute("IMAGE_PROPERTIES", "WIDTH", 0);
			int _height		= requestParser.getAttribute("IMAGE_PROPERTIES", "HEIGHT", 0);
			int _tileSize	= requestParser.getAttribute("IMAGE_PROPERTIES", "TILESIZE", 0);
			
			wbcDynamicElement* tempObject = getSelectedItem();
			
			size_t loc1 = response.url.find(tempObject->elementData->mDataName);
			
			if (loc1 != string::npos)
			{	
				//		printf("[WBC ZOOMIFY] Found %s, updating with image details\n", tempObject->elementData->mDataName.c_str());
				
				//<IMAGE_PROPERTIES WIDTH="1440" HEIGHT="1782" NUMTILES="59" NUMIMAGES="1" VERSION="1.8" TILESIZE="256" />
				
				ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
				tempslide->mWidth_px		= _width;
				tempslide->mHeight_px		= _height;
				tempslide->mTileSize_px		= _tileSize;
				tempslide->mSlidePath		= response.url.substr(0, response.url.length() - 19);  //directory containing imageproperties.xml
				
				tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
				tempObject->elementData->mSlideList.push_back(tempslide);
				tempObject->elementData->bHasMetaData = true;
			}
		}
	}
	else if (response.contentType.compare("text/html")==0)
	{	
#pragma mark slide list
		printf("[WBC] text/html mime filetype received\n");		
		
		// figure out what type of file we downloaded:
		size_t loc1 = response.url.find("getslides2");
		
		if (loc1 != string::npos)
		{
			//		printf("[WBC] Downloaded brain-maps.org dataset list.\n");
			
			string delim = "\n";
			string str = response.responseBody;
			str = str.erase(0, 5);
			
			vector<string> tokens;
			
			size_t p0 = 0, p1 = string::npos;
			while(p0 != string::npos)
			{
				p1 = str.find_first_of(delim, p0);
				if(p1 != p0)
				{
					string token = str.substr(p0, p1 - p0);
					tokens.push_back(token);
				}
				p0 = str.find_first_not_of(delim, p1);
			}
			
			//			printf("[WBC] %d slides\n", (int)tokens.size());
			
			for (int i = 0; i < tokens.size(); i++)
			{
				str = tokens[i];
				
				vector<string> parts;
				delim = " ";
				size_t p0 = 0, p1 = string::npos;
				while(p0 != string::npos)
				{
					p1 = str.find_first_of(delim, p0);
					if(p1 != p0)
					{
						string token = str.substr(p0, p1 - p0);
						parts.push_back(token);
					}
					p0 = str.find_first_not_of(delim, p1);
				}
				
				if (getSelectedItem() != NULL) {
					
					ofxWBCSlideDescription* tempslide = new ofxWBCSlideDescription();
					tempslide->mSlideID			= ( parts[0] );
					tempslide->mWidth_px		= ofToInt( parts[2] );
					tempslide->mHeight_px		= ofToInt( parts[3] );
					tempslide->mTileSize_px		= 256;
					
					
					tempslide->mSlidePath		= getSelectedItem()->elementData->mURL + parts[1];
					//			printf("slide path: %s\n", tempslide->mSlidePath.c_str());
					
					tempslide->mNumberOfResolutions = 1+ceil(log(ceil((double)(max(tempslide->mWidth_px,tempslide->mHeight_px)/tempslide->mTileSize_px)))/log(2.0));
					
					try {
						getSelectedItem()->elementData->mSlideList.push_back(tempslide);
						getSelectedItem()->elementData->bHasMetaData = true;
					}
					catch (exception &e) {
						//
					}
					
					//
					//					if(getSelectedItem()->elementData->mSlideList. != NULL)
					//					{
					//											}
					//					else {
					//						free(tempslide);
					//					}
					
				}
			}
		}	
	}	
	else if (response.contentType.compare("image/jpeg")==0)
	{	
		printf("response url %s\n", response.url.c_str());		
		
		for (int i = 0; i < mItems.size(); i++) {
			
			//printf("image url %s\n", mItems[i]->imageURL.c_str());
			//			response.url.find(mItems[i]->imageURL);
			size_t loc1 = mItems[i]->imageURL.find(response.url);
			
			if (loc1 != string::npos)
			{	
				printf("found at %d\n", i);
				
				string tempfilename = mItems[i]->elementData->mDataName;
				size_t found;
				found = tempfilename.find(".");
				if (found !=string::npos) {
					tempfilename.erase(found);
				}
				
				string mHibernateFilename = tempfilename + "_thumb.jpg";
				
				printf("tempfilename: %s\n", mHibernateFilename.c_str());
				
				// set autorelease pool
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
				NSError* error;
				
				// save image, the right way
				downloadedBuffer = [NSData dataWithBytes:response.responseBody.data() length:response.responseBody.length()];
				paths = [NSArray arrayWithArray:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)];
				temporaryDirectory = [NSString stringWithString:[paths objectAtIndex:0]];
				path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:mHibernateFilename.c_str()]];
				
				NSLog(@"%@\n", path);
				
				[downloadedBuffer writeToFile:path options:NSAtomicWrite error:&error];
				
				
				
				if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) 
				{
					//mItems[i]->baseImage.loadFromFileIPHONE([path UTF8String]);
					mItems[i]->baseImage.update();
					mItems[i]->baseImage.containsData = true;
					
				}
				
				[pool release];
				
				
				
			}
		}
	}
	else 
	{	
		
		printf("%s\n", response.contentType.c_str());
	}
	
	
}







