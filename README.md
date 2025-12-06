# ghostty-aurora
Aurora is a shader for the ghostty terminal emulator that shows a subtle rainbow glow on the edge of your window.

<video loop autoplay controls="" width="800" height="500" src="https://github.com/user-attachments/assets/acc7418d-4bf5-4e9c-8e83-1ceef9cfc1b0"></video>

## Installation

Download:
```
cd
git clone https://github.com/cmmichael/ghostty-aurora
```

Then, add to your ghostty config:
```
custom-shader=~/ghostty-aurora/aurora.glsl
custom-shader=~/ghostty-aurora/cursor.glsl # Optional shader for the cursor.
```

## Customization

`ghostty-aurora` comes with a number of themes. Select a theme at the top:

```
#define THEME_AURORA 0
#define THEME_CATPPUCCIN 1
#define THEME_DRACULA 2
#define THEME_NORD 3
#define THEME_GRUVBOX 4
#define THEME_TOKYO_NIGHT 5
#define THEME_TRON 6
#define THEME_SYNTHWAVE 7
#define THEME_MONOKAI 8

// CHANGE THIS VALUE TO SWITCH THEMES
#define ACTIVE_THEME THEME_AURORA
```

You may also add your own theme directly in the shader.