#import "ViewController.h"

// Import of the 3 example classes. Choose one example below.

#include "com/tastenkunst/cpp/brf/nxt/ios/examples/ExamplePointTrackingIOS.hpp"
#include "com/tastenkunst/cpp/brf/nxt/ios/examples/ExampleFaceDetectionIOS.hpp"
#include "com/tastenkunst/cpp/brf/nxt/ios/examples/ExampleFaceTrackingIOS.hpp"
#include "com/tastenkunst/cpp/brf/nxt/ios/examples/ExampleFaceSubstitutionIOS.hpp"
#include "com/tastenkunst/cpp/brf/nxt/ios/examples/ExampleCandideTrackingIOS.hpp"

#include "com/tastenkunst/cpp/brf/nxt/utils/StringUtils.hpp"

#import "OpenGLView.h"

#import <sys/utsname.h>

@interface ViewController ()

@end

@implementation ViewController

UIImageView *captureImage;
AVCaptureVideoDataOutput* videoOutput;
OpenGLView* glView;

// Choose one resolution. Newer devices can handle 640x480, older ones only 352x288 resolutions.

// normal camera resolution settings -> eg. iphone 6 (older chip/cpu)

int _cameraWidth  = 480;
int _cameraHeight = 640;
NSString* _defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;

// small camera resolution settings -> eg ipad 3 (older chip/cpu)
/*
static int _cameraWidth  = 288;
static int _cameraHeight = 352;
static NSString* _defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
*/
AVCaptureSession *session;
AVCaptureVideoOrientation _defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
dispatch_queue_t videoQueue;

// Choose one of these examples.

//ExamplePointTrackingIOS _example(_cameraWidth, _cameraHeight);
//ExampleFaceDetectionIOS _example(_cameraWidth, _cameraHeight);
//ExampleFaceTrackingIOS _example(_cameraWidth, _cameraHeight);
ExampleFaceSubstitutionIOS _example(_cameraWidth, _cameraHeight);
//ExampleCandideTrackingIOS _example(_cameraWidth, _cameraHeight);

// static initializsers. READY will be called, once BRF is ready to be used.

const std::function< void() > brf::BRFManager::READY = []{ _example.onReadyBRF(); };
double DrawingUtils::CANVAS_WIDTH = (double)_cameraWidth;
double DrawingUtils::CANVAS_HEIGHT = (double)_cameraHeight;

// should the camera image be like a mirror?

bool _mirrored = true;

// use front cam (at the display site)

bool _useFrontCam = true;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// !!! MAKE SURE YOU HAVE THE CORRENT LAUNCH IMAGES SET FOR YOUR DEVICE,
	// OTHERWISE THE MASKS WILL BE NOT PLACED CORRECTLY!!!
	
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	brf::trace("resolution: " + brf::to_string(screenBounds.size.width) + " " + brf::to_string(screenBounds.size.height));
	
    glView = [[OpenGLView alloc] initWithFrame:screenBounds];
}

- (void)viewDidAppear:(BOOL)animated {
    [self initializeCamera];
	_example.init(true);
}

- (void)loadView {
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;

	captureImage = [[UIImageView alloc] initWithFrame:applicationFrame];
	captureImage.contentMode = UIViewContentModeScaleAspectFill;
	[self.view addSubview:captureImage];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
         didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection *)connection
{

// Create autorelease pool because we are not in the main_queue
@autoreleasepool {

	// Get a CMSampleBuffer's Core Video image buffer for the media data
	//CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	// Lock the base address of the pixel buffer
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
    // Get the pixel buffer width and height
	int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
	
	if(width != _cameraWidth || height != _cameraHeight) {
		
		brf::trace("Error: wrong video input size: width: " + brf::to_string(width) +
				" height: " + brf::to_string(height));
		brf::trace("... changing videoOrientation ...");
		
		[connection setVideoOrientation: 	_defaultAVCaptureVideoOrientation];
		[connection setVideoMirrored: 		_mirrored];
		
		//We unlock the  image buffer
		CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
		
	} else {
	
	    // Get the number of bytes per row for the pixel buffer
		uint8_t* baseAddress = (uint8_t*) CVPixelBufferGetBaseAddress(imageBuffer);
		
		// Create a device-dependent RGB color space
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		// Create a bitmap graphics context with the sample buffer data
		CGContextRef context = CGBitmapContextCreate(
			baseAddress, width, height, 8, CVPixelBufferGetBytesPerRow(imageBuffer),
			colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
		
		_example.update(baseAddress);
		_example.updateGUI(context);
		
		[glView updateVertices:_example._brfManager.faceShape().faceShapeVertices];
		
		// Create a Quartz image from the pixel data in the bitmap graphics context
		CGImageRef quartzImage = CGBitmapContextCreateImage(context);
		// Unlock the pixel buffer
		CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
		
		// Free up the context and color space
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
	 
		// Create an image object from the Quartz image
		UIImage *image = [UIImage imageWithCGImage:quartzImage];
		
		// Release the Quartz image
		CGImageRelease(quartzImage);
		
		//captureImage.hidden = FALSE;
		[captureImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
	}
}

}

- (void) initializeCamera {

    session = [[AVCaptureSession alloc] init];
	session.sessionPreset = _defaultAVCaptureSessionPreset;
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill]; //AVLayerVideoGravityResizeAspectFill
    
	captureVideoPreviewLayer.frame = self.view.bounds;
	[self.view.layer addSublayer:captureVideoPreviewLayer];
	[self.view addSubview: captureImage];
	[self.view addSubview: glView];
	
    UIView *view = [self view];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    if (!_useFrontCam) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (_useFrontCam) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
	
	// Create a VideoDataOutput and add it to the session
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	
	NSDictionary *rgbOutputSettings =
			[NSDictionary dictionaryWithObject:
				[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
			forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	[videoOutput setVideoSettings:rgbOutputSettings];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)

	// Configure your output.
	videoQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoQueue];
    //dispatch_release(videoQueue);
	
	[session addOutput:videoOutput];
 
    // Start the session running to start the flow of data
 	[session startRunning];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
