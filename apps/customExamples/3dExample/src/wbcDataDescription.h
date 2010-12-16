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


// A universal data description
// this will contain methods for every tile type
// load from, calculate, etc

#ifndef WBC_DATA_DESCRIPTION
#define WBC_DATA_DESCRIPTION

#include "ofxWBCglobals.h"

class wbcDataDescription {
	
public:
	
	wbcDataDescription();
	
	bool							bHasMetaData;	// slide info, etc
	
	string							mDataName;		// data id
	string							mDisplayName;	// what to display 
	string							mURL;			// server base url ( eg http://brainmaps.org)
	ofxVec3f						mSize;			// x/y/z bounding box for entire dataset

	string	mAttribution;
	string	mSite;
	string  mSpecies;
	
	
	vector<ofxWBCSlideDescription*>	mSlideList;		// collection of slides: each needs data equiv. to imageproperties.xml
	vector<MSA::Interpolator3D>	mTraceList;		// collection of traces: each holds an array of points
	
	wbcTileFormat					mTileFormat;	// defined in globals (e.g. zoomify)
	
	void		loadFromZoomifyURL(string _url);
	void		loadFromBrainMaps(string _url);
	void		loadFromCCDB(string _URL);
	void		loadFromZebraFishURL(string _url);

	void		populate(); // no matter which type, populate data from web/local
	
	//Brain maps Specific meta data
	int			bmID;
	string		bmOrganSpecies;
	string		bmStain;
	string		bmMethod;
	string		bmPlane;
	string		bmArea;
	string		bmSource;
	int			bmSlides;
	string		bmDateAdded;
	float		bmResolution;
	float		bmThickness;
	string		bmDirectory;
	
	//
	string	getSourceString();
	
};



#endif 