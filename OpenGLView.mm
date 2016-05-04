#import "OpenGLView.h"

@interface OpenGLView() {

	CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
	GLKBaseEffect* _baseEffect;
	
	GLuint _vertexBufferID;
	GLuint _indexBufferID;

}

@end

@implementation OpenGLView

// define the face shape vertex bufferfor drawing

int numVertices = 68;
int sizeFaceShapeVertices = numVertices * sizeof(VertexData_t);

VertexData_t faceShapeVertices[] = {
	{{150.0f, 200.6f, 0.0f}, {0.01921491f, 0.17824240f}},
	{{151.8f, 230.3f, 0.0f}, {0.02796369f, 0.35185420f}},
	{{157.3f, 260.0f, 0.0f}, {0.05673806f, 0.51831481f}},
	{{167.5f, 289.3f, 0.0f}, {0.11143465f, 0.67511486f}},
	{{178.6f, 308.1f, 0.0f}, {0.17946249f, 0.80202905f}},
	{{192.1f, 322.4f, 0.0f}, {0.26495727f, 0.88806515f}},
	{{209.6f, 334.5f, 0.0f}, {0.36862634f, 0.96167088f}},
	{{233.7f, 339.8f, 0.0f}, {0.50243434f, 0.98766687f}},
	{{258.6f, 335.3f, 0.0f}, {0.64431415f, 0.95692746f}},
	{{277.3f, 324.1f, 0.0f}, {0.75722897f, 0.87900119f}},
	{{293.0f, 310.4f, 0.0f}, {0.84827741f, 0.78639558f}},
	{{305.8f, 289.4f, 0.0f}, {0.91612883f, 0.66268449f}},
	{{316.3f, 259.5f, 0.0f}, {0.96252179f, 0.50239818f}},
	{{321.7f, 230.7f, 0.0f}, {0.98445848f, 0.32997086f}},
	{{324.1f, 200.4f, 0.0f}, {0.98777679f, 0.15959649f}},
	{{307.7f, 184.3f, 0.0f}, {0.87622802f, 0.07844775f}},
	{{291.2f, 172.7f, 0.0f}, {0.78205102f, 0.02060231f}},
	{{272.0f, 174.2f, 0.0f}, {0.67706314f, 0.03308084f}},
	{{253.3f, 184.6f, 0.0f}, {0.58142547f, 0.09597456f}},
	{{272.9f, 183.7f, 0.0f}, {0.68495347f, 0.08827899f}},
	{{290.3f, 182.5f, 0.0f}, {0.78096632f, 0.07745276f}},
	{{162.4f, 184.2f, 0.0f}, {0.10824602f, 0.09068034f}},
	{{178.2f, 172.5f, 0.0f}, {0.19636435f, 0.02991542f}},
	{{196.6f, 174.3f, 0.0f}, {0.29830673f, 0.03948736f}},
	{{215.3f, 184.9f, 0.0f}, {0.39390658f, 0.09889252f}},
	{{196.2f, 183.9f, 0.0f}, {0.29317674f, 0.09518291f}},
	{{179.0f, 182.4f, 0.0f}, {0.19898968f, 0.08741622f}},
	{{177.9f, 200.9f, 0.0f}, {0.18896724f, 0.17541811f}},
	{{192.9f, 194.1f, 0.0f}, {0.26855892f, 0.13695503f}},
	{{208.4f, 202.1f, 0.0f}, {0.35424031f, 0.18029044f}},
	{{192.6f, 207.7f, 0.0f}, {0.26929425f, 0.21081084f}},
	{{193.2f, 200.1f, 0.0f}, {0.26944773f, 0.16874469f}},
	{{290.8f, 201.1f, 0.0f}, {0.79544222f, 0.16630527f}},
	{{275.5f, 194.3f, 0.0f}, {0.71304434f, 0.13008122f}},
	{{260.3f, 201.8f, 0.0f}, {0.62845797f, 0.17665031f}},
	{{275.6f, 208.0f, 0.0f}, {0.71465638f, 0.20471582f}},
	{{275.1f, 200.0f, 0.0f}, {0.71246930f, 0.16179229f}},
	{{224.3f, 200.7f, 0.0f}, {0.43631303f, 0.18566924f}},
	{{221.2f, 231.1f, 0.0f}, {0.41989174f, 0.35548076f}},
	{{208.9f, 249.6f, 0.0f}, {0.35527748f, 0.45101864f}},
	{{215.7f, 259.6f, 0.0f}, {0.38752634f, 0.51253868f}},
	{{233.4f, 263.1f, 0.0f}, {0.49179594f, 0.53808446f}},
	{{251.9f, 259.4f, 0.0f}, {0.59890115f, 0.50871942f}},
	{{259.1f, 249.6f, 0.0f}, {0.63113236f, 0.44595270f}},
	{{246.5f, 231.4f, 0.0f}, {0.56147337f, 0.35510968f}},
	{{244.1f, 200.7f, 0.0f}, {0.54188768f, 0.18313082f}},
	{{220.3f, 254.6f, 0.0f}, {0.41483034f, 0.49237759f}},
	{{246.7f, 254.7f, 0.0f}, {0.56727968f, 0.48953864f}},
	{{204.4f, 289.1f, 0.0f}, {0.32079730f, 0.67181952f}},
	{{215.8f, 284.0f, 0.0f}, {0.38839353f, 0.65379770f}},
	{{226.2f, 282.6f, 0.0f}, {0.44983658f, 0.64610462f}},
	{{233.7f, 283.7f, 0.0f}, {0.49202588f, 0.65396618f}},
	{{241.0f, 282.7f, 0.0f}, {0.53582075f, 0.64507814f}},
	{{251.7f, 284.0f, 0.0f}, {0.60071968f, 0.65075483f}},
	{{264.2f, 289.1f, 0.0f}, {0.67666421f, 0.66629884f}},
	{{255.2f, 295.3f, 0.0f}, {0.62613884f, 0.71045092f}},
	{{245.4f, 298.3f, 0.0f}, {0.56527248f, 0.73496347f}},
	{{233.6f, 299.4f, 0.0f}, {0.49453002f, 0.74328731f}},
	{{222.2f, 298.4f, 0.0f}, {0.42711341f, 0.73678104f}},
	{{213.0f, 295.3f, 0.0f}, {0.37092738f, 0.71447612f}},
	{{220.8f, 288.1f, 0.0f}, {0.41620348f, 0.68219076f}},
	{{233.8f, 290.0f, 0.0f}, {0.49577021f, 0.69291483f}},
	{{247.0f, 288.2f, 0.0f}, {0.57700016f, 0.67951961f}},
	{{247.0f, 286.3f, 0.0f}, {0.57581994f, 0.66736197f}},
	{{233.9f, 288.1f, 0.0f}, {0.49513429f, 0.67855539f}},
	{{220.7f, 286.1f, 0.0f}, {0.41578055f, 0.67005441f}},
	{{233.8f, 289.0f, 0.0f}, {0.49543990f, 0.68501258f}},
	{{233.2f, 248.6f, 0.0f}, {0.48781779f, 0.46090586f}}
};


GLubyte faceShapeTriangles[] = {
	0, 1, 27, 0, 21, 27, 1, 2, 39, 1, 27, 30,
	1, 30, 39, 2, 3, 48, 2, 39, 48, 3, 4, 48,
	4, 5, 48, 5, 6, 58, 5, 48, 59, 5, 58, 59,
	6, 7, 57, 6, 57, 58, 7, 8, 56, 7, 56, 57,
	8, 9, 55, 8, 55, 56, 9, 10, 54, 9, 54, 55,
	10, 11, 54, 11, 12, 54, 12, 13, 43, 12, 43, 54,
	13, 14, 32, 13, 32, 35, 13, 35, 43, 14, 15, 32,
	15, 16, 20, 15, 20, 32, 16, 17, 20, 17, 18, 19,
	17, 18, 23, 17, 19, 20, 18, 19, 34, 18, 23, 24,
	18, 24, 37, 18, 34, 45, 18, 37, 45, 19, 20, 33,
	19, 33, 34, 20, 32, 33, 21, 22, 26, 21, 26, 27,
	22, 23, 26, 23, 24, 25, 23, 25, 26, 24, 25, 29,
	24, 29, 37, 25, 26, 28, 25, 28, 29, 26, 27, 28,
	27, 28, 31, 27, 30, 31, 28, 29, 31, 29, 30, 31,
	29, 30, 38, 29, 37, 38, 30, 38, 39, 32, 33, 36,
	32, 35, 36, 33, 34, 36, 34, 35, 36, 34, 35, 44,
	34, 44, 45, 35, 43, 44, 37, 38, 45, 38, 39, 67,
	38, 44, 45, 38, 44, 67, 39, 40, 46, 39, 40, 48,
	39, 46, 67, 40, 41, 46, 40, 41, 50, 40, 48, 49,
	40, 49, 50, 41, 42, 47, 41, 42, 52, 41, 46, 67,
	41, 47, 67, 41, 50, 51, 41, 51, 52, 42, 43, 47,
	42, 43, 54, 42, 52, 53, 42, 53, 54, 43, 44, 47,
	44, 47, 67, 48, 49, 65, 48, 59, 60, 48, 60, 65,
	49, 50, 65, 50, 51, 64, 50, 64, 65, 51, 52, 64,
	52, 53, 63, 52, 63, 64, 53, 54, 63, 54, 55, 62,
	54, 62, 63, 55, 56, 62, 56, 57, 61, 56, 61, 62,
	57, 58, 61, 58, 59, 60, 58, 60, 61, 60, 61, 66,
	60, 65, 66, 61, 62, 66, 62, 63, 66, 63, 64, 66,
	64, 65, 66
};

- (void) updateVertices:(std::vector<double>)v {
	int i = 0;
	int l = numVertices;
	
	float offsetX =
		((((float)self.frame.size.height / (float)DrawingUtils::CANVAS_HEIGHT)
			* (float)DrawingUtils::CANVAS_WIDTH) - (float)self.frame.size.width) / 2.0f;

	for(; i < l; ++i) {
		float x = (float)v[i * 2];
		float y = (float)v[i * 2 + 1];
		
		VertexData_t& data = faceShapeVertices[i];
		
		data.position[0] = x + offsetX;
		data.position[1] = y;
	}
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
	_eaglLayer.opaque = NO;
	_eaglLayer.drawableProperties =
		[NSDictionary dictionaryWithObjectsAndKeys: kEAGLColorFormatRGBA8,
		kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	GLKView* view = (GLKView*) self;
	view.context = _context;
	
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
	
	float offsetX =
		((((float)self.frame.size.height / (float)DrawingUtils::CANVAS_HEIGHT)
			* (float)DrawingUtils::CANVAS_WIDTH) - (float)self.frame.size.width);
	
	brf::trace("INIT: " + brf::to_string(self.frame.size.height) + " " +  brf::to_string(self.frame.size.width));
	
	_baseEffect = [[GLKBaseEffect alloc] init];
	_baseEffect.transform.projectionMatrix =
//		GLKMatrix4MakeOrtho(0, self.frame.size.width, self.frame.size.height, 0, 0, 1);
		GLKMatrix4MakeOrtho(offsetX, DrawingUtils::CANVAS_WIDTH, DrawingUtils::CANVAS_HEIGHT, 0, 0, 1);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
}

- (void)setupVBOs {

    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
	glBufferData(GL_ARRAY_BUFFER, sizeFaceShapeVertices, NULL, GL_DYNAMIC_DRAW);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeFaceShapeVertices, faceShapeVertices);
	
    glGenBuffers(1, &_indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(faceShapeTriangles), NULL, GL_STATIC_DRAW);
	glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(faceShapeTriangles), faceShapeTriangles);
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData_t), (GLvoid*) offsetof(VertexData_t, position));
	
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData_t), (GLvoid*) offsetof(VertexData_t, uv));
	
	CGImageRef texRef = [[UIImage imageNamed:@"texture_marcel_v3.png"] CGImage];
	//texture upside down: options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft]
	GLKTextureInfo* textureInfo =[GLKTextureLoader textureWithCGImage:texRef
			options:nil error:NULL];
	
	_baseEffect.texture2d0.name = textureInfo.name;
	_baseEffect.texture2d0.target = GLKTextureTarget2D;// textureInfo.target;
}

- (void)render:(CADisplayLink*)displayLink {

	glClear(GL_COLOR_BUFFER_BIT);
	
	glBufferData(GL_ARRAY_BUFFER, sizeFaceShapeVertices, NULL, GL_DYNAMIC_DRAW);
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeFaceShapeVertices, faceShapeVertices);
	
	[_baseEffect prepareToDraw];
	
	glDrawElements(GL_TRIANGLES, sizeof(faceShapeTriangles)/sizeof(faceShapeTriangles[0]), GL_UNSIGNED_BYTE, 0);

	[_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
		[self setupLayer];
		[self setupContext];
		[self setupVBOs];
		[self setupDisplayLink];
	}
    return self;
}

- (void)dealloc
{
    _context = nil;
}

@end
