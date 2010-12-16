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


#include "ofxWebImageLoader.h"

webImageLoader::webImageLoader()
{
	containsData = false;
}

bool webImageLoader::isUsingTexture()
{
	
	return this->bUseTexture;
}



void webImageLoader::loadFromBuffer(string _str){
	
	
	//copy to our string
	
	//figure out how many bytes the image is and allocate
	int bytesToRead = _str.size();
	char buff[bytesToRead];
	memset(buff, 0, bytesToRead);
	
	//copy the bytes from the string to our buffer
	for(int i = 0; i < bytesToRead; i++){
		buff[i] = _str[i];
	}
	
	//	printf("numBytes copied is %i \n", (int)sizeof(buff));
	
	//if we already have a loaded image clear it
	//	if(isValid()){
    clear();     
	//	}
	
	//create a freeimage memory handle from the buffer address
	FIMEMORY *hmem = NULL;
	hmem = FreeImage_OpenMemory((uint8_t *)buff, bytesToRead);
	if (hmem == NULL){ printf("couldn't create memory handle! \n"); return; }
	
	//get the file type!
	FREE_IMAGE_FORMAT fif = FreeImage_GetFileTypeFromMemory(hmem);
	
	//make the image!!
	putBmpIntoPixels(FreeImage_LoadFromMemory(fif, hmem, 0), myPixels);
	//  bmp = FreeImage_LoadFromMemory(fif, hmem, 0);
	
	//free our memory
	FreeImage_CloseMemory(hmem);
	
	if (getBmpFromPixels(myPixels) == NULL){ printf("couldn't create bmp! \n"); return; }
	
	//flip it!
	FreeImage_FlipVertical(getBmpFromPixels(myPixels));
	
	if (myPixels.bAllocated == true && bUseTexture == true){
		//		printf("[WBC WEB IMAGE LOADER] mypixels bpp %d, imagetype %d, gldata type %d\n", myPixels.bitsPerPixel, myPixels.ofImageType, myPixels.glDataType);
		tex.allocate(myPixels.width, myPixels.height, myPixels.glDataType);
		
	}   
		
	//	swapRgb(myPixels);
	
	update();
	
	containsData = true;
	
	
}


void webImageLoader::loadFromFile(string filename)
{
		
	loadImage(filename);
	update();
	containsData = true;
	
	
}



bool webImageLoader::loadFromUrl(string url){
	
	
	//poco is not happy if we register the factory more than once
	if(!factoryLoaded){
		HTTPStreamFactory::registerFactory();
		factoryLoaded = true;
	}
	
	//specify out url and open stream
	URI uri(url);      
	std::auto_ptr<std::istream> pStr(URIStreamOpener::defaultOpener().open(uri));
	
	//copy to our string
	string str;       
	StreamCopier::copyToString(*pStr.get(), str);
	
	//figure out how many bytes the image is and allocate
	int bytesToRead = str.size();
	char buff[bytesToRead];
	memset(buff, 0, bytesToRead);
	
	//copy the bytes from the string to our buffer
	for(int i = 0; i < bytesToRead; i++){
		buff[i] = str[i];
	}
	
//	printf("[Webimageloader] Numbytes copied is %i \n", (int)sizeof(buff));
	
	//if we already have a loaded image clear it
	// if(isValid()){
    clear();     
	// }
	
	//create a freeimage memory handle from the buffer address
	FIMEMORY *hmem = NULL;
	hmem = FreeImage_OpenMemory((uint8_t *)buff, bytesToRead);
	if (hmem == NULL){ printf("couldn't create memory handle! \n"); return false; }
	
	//get the file type!
	FREE_IMAGE_FORMAT fif = FreeImage_GetFileTypeFromMemory(hmem);
	
	//make the image!!
	putBmpIntoPixels(FreeImage_LoadFromMemory(fif, hmem, 0), myPixels);
	
	//free our memory
	FreeImage_CloseMemory(hmem);
	
	if (getBmpFromPixels(myPixels) == NULL){ printf("couldn't create bmp! \n"); return false; }
	
	//flip it!
	FreeImage_FlipVertical(getBmpFromPixels(myPixels));
	
	if (myPixels.bAllocated == true && bUseTexture == true){
		
		//printf("[WBC WEB IMAGE LOADER] mypixels bpp %d, imagetype %d, gldata type %d\n", myPixels.bitsPerPixel, myPixels.ofImageType, myPixels.glDataType);
		
		tex.allocate(myPixels.width, myPixels.height, myPixels.glDataType);
		
		//		delete [] myPixels.pixels;
	}   
	
	//swapRgb(myPixels);
	
	update();
	
	containsData = true;
	return true;
}  



void webImageLoader::loadFromFileIPHONE(string filename)
{
	
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath(filename, true).c_str()]];
	
	CGImageRef inImage = image.CGImage;
	
	CGContextRef cgctx = createARGBBitmapContextFromImage(inImage);
	
	//if (cgctx == NULL) { break; /* error */ }
	
	size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}}; 
	
	CGContextDrawImage(cgctx, rect, inImage); 
	
	unsigned char* data = (unsigned char*) CGBitmapContextGetData (cgctx);
	
	//setFromPixels(data, w, h, GL_RGB, true);
	

	// When finished, release the context
	CGContextRelease(cgctx);
	
	if (data) { free(data); }
	
	update();
	
	containsData = true;
	

}

CGContextRef webImageLoader::createARGBBitmapContextFromImage(CGImageRef inImage)
{
	
	//- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	//	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}





//
//
//unsigned char* webImageLoader::readImagefile(string filename, int *width, int *height)
//{
//	
//	//typedef enum {
////		NSApplicationDirectory = 1,
////		NSDemoApplicationDirectory,
////		NSDeveloperApplicationDirectory,
////		NSAdminApplicationDirectory,
////		NSLibraryDirectory,
////		NSDeveloperDirectory,
////		NSUserDirectory,
////		NSDocumentationDirectory,
////		NSDocumentDirectory,
////		NSCoreServiceDirectory,
////		NSDesktopDirectory = 12,
////		NSCachesDirectory = 13,
////		NSApplicationSupportDirectory = 14,
////		NSDownloadsDirectory = 15,
////		NSAllApplicationsDirectory = 100,
////		NSAllLibrariesDirectory = 101
////	} NSSearchPathDirectory;
//	
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithCString:filename.c_str()]];
//	
//	UIImage* image = [UIImage imageWithContentsOfFile:path];
//	
//	//- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
//	//	UIColor* color = nil;
//	
//	CGImageRef inImage = image.CGImage;
//	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
//	//	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
//	
//	CGContextRef cgctx = createARGBBitmapContextFromImage(inImage);
//	if (cgctx == NULL) { return nil; /* error */ }
//	
//    size_t w = CGImageGetWidth(inImage);
//	size_t h = CGImageGetHeight(inImage);
//	CGRect rect = {{0,0},{w,h}}; 
//	
//	//	CGPoint point = CGPointMake(100.0f, 100.0f);
//	//	
//	// Draw the image to the bitmap context. Once we draw, the memory
//	// allocated for the context for rendering will then contain the
//	// raw image data in the specified color space.
//	CGContextDrawImage(cgctx, rect, inImage); 
//	
//	// Now we can get a pointer to the image data associated with the bitmap
//	// context.
//	unsigned char* data = (unsigned char*) CGBitmapContextGetData (cgctx);
//	
//	//	if (data != NULL) {
//	//		//offset locates the pixel in the data from x,y.
//	//		//4 for 4 bytes of data per pixel, w is width of one row of data.
//	//		int offset = 4*((w*round(point.y))+round(point.x));
//	//		int alpha =  data[offset];
//	//		int red = data[offset+1];
//	//		int green = data[offset+2];
//	//		int blue = data[offset+3];
//	//		NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
//	//		//color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
//	//	}
//	
//	// When finished, release the context
//	CGContextRelease(cgctx);
//	// Free image data memory for the context
//	//if (data) { free(data); }
//	
//	*width = w;
//    *height = h;
//	
//	return data;
//}
//


