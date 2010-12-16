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


#pragma once

#ifndef OFX_WBC_GLOBALS
#define OFX_WBC_GLOBALS

#include "ofMain.h"
#include "ofxDirList.h"
#include "ofxVectorMath.h"
#include "ofxXmlSettings.h"

#include "ofxHttpEvents.h"
#include "ofxWBCEvents.h";

#include "ofxGuiTypes.h"
#include "ofxWebImageLoader.h"
#include "ofxCamera.h"

#include "MSAInterpolator.h"
#include "ofxMSAInteractiveObject.h"

#include <fstream>

typedef enum {
	WBC_Scene_IntroMovie,
	WBC_Scene_Menu,
	WBC_Scene_Description,
	WBC_Scene_Detail,
	WBC_Scene_Credits,
} wbcScene;

typedef enum  {
	WBC_FORMAT_UNKNOWN,
	WBC_ZOOMIFY,
	WBC_CCDB,
	WBC_BRAINMAPS,
	WBC_ABA,
	WBC_ZFISH,
} wbcTileFormat;




class ofxWBCSlideDescription {
	
public:
	int			mWidth_px;
	int			mHeight_px;
	int			mTileSize_px;
	
	string		mSlideID;
	string		mSlidePath;
	
	float		mResolution;	//micron per pixel
	float		mWidth_um;		//calculate
	float		mHeight_um;		//calculate
	
	int			mNumberOfResolutions;
	
	ofxWBCSlideDescription()
	{
		mWidth_px = 0;
		mHeight_px = 0;
		mTileSize_px = 0;
		mNumberOfResolutions = 0;
		
		mSlideID = "";
		mSlidePath = "";
	};
	
	void print()
	{
		printf("[WBC SLIDE DESCRIPTION] mSlideID: %s\n", mSlideID.c_str());
		printf("[WBC SLIDE DESCRIPTION] mSlidePath: %s\n", mSlidePath.c_str());
		printf("[WBC SLIDE DESCRIPTION] mWidth_px: %d\n", mWidth_px);
		printf("[WBC SLIDE DESCRIPTION] mHeight_px: %d\n", mHeight_px);
		printf("[WBC SLIDE DESCRIPTION] mTileSize_px: %d\n", mTileSize_px);
	}
	
};

#pragma mark -
#pragma mark File utilities

bool static doesFileExist(string _filename)
{	
	bool fileExists = false;
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *temporaryDirectory = [paths objectAtIndex:0];
	NSString* path = [temporaryDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:_filename.c_str()]];
	
//	NSLog(@"Does file exist? %@\n", path);
	
	if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: false ] ) {
		fileExists = true;
	}
	else {
		fileExists = false;
	}
	
	[pool release];
	
	return fileExists;
};


#pragma mark -
#pragma mark project / unproject code from SIO2

//#pragma mark ======== Unproject, make global for tile and engine ========
unsigned char static wbcUnProject( float winx,
								  float winy,
								  float winz,
								  float model   [ 16 ],
								  float proj    [ 16 ],
								  int   viewport[ 4  ],
								  float *objx,
								  float *objy,
								  float *objz )
{
	int i = 0;
	
	float m   [ 16 ],
	a   [ 16 ],
	tin  [ 4  ],
	tout [ 4  ],
	temp[ 16 ],
	wtmp[ 4  ][ 8 ],
	m0,
	m1,
	m2,
	m3,
	s,
	*r0,
	*r1,
	*r2,
	*r3;
	
	tin[ 0 ] = ( winx - viewport[ 0 ] ) * 2.0f / viewport[ 2 ] - 1.0f;
	tin[ 1 ] = ( winy - viewport[ 1 ] ) * 2.0f / viewport[ 3 ] - 1.0f;
	tin[ 2 ] = 2.0f * winz - 1.0f;
	tin[ 3 ] = 1.0f;
	
#define A(row,col) proj[ ( col << 2 ) + row ]
	
#define B(row,col) model[ ( col << 2 ) + row ]
	
#define T(row,col) temp[ ( col << 2 ) + row ]
	
	while( i != 4 )
	{
		T( i, 0 ) = A( i , 0 ) *B( 0, 0 ) + A( i, 1 ) * B( 1,0 ) + A( i, 2 ) *B( 2, 0 ) + A( i, 3) *B( 3, 0 );
		T( i, 1 ) = A( i , 0 ) *B( 0, 1 ) + A( i, 1 ) * B( 1,1 ) + A( i, 2 ) *B( 2, 1 ) + A( i, 3) *B( 3, 1 );
		T( i, 2 ) = A( i , 0 ) *B( 0, 2 ) + A( i, 1 ) * B( 1,2 ) + A( i, 2 ) *B( 2, 2 ) + A( i, 3) *B( 3, 2 );
		T( i, 3 ) = A( i , 0 ) *B( 0, 3 ) + A( i, 1 ) * B( 1,3 ) + A( i, 2 ) *B( 2, 3 ) + A( i, 3) *B( 3, 3 );
		
		++i;
	}
	
#undef A
#undef B
#undef T
	
	
	memcpy( ( void * )a, ( void * )temp, sizeof( float ) << 4 );
	
	
#define SWAP_ROWS( a, b ) { float *_tmp = a; ( a ) = ( b ); ( b ) = _tmp; }
	
#define MAT( a, r, c ) ( a )[ ( c << 2 ) + ( r ) ]
	
	r0 = wtmp[ 0 ], r1 = wtmp[ 1 ], r2 = wtmp[ 2 ], r3 = wtmp[ 3 ];
	
	r0[ 0 ] = MAT( a, 0, 0 ), r0[ 1 ] = MAT( a, 0, 1 ),
	r0[ 2 ] = MAT( a, 0, 2 ), r0[ 3 ] = MAT( a, 0, 3 ),
	r0[ 4 ] = 1.0f          , r0[ 5 ] = r0[ 6 ] = r0[ 7 ] = 0.0f,
	r1[ 0 ] = MAT( a, 1, 0 ), r1[ 1 ] = MAT( a, 1, 1 ),
	r1[ 2 ] = MAT( a, 1, 2 ), r1[ 3 ] = MAT( a, 1, 3 ),
	r1[ 5 ] = 1.0f, r1[ 4 ] = r1[ 6 ] = r1[ 7 ] = 0.0f,
	r2[ 0 ] = MAT( a, 2, 0 ), r2[ 1 ] = MAT( a, 2, 1 ),
	r2[ 2 ] = MAT( a, 2, 2 ), r2[ 3 ] = MAT( a, 2, 3 ),
	r2[ 6 ] = 1.0f          , r2[ 4 ] = r2[ 5 ] = r2[ 7 ] = 0.0f,
	r3[ 0 ] = MAT( a, 3, 0 ), r3[ 1 ] = MAT( a, 3, 1 ),
	r3[ 2 ] = MAT( a, 3, 2 ), r3[ 3 ] = MAT( a, 3, 3 ),
	r3[ 7 ] = 1.0f          , r3[ 4 ] = r3[ 5 ] = r3[ 6 ] = 0.0f;
	
	if( fabs( r3[ 0 ] ) > fabs( r2[ 0 ] ) )
	{ SWAP_ROWS( r3, r2 ); }
	
	if( fabs( r2[ 0 ] ) > fabs( r1[ 0 ] ) )
	{ SWAP_ROWS( r2, r1 ); }
	
	if( fabs( r1[ 0 ] ) > fabs( r0[ 0 ] ) )
	{ SWAP_ROWS( r1, r0 ); }
	
	if( !r0[0] )
	{ return 0; }
	
	
	m1 = r1[ 0 ] / r0[ 0 ];
	m2 = r2[ 0 ] / r0[ 0 ];
	m3 = r3[ 0 ] / r0[ 0 ];
	s  = r0[ 1 ];
	
	r1[ 1 ] -= m1 * s;
	r2[ 1 ] -= m2 * s;
	r3[ 1 ] -= m3 * s;
	s = r0[ 2 ];
	
	r1[ 2 ] -= m1 * s;
	r2[ 2 ] -= m2 * s;
	r3[ 2 ] -= m3 * s;
	s = r0[ 3 ];
	
	r1[ 3 ] -= m1 * s;
	r2[ 3 ] -= m2 * s;
	r3[ 3 ] -= m3 * s;
	s = r0[ 4 ];
	
	if( s )
	{
		r1[ 4 ] -= m1 * s;
		r2[ 4 ] -= m2 * s;
		r3[ 4 ] -= m3 * s;
	}
	s = r0[ 5 ];
	
	if( s )
	{
		r1[ 5 ] -= m1 * s;
		r2[ 5 ] -= m2 * s;
		r3[ 5 ] -= m3 * s;
	}
	s = r0[ 6 ];
	
	if( s )
	{
		r1[ 6 ] -= m1 * s;
		r2[ 6 ] -= m2 * s;
		r3[ 6 ] -= m3 * s;
	}
	s = r0[ 7 ];
	
	if (s != 0.0)
	{
		r1[ 7 ] -= m1 * s;
		r2[ 7 ] -= m2 * s;
		r3[ 7 ] -= m3 * s;
	}
	
	if( fabs( r3[ 1 ] ) > fabs( r2[ 1 ] ) )
	{ SWAP_ROWS( r3, r2 ); }
	
	if( fabs( r2[ 1 ] ) > fabs( r1[ 1 ] ) )
	{ SWAP_ROWS( r2, r1 ); }
	
	if( !r1[ 1 ] )
	{ return 0; }
	
	m2 = r2[ 1 ] / r1[ 1 ];
	m3 = r3[ 1 ] / r1[ 1 ];
	
	r2[ 2 ] -= m2 * r1[ 2 ];
	r3[ 2 ] -= m3 * r1[ 2 ];
	r2[ 3 ] -= m2 * r1[ 3 ];
	r3[ 3 ] -= m3 * r1[ 3 ];
	s = r1[ 4 ];
	
	if( s )
	{
		r2[ 4 ] -= m2 * s;
		r3[ 4 ] -= m3 * s;
	}
	s = r1[ 5 ];
	
	if( s )
	{
		r2[ 5 ] -= m2 * s;
		r3[ 5 ] -= m3 * s;
	}
	s = r1[ 6 ];
	
	if( s )
	{
		r2[ 6 ] -= m2 * s;
		r3[ 6 ] -= m3 * s;
	}
	s = r1[ 7 ];
	
	if( s )
	{
		r2[ 7 ] -= m2 * s;
		r3[ 7 ] -= m3 * s;
	}
	
	if( fabs( r3[ 2 ] ) > fabs( r2[ 2 ] ) )
	{ SWAP_ROWS( r3, r2 ); }
	
	if( !r2[ 2 ] )
	{ return 0; }
	
	m3 = r3[ 2 ] / r2[ 2 ];
	r3[ 3 ] -= m3 * r2[ 3 ], r3[ 4 ] -= m3 * r2[ 4 ],
	r3[ 5 ] -= m3 * r2[ 5 ], r3[ 6 ] -= m3 * r2[ 6 ], r3[ 7 ] -= m3 * r2[ 7 ];
	
	
	if( !r3[ 3 ] )
	{ return 0; }
	
	s = 1.0f / r3[ 3 ];
	r3[ 4 ] *= s;
	r3[ 5 ] *= s;
	r3[ 6 ] *= s;
	r3[ 7 ] *= s;
	
	m2 = r2[ 3 ];
	s = 1.0f / r2[ 2 ];
	r2[ 4 ] = s * ( r2[ 4 ] - r3[ 4 ] * m2 ), r2[ 5 ] = s * ( r2[ 5 ] - r3[ 5 ] * m2 ),
	r2[ 6 ] = s * ( r2[ 6 ] - r3[ 6 ] * m2 ), r2[ 7 ] = s * ( r2[ 7 ] - r3[ 7 ] * m2 );
	
	m1 = r1[ 3 ];
	r1[ 4 ] -= r3[ 4 ] * m1, r1[ 5 ] -= r3[ 5 ] * m1,
	r1[ 6 ] -= r3[ 6 ] * m1, r1[ 7 ] -= r3[ 7 ] * m1;
	
	m0 = r0[3];
	r0[ 4 ] -= r3[ 4 ] * m0, r0[ 5 ] -= r3[ 5 ] * m0,
	r0[ 6 ] -= r3[ 6 ] * m0, r0[ 7 ] -= r3[ 7 ] * m0;
	
	m1 = r1[ 2 ];
	s = 1.0f / r1[ 1 ];
	r1[ 4 ] = s * ( r1[ 4 ] - r2[ 4 ] * m1 ), r1[ 5 ] = s * ( r1[ 5 ] - r2[ 5 ] * m1 ),
	r1[ 6 ] = s * ( r1[ 6 ] - r2[ 6 ] * m1 ), r1[ 7 ] = s * ( r1[ 7 ] - r2[ 7 ] * m1 );
	
	m0 = r0[ 2 ];
	r0[ 4 ] -= r2[ 4 ] * m0, r0[ 5 ] -= r2[ 5 ] * m0,
	r0[ 6 ] -= r2[ 6 ] * m0, r0[ 7 ] -= r2[ 7 ] * m0;
	
	m0 = r0[ 1 ];
	s = 1.0f / r0[ 0 ];
	r0[ 4 ] = s * ( r0[ 4 ] - r1[ 4 ] * m0 ), r0[ 5 ] = s * ( r0[ 5 ] - r1[ 5 ] * m0 ),
	r0[ 6 ] = s * ( r0[ 6 ] - r1[ 6 ] * m0 ), r0[ 7 ] = s * ( r0[ 7 ] - r1[ 7 ] * m0 );
	
	MAT( m, 0, 0 ) = r0[ 4 ];
	MAT( m, 0, 1 ) = r0[ 5 ], MAT( m, 0, 2 ) = r0[ 6 ];
	MAT( m, 0, 3 ) = r0[ 7 ], MAT( m, 1, 0 ) = r1[ 4 ];
	MAT( m, 1, 1 ) = r1[ 5 ], MAT( m, 1, 2 ) = r1[ 6 ];
	MAT( m, 1, 3 ) = r1[ 7 ], MAT( m, 2, 0 ) = r2[ 4 ];
	MAT( m, 2, 1 ) = r2[ 5 ], MAT( m, 2, 2 ) = r2[ 6 ];
	MAT( m, 2, 3 ) = r2[ 7 ], MAT( m, 3, 0 ) = r3[ 4 ];
	MAT( m, 3, 1 ) = r3[ 5 ], MAT( m, 3, 2 ) = r3[ 6 ];
	MAT( m, 3, 3 ) = r3[ 7 ];
	
#undef MAT
#undef SWAP_ROWS
	
	
#define M(row,col) m[ col * 4 + row ]
	
	tout[ 0 ] = M( 0, 0 ) * tin[ 0 ] + M( 0, 1 ) * tin[ 1 ] + M( 0, 2 ) * tin[ 2 ] + M( 0, 3 ) * tin[ 3 ];
	tout[ 1 ] = M( 1, 0 ) * tin[ 0 ] + M( 1, 1 ) * tin[ 1 ] + M( 1, 2 ) * tin[ 2 ] + M( 1, 3 ) * tin[ 3 ];
	tout[ 2 ] = M( 2, 0 ) * tin[ 0 ] + M( 2, 1 ) * tin[ 1 ] + M( 2, 2 ) * tin[ 2 ] + M( 2, 3 ) * tin[ 3 ];
	tout[ 3 ] = M( 3, 0 ) * tin[ 0 ] + M( 3, 1 ) * tin[ 1 ] + M( 3, 2 ) * tin[ 2 ] + M( 3, 3 ) * tin[ 3 ];
#undef M
	
	
	if( !tout[ 3 ] )
	{ return 0; }
	
	*objx = tout[ 0 ] / tout[ 3 ];
	*objy = tout[ 1 ] / tout[ 3 ];
	*objz = tout[ 2 ] / tout[ 3 ];
	
	return 1;
};

unsigned char static wbcProject( float objx,
								float objy,
								float objz,
								float model   [ 16 ],
								float proj    [ 16 ],
								int   viewport[ 4  ],
								float *winx,
								float *winy,
								float *winz )
{
	float tin [ 4 ],
	tout[ 4 ];
	
	tin[ 0 ] = objx;
	tin[ 1 ] = objy;
	tin[ 2 ] = objz;
	tin[ 3 ] = 1.0f;
	
	// Get rid of theses lousy macro...
#define M( row, col ) model[ col * 4 + row ]
	
	tout[ 0 ] = M( 0, 0 ) * tin[ 0 ] + M( 0, 1 ) * tin[ 1 ] + M( 0, 2 ) * tin[ 2 ] + M( 0, 3 ) * tin[ 3 ];
	tout[ 1 ] = M( 1, 0 ) * tin[ 0 ] + M( 1, 1 ) * tin[ 1 ] + M( 1, 2 ) * tin[ 2 ] + M( 1, 3 ) * tin[ 3 ];
	tout[ 2 ] = M( 2, 0 ) * tin[ 0 ] + M( 2, 1 ) * tin[ 1 ] + M( 2, 2 ) * tin[ 2 ] + M( 2, 3 ) * tin[ 3 ];
	tout[ 3 ] = M( 3, 0 ) * tin[ 0 ] + M( 3, 1 ) * tin[ 1 ] + M( 3, 2 ) * tin[ 2 ] + M( 3, 3 ) * tin[ 3 ];
#undef M
	
	
#define M( row, col ) proj[ col * 4 + row ]
	
	tin[ 0 ] = M( 0, 0 ) * tout[ 0 ] + M( 0, 1 ) * tout[ 1 ] + M( 0, 2 ) * tout[ 2 ] + M( 0, 3 ) * tout[ 3 ];
	tin[ 1 ] = M( 1, 0 ) * tout[ 0 ] + M( 1, 1 ) * tout[ 1 ] + M( 1, 2 ) * tout[ 2 ] + M( 1, 3 ) * tout[ 3 ];
	tin[ 2 ] = M( 2, 0 ) * tout[ 0 ] + M( 2, 1 ) * tout[ 1 ] + M( 2, 2 ) * tout[ 2 ] + M( 2, 3 ) * tout[ 3 ];
	tin[ 3 ] = M( 3, 0 ) * tout[ 0 ] + M( 3, 1 ) * tout[ 1 ] + M( 3, 2 ) * tout[ 2 ] + M( 3, 3 ) * tout[ 3 ];
#undef M
	
	if( !tin[ 3 ] )
	{ return 0; }
	
	tin[ 0 ] /= tin[ 3 ];
	tin[ 1 ] /= tin[ 3 ];
	tin[ 2 ] /= tin[ 3 ];
	
	*winx = viewport[ 0 ] + ( 1.0f + tin[ 0 ] ) * viewport[ 2 ] * 0.5f;
	*winy = viewport[ 1 ] + ( 1.0f + tin[ 1 ] ) * viewport[ 3 ] * 0.5f;
	*winz = ( 1.0f + tin[ 2 ] ) * 0.5f;
	
	return 1;
};



#endif