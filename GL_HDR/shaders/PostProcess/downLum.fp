uniform sampler2D DownSampler;
void main(void)
{
vec2 samples[16];

     samples[0] = vec2(-0.0234375, -0.0234375);
     samples[1] = vec2(-0.0078125, -0.0234375);
     samples[2] = vec2(0.0078125, -0.0234375);
     samples[3] = vec2(0.0234375, -0.0234375);
     samples[4] = vec2(-0.0234375, -0.0078125);
     samples[5] = vec2(-0.0078125, -0.0078125);
     samples[6] = vec2( 0.0078125, -0.0078125);
     samples[7] = vec2(0.0234375, -0.0078125);
     samples[8] = vec2(-0.0234375, 0.0078125 );
     samples[9] = vec2(-0.0078125, 0.0078125);
     samples[10] = vec2(0.0078125, 0.0078125);
     samples[11] = vec2(0.0234375, 0.0078125);
     samples[12] = vec2(-0.0234375, 0.0234375);
     samples[13] = vec2(-0.0078125, 0.0234375);
     samples[14] = vec2(0.0078125, 0.0234375);
     samples[15] = vec2(0.0234375, 0.0234375);

	float lum = 0.0;
	vec4	color;
        float	maximum = 0.0;
	for(int i = 0; i < 16; i++)
	{
		color = texture2D(DownSampler, gl_TexCoord[0].xy + samples[i]);
            	maximum = max( maximum, color.g );
            	lum += color.r;
	}
	lum *= 0.0625;
	
	gl_FragColor = vec4(lum, maximum, 0.0, 1.0);
}

