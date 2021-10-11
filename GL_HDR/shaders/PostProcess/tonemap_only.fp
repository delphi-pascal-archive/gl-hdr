uniform sampler2D srcImage;
uniform sampler2D blurYImage;
uniform float exposure;
const float blurBlendFactor = 1.0;
const float fGaussianScalar = 1.0;

void main(void)
{
	vec4 col = texture2D(srcImage, gl_TexCoord[0].xy);
	vec4 bloom = texture2D(blurYImage, gl_TexCoord[0].xy);
	vec4 lum = vec4(0.9);
	col += bloom * blurBlendFactor;

	float Lp = (exposure / lum.r ) * max( col.r, max( col.g, col.b ) );
	float LmSqr = (lum.g + fGaussianScalar * lum.g) * (lum.g + fGaussianScalar * lum.g);
	float toneScalar = ( Lp * ( 1.0 + ( Lp / ( LmSqr ) ) ) ) / ( 1.0 + Lp );
	col = col * toneScalar;
	gl_FragColor = col;
}
