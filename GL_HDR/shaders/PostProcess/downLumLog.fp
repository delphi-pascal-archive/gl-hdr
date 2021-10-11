const vec3 LUMINANCE_VECTOR  = vec3(0.2125, 0.7154, 0.0721);

uniform sampler2D DownSampler;

void main(void)
{

vec2 samples[9];
     samples[0] = vec2(-0.0052083335, -0.0052083335);
     samples[1] = vec2(-0.0052083335, 0.0 );
     samples[2] = vec2(-0.0052083335, 0.0052083335);
     samples[3] = vec2( 0.0, -0.0052083335);
     samples[4] = vec2( 0.0, 0.0);
     samples[5] = vec2( 0.0, 0.0052083335);
     samples[6] = vec2(0.0052083335, -0.0052083335);
     samples[7] = vec2(0.0052083335, 0.0);
     samples[8] = vec2(0.0052083335, 0.0052083335);

	float	lum = 0.0;
	float	GreyValue = 0.0;
        float	maximum = 0.0;
	vec3	color;
	vec2	sample;

	for(int i = 0; i < 9; i++)
	{
		color = texture2D(DownSampler, gl_TexCoord[0].xy + samples[i].xy).xyz;
		lum += log(dot(color,LUMINANCE_VECTOR) + 0.0001);
		GreyValue = max( color.r, max( color.g, color.b ) );
		maximum = max( maximum, GreyValue );
	}
	lum *= 0.111111;

	gl_FragColor = vec4(lum, maximum, 0.0, 1.0);
}