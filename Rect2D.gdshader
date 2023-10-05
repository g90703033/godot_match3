shader_type canvas_item;

uniform float hue_shift : hint_range(-1.0, 1.0) = 0.0;
uniform vec4 tint;

void fragment() {
    vec4 texcol = texture(TEXTURE, UV);
    vec3 col = texcol.rgb;

    // Convert RGB to HSV
    float cmax = max(col.r, max(col.g, col.b));
    float cmin = min(col.r, min(col.g, col.b));
    float delta = cmax - cmin;
    float hue = 0.0;

    if (delta > 0.0) {
        if (cmax == col.r) {
            hue = (col.g - col.b) / delta;
        } else if (cmax == col.g) {
            hue = 2.0 + (col.b - col.r) / delta;
        } else {
            hue = 4.0 + (col.r - col.g) / delta;
        }
        hue *= 60.0;
        if (hue < 0.0) {
            hue += 360.0;
        }
    }

    // Apply hue shift
    hue += hue_shift * 360.0;
    hue = mod(hue, 360.0);
    if (hue < 0.0) {
        hue += 360.0;
    }

    // Convert back to RGB
    float H = hue / 60.0;
    float C = 1.0 - abs(2.0 * col.r - 1.0 - col.g - col.b);
    float X = C * (1.0 - abs(mod(H, 2.0) - 1.0));
    float m = col.r - 0.5 * C;
    if (H < 1.0) {
        col = vec3(C + m, X + m, m);
    } else if (H < 2.0) {
        col = vec3(X + m, C + m, m);
    } else if (H < 3.0) {
        col = vec3(m, C + m, X + m);
    } else if (H < 4.0) {
        col = vec3(m, X + m, C + m);
    } else if (H < 5.0) {
        col = vec3(X + m, m, C + m);
    } else {
        col = vec3(C + m, m, X + m);
    }

    COLOR = vec4(col, texcol.a) * tint;
}