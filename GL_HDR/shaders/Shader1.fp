varying vec3 light_direction[1];
varying vec4 shadow[1];
varying vec3 eye_direction;
varying vec3 lightVec;
uniform sampler2D color_map,normal_map,specular_map;
uniform samplerCube shadow_map0;
uniform float exponent;
uniform float zbias;
//const float zbias = 0.0100000;
const  vec4 unpack = vec4 ( 1.0, 1/256.0, 1/ (256.0*256.0), 1/(256.0*256.0*256.0));
void main()
{
	vec4 sat = textureCube( shadow_map0, shadow[0].xyz );
		sat.w = dot(sat,unpack);
		sat.w = sat.w + zbias;
   if ( sat.w < length(shadow[0].xyz) )
      {
      discard;
      }

   vec3  base   = texture2D(color_map    , gl_TexCoord[0].xy ).xyz;
   vec3  bump   = normalize( 2.0 * texture2D(normal_map   , gl_TexCoord[0].xy ).xyz  - 1.0 );
	  vec3  spec   = texture2D(specular_map , gl_TexCoord[0].xy ).xyz;
   vec3 allcolor= vec3(0.0);
  float distance_sqr, atten,d,s;
  vec3 color,l,r;
	  r = reflect( -normalize(eye_direction), bump);
	distance_sqr = dot(light_direction[0], light_direction[0]);
	atten = max(0.0, 1.0 - distance_sqr) ;
	l = light_direction[0] * inversesqrt(distance_sqr);
	d = max(0.0, dot(l, bump) );
	color 	= base * (gl_FrontLightProduct[0].ambient.xyz + gl_FrontLightProduct[0].diffuse.xyz *  d);
 s = pow(clamp(dot(r, l ), 0.0, 1.0), exponent );
  allcolor	+= (color + spec*s)* atten;	   gl_FragColor = vec4(allcolor.xyz , 1) ;
}
