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


#ifndef OFX_WBC_EVENTS
#define OFX_WBC_EVENTS

#include "ofxWBCUtils.h"

class ofxWBCEventListener{
public:
	virtual void newResponse( ofxWBCResponse & response ){};
	virtual void newError(string & error) {};
	void newResponse(const void * sender, ofxWBCResponse & response){
		newResponse(response);
	}
    void newError(const void * sender, string & error){
        newError(error);
    }
};

class ofxWBCEventManager{
public:
	ofxWBCEventManager(ofxWBCUtils * sender){
		this->sender=sender;
	}
	void addListener(ofxWBCEventListener * listener){
		responseEvent += Poco::Delegate<ofxWBCEventListener,ofxWBCResponse>(listener,&ofxWBCEventListener::newResponse);
		errorEvent    += Poco::Delegate<ofxWBCEventListener,string>(listener,&ofxWBCEventListener::newError);
	}
	
	void removeListener(ofxWBCEventListener * listener){
		responseEvent -= Poco::Delegate<ofxWBCEventListener,ofxWBCResponse>(listener,&ofxWBCEventListener::newResponse);
		errorEvent    -= Poco::Delegate<ofxWBCEventListener,string>(listener,&ofxWBCEventListener::newError);
	}
	
	void notifyNewResponse(ofxWBCResponse response){
		responseEvent.notify(sender,response);
	}
	void notifyNewError(string error){
		errorEvent.notify(sender,error);
	}
protected:
	Poco::BasicEvent <ofxWBCResponse> responseEvent;
	Poco::BasicEvent<string>           errorEvent;
	ofxWBCUtils * sender;
};

extern ofxWBCUtils ofxWBCUtil;
extern ofxWBCEventManager ofxWBCEvents;
#endif /* ofxWBCEVENTS_H_ */
