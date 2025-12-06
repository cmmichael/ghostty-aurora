# 🌈 ghostty-aurora

**Aurora** is a shader for the [Ghostty](https://github.com/ghostty-org/ghostty) terminal emulator that adds a sleek, animated gradient glow to the edges of your window.

<video loop autoplay controls muted width="800" src="https://github.com/user-attachments/assets/acc7418d-4bf5-4e9c-8e83-1ceef9cfc1b0"></video>

## ✨ Features

- **Smooth Animation**: A rotating "snake" border effect.
- **Theme Support**: 9+ built-in palettes including Catppuccin, Dracula, and TRON.
- **High Quality**: Implements dithering to prevent color banding on gradients.
- **Customizable**: Adjustable speed, corner radius, glow thickness, and brightness.
- **Performance**: Optimized GLSL code.

## 📦 Installation

### 1. Download the shader
Clone the repository to a location of your choice. We recommend keeping it in your Ghostty config folder:

```bash
mkdir -p ~/.config/ghostty/shaders
git clone https://github.com/cmmichael/ghostty-aurora.git ~/.config/ghostty/shaders/ghostty-aurora
```

### 2. Update your config
Add the shader path to your Ghostty configuration file (usually located at `~/.config/ghostty/config`).

```ini
# ~/.config/ghostty/config
# On mac, this file may be at:
# /Users/$USER/Library/Application Support/com.mitchellh.ghostty/config

# Main Aurora Shader
custom-shader = ~/.config/ghostty/shaders/ghostty-aurora/aurora.glsl

# Optional: Matching Cursor Shader
# custom-shader = ~/.config/ghostty/shaders/ghostty-aurora/cursor.glsl
```

> **Note:** If you cloned it to your home folder instead, use `custom-shader=~/ghostty-aurora/aurora.glsl`.

## 🎨 Themes

`ghostty-aurora` comes with pre-configured palettes to match popular terminal themes. 

To switch themes, open `aurora.glsl` in your text editor and change the `ACTIVE_THEME` definition at the top of the file:

```glsl
// ... inside aurora.glsl ...

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
#define ACTIVE_THEME THEME_CATPPUCCIN
```

### Available Themes
*   **Aurora** (Default subtle rainbow)
*   **Catppuccin Mocha**
*   **Dracula**
*   **Nord**
*   **Gruvbox Dark**
*   **Tokyo Night**
*   **TRON Legacy** (Glowing Blue/Orange)
*   **Synthwave** (Sunset Purple/Orange)
*   **Monokai**

## ⚙️ Advanced Configuration

You can tweak the behavior of the shader by modifying the constants in the **Settings** section of `aurora.glsl`:

| Variable | Description |
| :--- | :--- |
| `SPEED` | Controls how fast the gradient rotates. |
| `CORNER_RADIUS` | Matches the border to your window's rounded corners. |
| `DECAY_RATE` | Controls how far the glow spreads inward. |
| `GLOW_OPACITY` | Controls the transparency of the effect (0.0 - 1.0). |

## 🤝 Credits

*   `cursor.glsl` is a pruned down version of [cursor_blaze.glsl](https://github.com/0xhckr/ghostty-shaders/blob/main/cursor_blaze.glsl) by @0xhckr.

## 📄 License

MIT
