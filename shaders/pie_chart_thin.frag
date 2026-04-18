precision highp float;

#define RGB8(r,g,b)   (vec4((r)/255.0, (g)/255.0, (b)/255.0, 1.0))
#define RGBA8(r,g,b,a) (vec4((r)/255.0, (g)/255.0, (b)/255.0, (a)/255.0))

// screen reading to create a nice background :p
// this is why were banning filters
// 10,664 at 340x1080
const vec2 pos_uv = vec2(0.03, 0.6152);
// targeting the top left corner of "[0] root"
const vec3 target = RGB8(252.0, 252.0, 252.0).rgb;

const vec4 entity_color = RGB8(228.0, 70.0, 196.0);
const vec4 unspecified_color = RGB8(70.0, 206.0, 102.0);
const vec4 blockentities_color = RGB8(236.0, 110.0, 78.0);
const vec4 mobspawner_color = RGB8(78.0, 228.0, 204.0);

// background
const vec2 screen_size = vec2(340.0, 1080.0);
const vec2 center = vec2(170.0, 760.0); // vec2(0.0, 676.0) + vec2(170.0, 84.0)
const vec2 rx = vec2(166.6, 82.32);

const vec4 background_color = RGB8(43.0, 28.0, 107.0);
const vec4 border_color = RGB8(81.0, 34.0, 141.0);

//------------------------------------------------------------------------------------------------

varying vec2 f_src_pos;

uniform sampler2D u_texture;

const float threshold = 0.01;

const vec3 entities         = vec3(0.894, 0.275, 0.769);

const vec3 unspecified      = vec3(0.275, 0.808, 0.400);
const vec3 destroyProgress  = vec3(0.800, 0.424, 0.275);
const vec3 prepare          = vec3(0.275, 0.298, 0.275);
const vec3 blockentities    = vec3(0.925, 0.431, 0.306);
const vec3 mobspawner       = vec3(0.306, 0.894, 0.800);

void main() {
    bool match = all(lessThan(abs(texture2D(u_texture, pos_uv).rgb - target), vec3(threshold)));
    
    vec2 screen_px = f_src_pos * screen_size;
    vec2 d = (screen_px - center) / rx;
    float r = dot(d, d);
    if (r <= 1.0 && r >= 0.9 && match) {
        gl_FragColor = border_color;
        return;
    }

    vec4 color = texture2D(u_texture, f_src_pos);

    bool is_blockentities = all(lessThan(abs(color.rgb - blockentities), vec3(threshold)));
    bool is_entities = all(lessThan(abs(color.rgb - entities), vec3(threshold)));
    bool is_unspecified = all(lessThan(abs(color.rgb - unspecified), vec3(threshold)));
    bool is_destroyProgess = all(lessThan(abs(color.rgb - destroyProgress), vec3(threshold)));
    bool is_prepare = all(lessThan(abs(color.rgb - prepare), vec3(threshold)));
    bool is_mobspawner = all(lessThan(abs(color.rgb - mobspawner), vec3(threshold)));

    if ( is_entities ) {
        gl_FragColor = entity_color;
    }
    else if ( is_unspecified || is_destroyProgess ) {
        gl_FragColor = unspecified_color;
    }
    else if ( is_blockentities ) {
        gl_FragColor = blockentities_color;
    }
    else if ( is_mobspawner ) {
        gl_FragColor = mobspawner_color;
    }
    else {
        if (r <= 1.0 && match) {
            gl_FragColor = background_color;
        } else {
            gl_FragColor = vec4(0.0);
        }
    }
}