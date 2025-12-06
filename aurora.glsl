// -----------------------------------------------
// Settings
// -----------------------------------------------

const float SPEED = 0.1;           
const float CORNER_RADIUS = 0.3;    
const float DECAY_START = 0.1;      
const float DECAY_RATE = 8.0;       
const float BRIGHTNESS = 0.8;      

// Rectangular Cutoff Settings
const float GLOW_CUTOFF_DISTANCE = 0.3; 
const float GLOW_CUTOFF_SOFTNESS = 0.5; 

// Dithering Strength
const float DITHER_STRENGTH = 1.0 / 50.0;

// Opacity settings
const float GLOW_OPACITY = 1.0; 

// Aurora colors
const vec3 C_GREEN  = vec3(0.203, 0.658, 0.325);
const vec3 C_YELLOW = vec3(0.984, 0.737, 0.019);
const vec3 C_RED    = vec3(0.917, 0.262, 0.207);
const vec3 C_BLUE   = vec3(0.258, 0.521, 0.956);

// Snake Banding Proportions
const float GREEN_END = 0.2;
const float YELLOW_END = 0.3;
const float RED_END = 0.4;
const float BLUE_END = 0.60;

// -----------------------------------------------
// Math & Utility Helpers
// -----------------------------------------------

// High-frequency pseudo-random noise
float interleavedGradientNoise(vec2 n) {
  return fract(52.9829189 * fract(0.06711056 * n.x + 0.00583715 * n.y));
}

// Signed Distance Function for a rounded box
float sdRoundedBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// -----------------------------------------------
// Geometry & Coordinates
// -----------------------------------------------

struct GeometryData {
  vec2 center;
  float dist; // Distance to the box edge
};

// Calculates the centered coordinates, box size, and SDF distance
GeometryData getGeometry(vec2 uv, vec2 resolution) {
  float aspect = resolution.x / resolution.y;
  
  // Center coordinates with aspect correction
  vec2 center = uv - 0.5;
  center.x *= aspect;
  
  // Define box dimensions
  vec2 boxSize = vec2(0.5 * aspect, 0.5) - 0.02; 
  
  float d = sdRoundedBox(center, boxSize, CORNER_RADIUS);
  
  return GeometryData(center, d);
}

// -----------------------------------------------
// Color Logic (The Snake)
// -----------------------------------------------

// Determines the color band based on the normalized angle (t)
vec4 getSnakeGradientColor(float t) {
  // Mixing factors
  float mixGreenYellow = smoothstep(GREEN_END, YELLOW_END, t);
  float mixYellowRed   = smoothstep(YELLOW_END, RED_END, t);
  float mixRedBlue     = smoothstep(RED_END, BLUE_END, t);

  // Hard steps for band logic
  float isGreen  = 1.0 - step(GREEN_END, t);
  float isYellow = step(GREEN_END, t) - step(YELLOW_END, t);
  float isRed    = step(YELLOW_END, t) - step(RED_END, t);
  float isBlue   = step(RED_END, t);

  // Combine colors
  vec3 color = C_GREEN * isGreen +
               mix(C_GREEN, C_YELLOW, mixGreenYellow) * isYellow +
               mix(C_YELLOW, C_RED, mixYellowRed) * isRed +
               mix(C_RED, C_BLUE, mixRedBlue) * isBlue;

  // Head and tail transparency
  float headFade = smoothstep(0.0, 0.4, t);
  float tailFade = 1.0 - smoothstep(0.6, 1.0, t);
  float alpha = headFade * tailFade;

  return vec4(color, alpha);
}

// Calculates the final snake color vector based on position and time
vec4 calculateSnakeLayer(vec2 centerPos, float time) {
  float angle = atan(centerPos.y, centerPos.x);
  float normAngle = fract((angle / 6.28318) + 0.5 - (time * SPEED));
  return getSnakeGradientColor(normAngle);
}

// -----------------------------------------------
// Glow Intensity Math
// -----------------------------------------------

float calculateGlowIntensity(float dist) {
  // Exponential light decay
  float distanceField = dist - DECAY_START;
  float intensity = exp(min(distanceField, 0.0) * DECAY_RATE);
  
  // Safe Zone (Rectangular Cutoff)
  float cutoff = -GLOW_CUTOFF_DISTANCE;
  float safeZoneMask = smoothstep(cutoff, cutoff + GLOW_CUTOFF_SOFTNESS, dist);
  
  return intensity * safeZoneMask;
}

// -----------------------------------------------
// Post-Processing & Compositing
// -----------------------------------------------

vec3 applyDither(vec3 color, vec2 fragCoord) {
  float noise = (interleavedGradientNoise(fragCoord) - 0.5) * DITHER_STRENGTH;
  return color + noise;
}

vec3 compositeLayer(vec4 terminalPixel, vec3 snakeColor, float snakeAlpha) {
  // Determine if the current pixel is "background" (dark) or "text" (bright)
  // Adjust threshold (0.5) if needed
  float isBackground = 1.0 - step(0.5, dot(terminalPixel.rgb, vec3(1.0)));

  // Mix the terminal background with the glow
  vec3 backgroundWithGlow = mix(terminalPixel.rgb, snakeColor, snakeAlpha * GLOW_OPACITY);

  // Only apply glow to background pixels, keep text crisp
  return mix(terminalPixel.rgb, backgroundWithGlow, isBackground);
}

// -----------------------------------------------
// Main
// -----------------------------------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;
  
  // Calculate Geometry & SDF
  GeometryData geo = getGeometry(uv, iResolution.xy);
  
  // Calculate Glow Intensity (Mask)
  float glowIntensity = calculateGlowIntensity(geo.dist);
  
  // Calculate Snake Color and Alpha
  vec4 snakeLayer = calculateSnakeLayer(geo.center, iTime);
  
  // Combine base alpha with intensity and brightness
  float finalSnakeAlpha = snakeLayer.a * glowIntensity * BRIGHTNESS;
  vec3 snakeRGB = snakeLayer.rgb;

  // Apply Dithering
  snakeRGB = applyDither(snakeRGB, fragCoord);
  
  // Composite with Terminal Texture
  vec4 terminalColor = texture(iChannel0, uv);
  vec3 finalColor = compositeLayer(terminalColor, snakeRGB, finalSnakeAlpha);

  // Output
  fragColor = vec4(finalColor, terminalColor.a);
}