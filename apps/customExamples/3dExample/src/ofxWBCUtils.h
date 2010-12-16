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


#ifndef _OFX_WBC_UTILS
#define _OFX_WBC_UTILS

#include "ofMain.h"

#include "ofxThread.h"

#include "Poco/Net/HTTPClientSession.h"
#include "Poco/Net/HTTPRequest.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTMLForm.h"
#include "Poco/StreamCopier.h"
#include "Poco/Path.h"
#include "Poco/URI.h"
#include "Poco/Exception.h"
#include "Poco/BasicEvent.h"
#include "Poco/Delegate.h"

#include <iostream>
//#include <queue.h>
#include <vector>
#include <istream.h>

using Poco::Net::HTTPClientSession;
using Poco::Net::HTTPRequest;
using Poco::Net::HTTPResponse;
using Poco::Net::HTMLForm;
using Poco::Net::HTTPMessage;
using Poco::StreamCopier;
using Poco::Path;
using Poco::URI;
using Poco::Exception;
using Poco::BasicEvent;
using Poco::Delegate;

class ofxWBCListener;
class ofxWBCEventManager;

typedef Poco::Timestamp ofTimestamp;

#include "ofxWBCdownloadTypes.h"

struct ofxWBCResponse{
	ofxWBCResponse(HTTPResponse& pocoResponse, istream &bodyStream, string turl){
		status = pocoResponse.getStatus();
		timestamp = pocoResponse.getDate();
		reasonForStatus = pocoResponse.getReasonForStatus(pocoResponse.getStatus());
		contentType = pocoResponse.getContentType();
		
		//d_stream = (istream*)bodyStream;
		
		StreamCopier::copyToString(bodyStream, responseBody);
		
		url = turl;
	}
	
	ofxWBCResponse(){}
	
	int status; 				// return code for the response ie: 200 = OK
	string reasonForStatus;		// text explaining the status
	string responseBody;		// the actual response
	string contentType;			// the mime type of the response
	ofTimestamp timestamp;		// time of the response
	string url;
};

class ofxWBCUtils : public ofxThread{
	
public:
	
	ofxWBCUtils();
	~ofxWBCUtils();
	//-------------------------------
	// non blocking functions
	
	void addForm(ofxWBCForm form);
	void addUrl(string url);
	void addUrl(string url, bool *inFrustum);
	
	
	//-------------------------------
	// blocking functions
	void submitForm(ofxWBCForm form);
	void getUrl(string url);
	void getUrlWithPort(string url, uint16_t port);
	ofxWBCResponse getUrlWithResponse(string url);
	
	// other stuff-------------------
	int getQueueLength(){
		return forms.size();
	}
	
	void clearMost() {
		while (forms.size() > 2) {
			forms.erase(forms.begin());
		}
	}
	
	void clearQueue(){
		forms.clear();					
	}
	void setTimeoutSeconds(int t){
		timeoutSeconds = t;
	}
	void setVerbose(bool v){
		verbose = v;
	}
	//-------------------------------
	// threading stuff
	void threadedFunction();
protected:
	void start();
	void stop();
	
	bool verbose;
	
	//--------------------------------
	// http utils
	string generateUrl(ofxWBCForm & form);
	void doPostForm(ofxWBCForm & form);
	ofxWBCResponse doPostFormWithResponse(ofxWBCForm & form);
	
	list <ofxWBCForm> forms;
	int timeoutSeconds;
	
};
#endif
