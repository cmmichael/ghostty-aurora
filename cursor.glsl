// -----------------------------------------------------------------------------
// Simple cursor shader derived from:
// https://github.com/0xhckr/ghostty-shaders/blob/main/cursor_blaze.glsl
// -----------------------------------------------------------------------------

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
  vec2 d = abs(p - xy) - b;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 norm(vec2 value, float isPosition) {
  return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
  return 1. - smoothstep(0., norm(vec2(2., 2.), 0.).x, distance);
}

vec2 getRectangleCenter(vec4 rectangle) {
  return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}
float ease(float x) {
  return pow(1.0 - x, 3.0);
}

// Catppuccin Mocha Lavender (#b4befe)
const vec4 TRAIL_COLOR = vec4(0.706, 0.745, 0.996, 1.0); 
// Catppuccin Mocha Blue (#89b4fa)
const vec4 TRAIL_COLOR_ACCENT = vec4(0.537, 0.706, 0.980, 1.0); 

const float DURATION = 0.3; //IN SECONDS

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
  // Normalization for fragCoord to a space of -1 to 1;
  vec2 vu = norm(fragCoord, 1.);
  vec2 offsetFactor = vec2(-.5, 0.5);

  // Normalization for cursor position and size;
  // cursor xy has the postion in a space of -1 to 1;
  // zw has the width and height
  vec4 currentCursor = vec4(norm(iCurrentCursor.xy, 1.), norm(iCurrentCursor.zw, 0.));
  vec4 previousCursor = vec4(norm(iPreviousCursor.xy, 1.), norm(iPreviousCursor.zw, 0.));

  vec2 centerCC = getRectangleCenter(currentCursor);
  vec2 centerCP = getRectangleCenter(previousCursor);

  float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);

  float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
  float easedProgress = ease(progress);
  float lineLength = distance(centerCC, centerCP);

  // Compute fade factor based on distance along the trail

  //cursorblaze
  vec4 trail = mix(TRAIL_COLOR_ACCENT, fragColor, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
  trail = mix(TRAIL_COLOR, trail, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
  fragColor = mix(trail, fragColor, 1. - smoothstep(0., sdfCurrentCursor, easedProgress * lineLength));
}