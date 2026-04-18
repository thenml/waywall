uniform vec3 bkg;
uniform float similarity;
uniform float targetOpacity;

void windowShader(inout vec4 color) {
	if (
		color.r >= bkg.r - similarity && color.r <= bkg.r + similarity &&
		color.g >= bkg.g - similarity && color.g <= bkg.g + similarity &&
		color.b >= bkg.b - similarity && color.b <= bkg.b + similarity
	) {
		color = vec4(0, 0, 0, targetOpacity);
	}
}