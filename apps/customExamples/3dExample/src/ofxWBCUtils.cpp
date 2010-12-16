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


#include "ofxWBCUtils.h"

#include "ofxWBCEvents.h"

// ----------------------------------------------------------------------
ofxWBCUtils::ofxWBCUtils(){
    timeoutSeconds = 40; // default timeout
    verbose = false;
    start();
}
// ----------------------------------------------------------------------
ofxWBCUtils::~ofxWBCUtils(){
    stop();
}
// ----------------------------------------------------------------------
void ofxWBCUtils::submitForm(ofxWBCForm form){
	doPostForm(form);
}
// ----------------------------------------------------------------------
void ofxWBCUtils::addForm(ofxWBCForm form){
	forms.push_back(form);
	
	if (isThreadRunning() == false){
	
		start();
	}
	
}


// ----------------------------------------------------------------------
void ofxWBCUtils::start() {
	if (isThreadRunning() == false){
        if(verbose) printf("starting http thread\n");
        startThread(true, verbose);
    }
}
// ----------------------------------------------------------------------
void ofxWBCUtils::stop() {
    stopThread();
}
// ----------------------------------------------------------------------
void ofxWBCUtils::threadedFunction(){
	
    // loop through this process whilst thread running
    while( isThreadRunning() == true )
		
    	if(forms.size()>0){
			ofxWBCForm form = forms.front();
			
			if (*form.inFrustum) {
				if(form.method==OFX_WBC_POST){
					doPostForm(form);
					if(verbose) printf("ofxWBCUtils: (thread running) form submitted (post): %s\n", form.name.c_str());
				}else{
					string url = generateUrl(form);
					getUrl(url);
					if(verbose) printf("ofxWBCUtils: (thread running) form submitted (get): %s\n", form.name.c_str());
				}
				
				forms.erase( forms.begin() );				
				
			}
			else {
				//printf("no longer in frustum, discarding. ;)\n");
				forms.erase( forms.begin() );
			}
    	}else{
    		stop();
    	}
	
}

// ----------------------------------------------------------------------
string ofxWBCUtils::generateUrl(ofxWBCForm & form) {
    // url to send to
    string url = form.action;
	
    // do we have any form fields?
    if(form.formIds.size() > 0){
        url += "?";
        for(unsigned int i=0;i<form.formIds.size();i++){
            url += form.formIds[i] +"="+ form.formValues[i];
            if(i<form.formIds.size()-1)
                url += "&";
        }
    }
    return url;
}

// ----------------------------------------------------------------------
void ofxWBCUtils::doPostForm(ofxWBCForm & form){
	
    try{
		
        URI uri( form.action.c_str() );
        std::string path(uri.getPathAndQuery());
        if (path.empty()) path = "/";
		
        HTTPClientSession session(uri.getHost(), uri.getPort());
        HTTPRequest req(HTTPRequest::HTTP_POST, path, HTTPMessage::HTTP_1_1);
		
        session.setTimeout(Poco::Timespan(timeoutSeconds,0));
		
        // create the form data to send
        HTMLForm pocoForm(HTMLForm::ENCODING_URL);
		
        // form values
        for(unsigned int i=0; i<form.formIds.size(); i++){
            const std::string name = form.formIds[i].c_str();
            const std::string val = form.formValues[i].c_str();
            pocoForm.set(name, val);
        }
		
        pocoForm.prepareSubmit(req);
		
        pocoForm.write(session.sendRequest(req));
        HTTPResponse res;
        istream& rs = session.receiveResponse(res);
		
		ofxWBCResponse response=ofxWBCResponse(res, rs, form.action);
		
    	ofxWBCEvents.notifyNewResponse(response);
		
		
    }catch (Exception& exc){
        ofxWBCEvents.notifyNewError("time out ");
        if(verbose) std::cerr << exc.displayText() << std::endl;
    }
	
}

ofxWBCResponse ofxWBCUtils::doPostFormWithResponse(ofxWBCForm & form){
	
    try{
		
        URI uri( form.action.c_str() );
        std::string path(uri.getPathAndQuery());
        if (path.empty()) path = "/";
		
        HTTPClientSession session(uri.getHost(), uri.getPort());
        HTTPRequest req(HTTPRequest::HTTP_POST, path, HTTPMessage::HTTP_1_1);
		
        session.setTimeout(Poco::Timespan(timeoutSeconds,0));
		
        // create the form data to send
        HTMLForm pocoForm(HTMLForm::ENCODING_URL);
		
        // form values
        for(unsigned int i=0; i<form.formIds.size(); i++){
            const std::string name = form.formIds[i].c_str();
            const std::string val = form.formValues[i].c_str();
            pocoForm.set(name, val);
        }
		
        pocoForm.prepareSubmit(req);
		
        pocoForm.write(session.sendRequest(req));
        HTTPResponse res;
        istream& rs = session.receiveResponse(res);
		
		ofxWBCResponse response=ofxWBCResponse(res, rs, form.action);
		
		//	ofxWBCEvents.notifyNewResponse(response);
		return response;
		
    }catch (Exception& exc){
		//    ofxWBCEvents.notifyNewError("time out ");
        if(verbose) std::cerr << exc.displayText() << std::endl;
    }
	
}


// ----------------------------------------------------------------------

//I've taken this function out for now whilst I make everything run ok in a thread
void ofxWBCUtils::getUrl(string url){
	try{
		URI uri(url.c_str());
		std::string path(uri.getPathAndQuery());
		if (path.empty()) path = "/";
		//printf("[ofxWBCUTIL] port: %d\n", uri.getPort());
		
		HTTPClientSession session(uri.getHost(), uri.getPort());
		HTTPRequest req(HTTPRequest::HTTP_GET, path, HTTPMessage::HTTP_1_1);
		session.sendRequest(req);
		
		session.setTimeout(Poco::Timespan(timeoutSeconds,0));
		
		HTTPResponse res;
		istream& rs = session.receiveResponse(res);
		
		ofxWBCResponse response=ofxWBCResponse(res,rs,url);
		
		ofxWBCEvents.notifyNewResponse(response);
		
	}catch (Exception& exc){
		if(verbose) std::cerr << exc.displayText() << std::endl;
		ofxWBCEvents.notifyNewError("time out ");
	}
}

void ofxWBCUtils::getUrlWithPort(string url, uint16_t port){
	try{
		URI uri(url.c_str());
		std::string path(uri.getPathAndQuery());
		if (path.empty()) path = "/";
		//printf("[ofxWBCUTIL] port: %d, used: %d\n", uri.getPort(), port);
		
		HTTPClientSession session(uri.getHost(), port);
		HTTPRequest req(HTTPRequest::HTTP_GET, path, HTTPMessage::HTTP_1_1);
		session.sendRequest(req);
		
		session.setTimeout(Poco::Timespan(timeoutSeconds,0));
		
		HTTPResponse res;
		istream& rs = session.receiveResponse(res);
		
		ofxWBCResponse response=ofxWBCResponse(res,rs,url);
		
		ofxWBCEvents.notifyNewResponse(response);
		
	}catch (Exception& exc){
		if(verbose) std::cerr << exc.displayText() << std::endl;
		ofxWBCEvents.notifyNewError("time out ");
	}
}


ofxWBCResponse ofxWBCUtils::getUrlWithResponse(string url){
	try{
		URI uri(url.c_str());
		std::string path(uri.getPathAndQuery());
		if (path.empty()) path = "/";
		
		HTTPClientSession session(uri.getHost(), uri.getPort());
		HTTPRequest req(HTTPRequest::HTTP_GET, path, HTTPMessage::HTTP_1_1);
		session.sendRequest(req);
		
		session.setTimeout(Poco::Timespan(timeoutSeconds,0));
		
		HTTPResponse res;
		istream& rs = session.receiveResponse(res);
		
		ofxWBCResponse response= ofxWBCResponse(res,rs,url);
		
		return response;
		
		//		ofxWBCEvents.notifyNewResponse(response);
		
	}catch (Exception& exc){
		if(verbose) std::cerr << exc.displayText() << std::endl;
		ofxWBCEvents.notifyNewError("time out ");
		
	}
}

void ofxWBCUtils::addUrl(string url){
	ofxWBCForm form;
	form.action=url;
	form.method=OFX_WBC_GET;
    form.name=form.action;
	addForm(form);
}

void ofxWBCUtils::addUrl(string url, bool *inFrustum){

	
	ofxWBCForm form;
	form.action=url;
	form.method=OFX_WBC_GET;
    form.name=form.action;
	form.inFrustum = inFrustum;
	addForm(form);
}

ofxWBCUtils ofxWBCUtil;
ofxWBCEventManager ofxWBCEvents(&ofxWBCUtil);


