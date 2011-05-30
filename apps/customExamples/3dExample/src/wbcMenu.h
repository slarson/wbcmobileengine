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

#ifndef WBC_MENU
#define WBC_MENU

#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxWBCglobals.h"
#include "ofxGuiGlobals.h"

#include "wbcDynamicElement.h"
#include "wbcGridLayout.h"
#include "ATArrayView.h"

class wbcMenu : public ofxHttpEventListener
{
	
public:
	
	wbcMenu();
	void	update();
	
	
	// http listener
	void newResponse(ofxHttpResponse &response);
	
	string						mXmlFile;
	ofxXmlSettings				mXml;
	ofxXmlSettings				requestParser;
	ofxDirList					mDir;
	bool						mXmlDone;
	
	
	bool				bIsLoaded;
	bool				bHasAnimations();
	
	void				linkToGui(ofxGuiGlobals* _ptr);
	void				loadResources(ofxGuiGlobals* _ptr);
	void				transitionTo(wbcScene _sceneMode);
	wbcDynamicElement*	getSelectedItem();
	
	bool				loadCustomSitesIfPresent(bool _withNetwork);
	bool				loadLocalSites(bool _withNetwork);
	bool				loadLocalSites(bool _withNetwork, int _start, int _count);
	
	bool				loadZebraFish(int _count);
	
	bool				loadCCDBZoomifiesFromLocalXML(int _count);
	bool				loadCCDBZoomifiesFromLocalXML(int _startIndex, int _count);
	
	bool				loadBrainMapsFromLocalXML(int _count);
	bool				loadBrainMapsFromLocalXML(int _startIndex, int _count);
	
	int				mBMstartindex;
	int				mBMcount;
	
	
	void			set2D();
	void			drawBaseMenu();
	void			drawDetailMenu();
	void			disableAllElements();
	void			enableAllElements();
	
	void			setupItemInArrayView();
	
	
	void			scaleGrid(float _scale);
	
	ATArrayView* _arrayView;
	
	ofImage			headerImg;
	ofTrueTypeFont	fHelvetica;
	
	ofxGuiGlobals*	mGlobals; // 
	wbcGridLayout	mGrid;
	
	vector<wbcDataDescription*> elementDatasets;
	
	vector<wbcDynamicElement*>	mItems;
	
	ofxPoint2f		mDetailPosition;
	ofxPoint2f		mDetailSize;
	
	ofxPoint2f		mDescriptionPosition;
	ofxPoint2f		mDescriptionSize;
	
	//	UIWebView*		descriptionView;
	//	bool			bWebEnabled;
	
	// downloading needs
	NSError		*	error;
	NSData		*	downloadedBuffer; //= [[NSData dataWithBytes:response.responseBody.data() length:response.responseBody.length()] retain];
	NSArray		*	paths;  //[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) retain];
	NSString	*	temporaryDirectory; // = [[paths objectAtIndex:0] retain];
	NSString	*	path; //	= [[temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:tilePtr->mHibernateFilename.c_str()]] retain];
	//	
};

#endif