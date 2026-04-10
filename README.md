# nml's waywall config

based on gore's config with random stuff pulled from the mcsr linux discord, don't remember everything SORREY

this will not work for you unless you have my exact setup (1080p, logitech mouse, hyprland)

### features

- ★ auto logitech dpi switch
- ★ disable remap in chat
- ★ transparent nbtracker with hyprland:darkwindow
- ★ link saves to /tmp with maps
- ★ auto disable state functionality
- ★ take a break aga
- tall/thin/wide
- e and pie mirrors
- preemptive cheatsheet (temporary)
- mpk quickbind

## hyprland config

```properties
windowrule = border_size 0, rounding 0, no_blur on, match:class waywall
windowrule = float on, border_size 0, rounding 0, no_blur on, pin on, no_focus on, darkwindow:shade transparentNB, match:tag nboverlay

input {
    sensitivity = -0.75
}
plugin:darkwindow {
    shader[transparentNB] {
        path = /home/nml/.config/waywall/NBTracker-transparency.glsl
        args = bkg = [0.121568627 0.137254902 0.168627451] targetOpacity = 0 similarity = 0.7
        introduces_transparency = true
    }
}
```

## glfw

```bash
# clone GLFW
git clone https://github.com/glfw/glfw
cd glfw

# compile GLFW
cmake -S . -B build -DBUILD_SHARED_LIBS=ON -DGLFW_BUILD_WAYLAND=ON
cd build
make
```

yes i used master branch