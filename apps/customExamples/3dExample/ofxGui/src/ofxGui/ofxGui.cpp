/*
 *  ofxGui.cpp
 *  openFrameworks
 *
 *  Created by Stefan Kirch on 18.06.08.
 *  Copyright 2008 alphakanal. All rights reserved.
 *
 */

//	----------------------------------------------------------------------------------------------------

#include "ofxGui.h"


//	----------------------------------------------------------------------------------------------------

ofxGui* ofxGui::Instance(ofxGuiListener* listener)
{
	static ofxGui gui(listener);
	return &gui;
}

//	----------------------------------------------------------------------------------------------------

ofxGui::ofxGui(ofxGuiListener* listener)
{
	mIsActive			= false;
	mDoUpdate			= false;
	mXmlDone			= true;
	
	
	mGlobals			= ofxGuiGlobals::Instance();
	mGlobals->mListener	= listener;
	
//	ofAddListener(ofEvents.touchDown, this, &ofxGui::mousePressed);
//	ofAddListener(ofEvents.touchMoved, this, &ofxGui::mouseDragged);
//	ofAddListener(ofEvents.touchUp, this, &ofxGui::mouseReleased);
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::update(int parameterId, int type, void* data, int length)
{
	if(mIsActive || mDoUpdate)
	{
		ofxGuiObject*	tmpObj;
		bool			handled;
		
		for(int i = 0; i < mObjects.size(); i++)
		{
			tmpObj	= (ofxGuiObject*)mObjects.at(i);
			handled	= tmpObj->update(parameterId, type, data, length);

			if(handled)
				break;
		}
	}
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::draw()
{
	if(mIsActive)
	{
	//	ofEnableAlphaBlending();
		
		ofxGuiObject* tmpObj;
		
		for(int i = 0; i < mObjects.size(); i++)
		{
			tmpObj = (ofxGuiObject*)mObjects.at(i);
			if (tmpObj->mIsActive) {
				//printf("shoudl draw");
				tmpObj->draw();				
			}

		}
		
	//	ofDisableAlphaBlending();
	}
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::activate(bool activate)
{
	mIsActive = activate;
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::forceUpdate(bool update)
{
	mDoUpdate = update;
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::keyPressed(int key)
{
	
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::keyReleased(int key)
{
	
}

//	----------------------------------------------------------------------------------------------------

//void ofxGui::mouseDragged(int x, int y, int button)
//void			mousePressed(ofTouchEventArgs &e);	

int ofxGui::mouseDragged(ofTouchEventArgs &e)
{

	if(mIsActive)
	{
		ofxGuiObject*	tmpObj;
		bool			handled;

		for(int i = 0; i < mObjects.size(); i++)
		{
			tmpObj	= (ofxGuiObject*)mObjects.at(i);
			if (tmpObj->mIsActive) {
				handled	= tmpObj->mouseDragged(e.x, e.y, 0);
			}


			if(handled)
				return true;
		}
	}
	
	return false;
}

//	----------------------------------------------------------------------------------------------------

//void ofxGui::mousePressed(int x, int y, int button)
int ofxGui::mousePressed(ofTouchEventArgs &e)
{
	
	if(mIsActive)
	{
		ofxGuiObject*	tmpObj;
		bool			handled;
		
		for(int i = 0; i < mObjects.size(); i++)
		{
			tmpObj	= (ofxGuiObject*)mObjects.at(i);
			if (tmpObj->mIsActive) {
				handled	= tmpObj->mousePressed(e.x, e.y, 0);
			}
			
			if(handled)
			{
			//	printf("handled");
				return true;
			}
			
		}
		
	}
	
	return false;
}

//	----------------------------------------------------------------------------------------------------

//void ofxGui::mouseReleased(int x, int y, int button)
int ofxGui::mouseReleased(ofTouchEventArgs &e)
{
	
	if(mIsActive)
	{
		ofxGuiObject*	tmpObj;
		bool			handled;	
		
		for(int i = 0; i < mObjects.size(); i++)
		{
			
			tmpObj = (ofxGuiObject*)mObjects.at(i);
			
			if (tmpObj->mIsActive) {
				handled = tmpObj->mouseReleased(e.x, e.y, 0);
			}
			
			if (handled) {
				return true;
			}
		}
	}
	
	return false;
}

//	----------------------------------------------------------------------------------------------------

ofxGuiPanel* ofxGui::addPanel(int id, string name, int x, int y, int border, int spacing)
{
	ofxGuiPanel* newPanel = new ofxGuiPanel();
	newPanel->init(id, name, x, y, border, spacing);
	mObjects.push_back(newPanel);
	
	return newPanel;
}

//	----------------------------------------------------------------------------------------------------

bool ofxGui::buildFromXml(string file)
{
	if(!mXmlDone)
		return false;
	
	if(!mGlobals->mXml.loadFile(file))
		return false;
	
	int numberOfTags = mGlobals->mXml.getNumTags("UI");
	
	if(numberOfTags != 1)
		return false;
	
	mObjects.clear();
	
	mXmlDone			= false;
	mGlobals->mXmlfile	= file;
	
	mGlobals->mXml.pushTag("UI", 0);

	mIsActive	= mGlobals->mXml.getValue("ISACTIVE", 0);
	mDoUpdate	= mGlobals->mXml.getValue("DOUPDATE", 0);

	mGlobals->buildFromXml();
	
	numberOfTags = mGlobals->mXml.getNumTags("OBJECT");
	
	if(numberOfTags > 0)
	{
		for(int i = 0; i < numberOfTags; i++)
		{
			mGlobals->mXml.pushTag("OBJECT", i);
			
			int		id		= mGlobals->mXml.getValue("ID", 0);
			string	type	= mGlobals->mXml.getValue("TYPE", "");
			string	name	= mGlobals->mXml.getValue("NAME", "");
			int		x		= mGlobals->mXml.getValue("LEFT", 0);
			int		y		= mGlobals->mXml.getValue("TOP", 0);
			int		border	= mGlobals->mXml.getValue("BORDER", 0);
			int		spacing	= mGlobals->mXml.getValue("SPACING", 0);
			
			if(type == "PANEL")
			{
				ofxGuiPanel* panel = addPanel(id, name, x, y, border, spacing);
				panel->buildFromXml();
			}
			
			mGlobals->mXml.popTag();
		}
	}
	
	mGlobals->mXml.popTag();
	
	mXmlDone = true;
	
	return true;
}

//	----------------------------------------------------------------------------------------------------

void ofxGui::saveToXml(string file)
{
	if(!mXmlDone)
		return;

	mXmlDone = false;

	mGlobals->mXml.clear();
		
	int id = mGlobals->mXml.addTag("UI");
	
	mGlobals->mXml.setValue("UI:VERSION", OFXGUI_VERSION, id);

	mGlobals->mXml.setValue("UI:ISACTIVE", mIsActive, id);
	mGlobals->mXml.setValue("UI:DOUPDATE", mDoUpdate, id);
		
	mGlobals->mXml.pushTag("UI", id);

	mGlobals->saveToXml();

	ofxGuiObject* tmpObj;

	for(int i = 0; i < mObjects.size(); i++)
	{
		tmpObj = (ofxGuiObject*)mObjects.at(i);
		tmpObj->saveToXml();
	}
	
	mGlobals->mXml.popTag();
	mGlobals->mXml.saveFile(file);

	mXmlDone = true;
}

//	----------------------------------------------------------------------------------------------------

//void ofxGui::touchDown(ofTouchEventArgs &touch)
//{
//	printf("hhahah");
//	
//}
//
//void ofxGui::touchMoved(ofTouchEventArgs &touch)
//{}
//
//void ofxGui::touchUp(ofTouchEventArgs &touch)
//{}
//
//void ofxGui::touchDoubleTap(ofTouchEventArgs &touch)
//{}


