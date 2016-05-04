#include <GLKit/GLKit.h>
#include <vector>

#include "VertexData_t.h"

#include "com/tastenkunst/cpp/brf/nxt/utils/StringUtils.hpp"
#include "com/tastenkunst/cpp/brf/nxt/ios/utils/DrawingUtils.hpp"

@interface OpenGLView : GLKView

- (void) updateVertices:(std::vector<double>)v;

@end

