uniform sampler2D CurLum;
uniform sampler2D AdaptLum;
uniform float dtime;
void main(void)
{

	vec3	Clum = texture2D(CurLum, vec2(0.5, 0.5)).xyz;
	vec3	Alum = texture2D(AdaptLum, vec2(0.5, 0.5)).xyz;
	vec3	col = Alum + (Clum - Alum) * (1.0 - pow(0.98, 30.0 * dtime));
	col.x = clamp(col.x, 0.25, 5.0);
	gl_FragColor = vec4(col.x,col.y, col.z, 1.0);

}

