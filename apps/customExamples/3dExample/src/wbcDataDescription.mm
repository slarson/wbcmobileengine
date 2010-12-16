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

#include "wbcDataDescription.h"

#pragma mark -
#pragma mark Constructors and definitions

wbcDataDescription::wbcDataDescription()
{
	bHasMetaData	= false;
	
	mDataName		= "";
	mDisplayName	= "";
	mAttribution	= "";
	mSpecies		= "";
	mSite			= "";
	
	mURL			= "";
	mSize			= ofxVec3f(0,0,0);
	mTileFormat		= WBC_FORMAT_UNKNOWN;
	
	//brain maps specific meta data
	
	bmOrganSpecies	= "";
	bmStain			= "";
	bmMethod		= "";
	bmPlane			= "";
	bmArea			= "";
	bmSource		= "";
	bmSlides		= 0;
	bmDateAdded		= "";
	bmResolution	= 0.0f;
	bmThickness		= 0.0f;
	bmDirectory		= "";
	bmID			= 0;
}

string wbcDataDescription::getSourceString()
{

	switch (mTileFormat) {
		case WBC_FORMAT_UNKNOWN:
			return "unknown";
			break;
		case WBC_ZOOMIFY:
			return "Generic Zoomify";
			break;
		case WBC_ABA:
			return "Brain-map.org";
			break;
		case WBC_BRAINMAPS:
			return "Brainmaps.org";
			break;
		case WBC_CCDB:
			return "ccdb.ucsd.edu";
			break;
			
		default:
			break;
	}
	
	
}


void wbcDataDescription::populate()
{
	string imagePropertiesURL;
	
	switch (mTileFormat) {
		case WBC_FORMAT_UNKNOWN:
//			printf("No tile type specified, fail\n");
			break;
			
		case WBC_ZOOMIFY:
			if (bHasMetaData) {
//				printf("Data already populated\n");
			}
			else {
				imagePropertiesURL = mURL + mDataName + "/ImageProperties.xml";
//				printf("[MENU NET] Requesting %s\n", imagePropertiesURL.c_str());
				ofxHttpUtil.addUrl(imagePropertiesURL);
			}
			break;
			
		case WBC_ZFISH:
			
			if (bHasMetaData) {
//				printf("Data already populated\n");
			}
			
//			else {
//				imagePropertiesURL = mURL + mDataName + "/ImageProperties.xml";
//				printf("[MENU NET] Requesting %s\n", imagePropertiesURL.c_str());
//				ofxHttpUtil.addUrl(imagePropertiesURL);
//			}
			break;
			
			
		case WBC_BRAINMAPS:
			
			if (bHasMetaData) {
//				printf("Data already populated\n");
			}
			else {
				
//				imagePropertiesURL = mURL + mDataName + "/ImageProperties.xml";
//				printf("[MENU NET] Requesting %s\n", imagePropertiesURL.c_str());
//				ofxHttpUtil.addUrl(imagePropertiesURL);
				
				string slideListURL = "http://brainmaps.org/getslides2.php?datid=" + ofToString(bmID);
//				printf("[WBC] Requesting %s\n", slideListURL.c_str());
				ofxHttpUtil.addUrl(slideListURL);
			}
			break;
			
			
		case WBC_ABA:
//			printf("[WDD]  Populating ABA tileset\n");
			break;
			
		default:
			break;
	}
}
	



#pragma mark -
#pragma mark Zoomify methods

void wbcDataDescription::loadFromZoomifyURL(string _URL)
{
	mTileFormat = WBC_ZOOMIFY;
	
	string delim = "/";
	vector<string> tokens;
	size_t p0 = 0, p1 = string::npos;
	while(p0 != string::npos)
	{
		p1 = _URL.find_first_of(delim, p0);
		if(p1 != p0)
		{
			string token = _URL.substr(p0, p1 - p0);
			tokens.push_back(token);
		}
		p0 = _URL.find_first_not_of(delim, p1);
	}
	
	string serverURL = "http://";
	for(int i = 1; i < tokens.size()-1; i++)
	{	
		serverURL+=tokens[i] + delim;
	}
	
	mDataName		= tokens[tokens.size()-1];
	mURL			= serverURL;
	
//	printf("[WDD]  Server: %s\n       Data name: %s\n", mURL.c_str(), mDataName.c_str());
}


void wbcDataDescription::loadFromCCDB(string _URL)
{
	mTileFormat = WBC_CCDB;
	
	string delim = "/";
	vector<string> tokens;
	size_t p0 = 0, p1 = string::npos;
	while(p0 != string::npos)
	{
		p1 = _URL.find_first_of(delim, p0);
		if(p1 != p0)
		{
			string token = _URL.substr(p0, p1 - p0);
			tokens.push_back(token);
		}
		p0 = _URL.find_first_not_of(delim, p1);
	}
	
	string serverURL = "http://";
	for(int i = 1; i < tokens.size()-1; i++)
	{	
		serverURL+=tokens[i] + delim;
	}
	
	mDataName		= tokens[tokens.size()-1];
	mURL			= serverURL;
	
	
	
//	printf("[WDD]  Server: %s\n       Data name: %s\n", mURL.c_str(), mDataName.c_str());
}

#pragma mark -
#pragma mark Zebra fish



void wbcDataDescription::loadFromZebraFishURL(string _url)
{
//	mDataName = _url;
	mURL      = "http://zfatlas.psu.edu/i.php?";
	
	mTileFormat = WBC_ZFISH;
	
//	printf("[WDD] Zebrafish entry added");

}


#pragma mark -
#pragma mark Brain-Maps methods


void wbcDataDescription::loadFromBrainMaps(string _url)
{
	mDataName = _url;
	mURL = "http://www.brainmaps.org/";
	
	mTileFormat = WBC_BRAINMAPS;

//http://brainmaps.org/HBP2/c.aethiops/AGM1/AGM1-highres/023/ImageProperties.xml

//	printf("[WDD] Brain-maps Server: %s\n       Data name: %s\n", mURL.c_str(), mDataName.c_str());

}

