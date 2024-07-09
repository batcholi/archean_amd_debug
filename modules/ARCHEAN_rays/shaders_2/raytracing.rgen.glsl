#define SHADER_RGEN
#include "../common.inc.glsl"

layout(location = 0) rayPayloadEXT RayPayload ray;

void main() {
	// Initialize first ray
	const ivec2 pixelInMiddleOfScreen = ivec2(gl_LaunchSizeEXT.xy) / 2;
	const bool isMiddleOfScreen = (COORDS == pixelInMiddleOfScreen);
	const mat4 projMatrix = isMiddleOfScreen? mat4(xenonRendererData.config.projectionMatrix) : mat4(xenonRendererData.config.projectionMatrixWithTAA);
	const vec2 pixelCenter = vec2(gl_LaunchIDEXT.xy) + vec2(0.5);
	const vec2 screenSize = vec2(gl_LaunchSizeEXT.xy);
	const vec2 uv = pixelCenter/screenSize;
	const vec3 initialRayPosition = inverse(renderer.viewMatrix)[3].xyz;
	const vec3 viewDir = normalize(vec4(inverse(projMatrix) * vec4(uv*2-1, 1, 1)).xyz);
	const vec3 initialRayDirection = normalize(VIEW2WORLDNORMAL * viewDir);
	vec3 rayDirection = initialRayDirection;
	vec3 rayOrigin = initialRayPosition;
	
	// Clear images
	imageStore(img_normal_or_debug, COORDS, vec4(0));
	imageStore(img_depth, COORDS, vec4(0));
	imageStore(img_motion, COORDS, vec4(0));
	
	ray.renderableIndex = -1;
	ray.surfaceFlags = uint8_t(0);
	ray.normal = vec3(0);
	ray.color = vec3(1,0,0);
	traceRayEXT(tlas, gl_RayFlagsOpaqueEXT/*flags*/, RAYTRACE_MASK_TERRAIN, 0/*rayType*/, 0/*nbRayTypes*/, 0/*missIndex*/, rayOrigin, xenonRendererData.config.zNear, rayDirection, xenonRendererData.config.zFar, 0/*payloadIndex*/);
	imageStore(img_composite, COORDS, vec4(ray.color, 1));
}
