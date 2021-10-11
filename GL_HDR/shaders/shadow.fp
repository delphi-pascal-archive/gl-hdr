/*
 Made by : SVSD_VAL
 Site    : http://svsd.mirgames.ru & http://delphigfx.mirgames.ru
 mail    : Valdim_05@mail.ru or SVSD_VAL@SibNet.ru
 ICQ     : 223-725-915
 Jabber  : svsd_val@jabber.ru or svsd_val@Jabber.Sibnet.ru
*/

varying vec3 vertex;
const  vec4 pack = vec4 ( 1.0, 256.0, 256.0*256.0, 256.0*256.0*256.0 );
void main()
{
 gl_FragColor = length(vertex) * pack;

}