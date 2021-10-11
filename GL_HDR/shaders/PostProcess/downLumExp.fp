uniform sampler2D DownSampler;
void main(void)
{
vec2 samples[16];
     samples[0] = vec2(16.0, -0.375);
     samples[1] = vec2(-0.375, -0.125);
     samples[2] = vec2(-0.375, 0.125);
     samples[3] = vec2(-0.375, 0.375);
     samples[4] = vec2(-0.375, -0.375);
     samples[5] = vec2(-0.125, -0.125);
     samples[6] = vec2(-0.125, 0.125);
     samples[7] = vec2(-0.125, 0.375);
     samples[8] = vec2(-0.125, -0.375);
     samples[9] = vec2(0.125, -0.125);
     samples[10] = vec2(0.125, 0.125);
     samples[11] = vec2(0.125, 0.375);
     samples[12] = vec2(0.125, -0.375);
     samples[13] = vec2(0.375, -0.125);
     samples[14] = vec2(0.375, 0.125);
     samples[15] = vec2(0.375, 0.375);

	float	lum = 0.0;
        float	maximum = 0.0;
	vec4	color;
	for(int i = 0; i < 16; i++)
	{
		color = texture2D(DownSampler, gl_TexCoord[0].xy + samples[i]);
            	maximum = max( maximum, color.g );
            	lum += color.r;
	}

	lum *= 0.0625;
	lum = exp(lum);

	gl_FragColor = vec4(lum, maximum, 0.0, 1.0);
}

