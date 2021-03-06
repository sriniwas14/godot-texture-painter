shader_type canvas_item;

//uniform sampler2D meshtex_pos; // The 3d position data 
//No longer needed

//NOTE - this shader can be slow since it only runs once when a mesh is loaded

void fragment()
{
	float epsilon = 1e-5;
	
	//Only need to fix seams on pixels outside any UV islands
	if (texture(SCREEN_TEXTURE, UV).a > 0.999)
		discard;
		
	int neighborhood = 30; //Look in neighborhood of -30....30 pixels for colors to fill in the seams	
	// TODO allow configuring this (but don't go too high or it'll lag)	
	
	vec3 nearest_color = vec3(0.0); //New color of this pixel
	bool found = false; //Found a neighbor we can use?
	
	float nearest_color_dist = 1.0e10;
	
	for (int x = -neighborhood; x <= neighborhood; x++)
	{
		for (int y = -neighborhood; y <= neighborhood; y++)
		{
			if (x == 0 && y == 0)
				continue; //Skip this pixel
				
			ivec2 point_local = ivec2(x, y);
			ivec2 point = ivec2(floor(UV / SCREEN_PIXEL_SIZE)) + point_local;
			
			//Skip pixels outside bounds (TODO ensure this actually makes it faster)
			if (point.x < 0 || point.x >= textureSize(SCREEN_TEXTURE, 0).x || point.y < 0 || point.y >= textureSize(SCREEN_TEXTURE, 0).y)
				continue;
			
			//Okay, fixed it, must use SCREEN_TEXTURE instead of meshtex_pos here
			vec4 pos_col = texelFetch(SCREEN_TEXTURE, point, 0);
			
			if (pos_col.a < 0.999)
				continue;
				
			float dist = dot(vec2(point_local), vec2(point_local)); //Distance squared of this point to the pixel
			if (dist < nearest_color_dist) //If closer, keep this color as closest
			{
				nearest_color = pos_col.rgb;
				nearest_color_dist = dist;
				found = true;
			}
			
		}
	}
	
	//If no neighbors found, skip this pixel
	if (!found)
		discard;
		
	//Else use the NEAREST of the colors found
	COLOR = vec4(nearest_color, 1.0);
	
}