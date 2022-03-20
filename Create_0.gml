/// @description Build the level

#region //Variables for maze builder and room edge walls

room_width = CELL_WIDTH * 6;
room_height = CELL_HEIGHT * 5;


wall = 2;
iteration = 0;
//variable to use to check if the pop_seed is region a or b
isregiona = true;

// Set the global.grid width and height
width = room_width div CELL_WIDTH;
height = room_height div CELL_HEIGHT;

//Create the grids
global.grid = ds_grid_create(width, height);
datagrid = ds_grid_create(width, height);
global.walkgrid = mp_grid_create(0, 0, width, height, CELL_WIDTH, CELL_HEIGHT);

//Create core lists
reg0 = ds_list_create();
//Create set to keep track of which cells have been assigned to a region
set = ds_list_create();

//Fill the grids with the void
ds_grid_set_region(global.grid, 0, 0, width - 1, height - 1, VOID);

//Give every cell in the datagrid a number
for(var yy = 0; yy < height; yy++) {
	for(var xx =  0; xx < width; xx++){
	var grid_index = NameCell(xx,yy);
	datagrid[# xx, yy] = grid_index;
	}
}

// Randomize the engine randomizer seed
randomize();

//Fill the edges with walls
for(var xx = 0; xx < width; xx++;) global.grid[# xx, 0] = WALL;
for(var xx = 0; xx < width; xx++;) global.grid[# xx, height-1] = WALL;
for(var yy = 0; yy < height; yy++;) global.grid[# width-1, yy] = WALL;
for(var yy = 0; yy < height; yy++;) global.grid[# 0, yy] = WALL;

//Create an array for the initial region to divide by check all cells and adding non-wall cells
for(var yy = 1; yy < height - 1; yy++) {
	for(var xx =  1; xx < width - 1; xx++){
		if (global.grid[# xx, yy] != WALL) {
			// Add to reg0
			ds_list_add(reg0, datagrid[# xx, yy]);
		}
	}
}
#endregion

#region //Divide Reg0

//Create 2 lists to store subregions and another to store walls
rega = ds_list_create();
regb = ds_list_create();
regw = ds_list_create();
reg02 = ds_list_create();
ds_list_copy(reg02, reg0);

iteration += 1;

var reg_list_index_cap = ds_list_size(reg02)-1;


//Choose 2 random index values from the region array

var irand1 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = reg02[| irand1];

var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);

//Add to subregion a list and delete the index and it's adjacent cells
ds_list_add(rega, datagrid[# s1x, s1y]);
ds_list_delete(reg02, irand1);

var tempcellleft = ds_list_find_index(reg02, datagrid[# s1x - 1, s1y]);
var tempcellright = ds_list_find_index(reg02, datagrid[# s1x + 1, s1y]);
var tempcellup = ds_list_find_index(reg02, datagrid[# s1x, s1y - 1]);
var tempcelldown = ds_list_find_index(reg02, datagrid[# s1x, s1y + 1]);

if(tempcellleft != -1)
ds_list_delete(reg02, tempcellleft);
if(tempcellright != -1)
ds_list_delete(reg02, tempcellright);
if(tempcellup != -1)
ds_list_delete(reg02, tempcellup);
if(tempcelldown != -1)
ds_list_delete(reg02, tempcelldown);

//Update region copy size to pick new random seed for region b
var reg_list_index_cap = ds_list_size(reg02)-1;
var irand2 = irandom(reg_list_index_cap);
var rand_coord2 = reg02[| irand2];

var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//add to regionb and delete the copy list
ds_list_add(regb, datagrid[# s2x, s2y]);
ds_list_destroy(reg02);

//Add the seed coordinates to the set list
ds_list_add(set, rega[| 0], regb[| 0]);

var isfirstseeda = true;
var isfirstseedb = true;

var whilecount = 0;
//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	
	whilecount += 1;
show_debug_message("loops: " + string(whilecount));

var set_size_index_cap = ds_list_size(set)-1;
//Add the region seeds to a set to keep track of all active seeds
if(isfirstseeda == true and isfirstseedb == true){
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];
if(rand == rega[| 0] and isfirstseeda == true) isfirstseeda = false;
else if(rand == regb[| 0] and isfirstseedb == true) isfirstseedb = false;
}
else if(isfirstseeda == true)
pop_seed = rega[| 0];
else if(isfirstseedb == true)
pop_seed = regb[| 0];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(rega, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(rega, north_Cell);
var isregEa = RegionACheck(rega, east_Cell);
var isregSa = RegionACheck(rega, south_Cell);
var isregWa = RegionACheck(rega, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(rega, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(east_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(rega, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(south_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(rega, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(west_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(rega, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(north_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regb, north_Cell);
var isregEb = RegionBCheck(regb, east_Cell);
var isregSb = RegionBCheck(regb, south_Cell);
var isregWb = RegionBCheck(regb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(rega, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(east_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(rega, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(south_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(rega, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(west_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(rega, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regw)){
		for(xx = 0; xx < ds_list_size(regw); xx++;){
			if(north_Cell == regw[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regw, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}
var regw_size = ds_list_size(regw);
//Determine number of doors to spawn by wall length
if(!ds_list_empty(regw)){
//Set doors
if(regw_size >= 18) xx = 3;
else if(1 < regw_size < 18){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regw);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regw[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regw, rand);
}
}

//Set walls
var regw_size = ds_list_size(regw);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regw[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regw);

#endregion
/*
//4 rooms
#region //Divide a and b


//Check the total area of the region a. If room is too big,
//recursively run this funcion on that region.
if(ds_list_size(rega) >= 30 and !ds_list_empty(rega)){


}
else if(12 < ds_list_size(rega) < 30 and !ds_list_empty(rega)){
	var rand = irandom(3);
	if(rand != 0){ 
		

	}
}

//Do the same for region b
if(ds_list_size(regb) > 15 and !ds_list_empty(regb)){
	

}
else if(8 < ds_list_size(regb) < 15 and !ds_list_empty(regb)){
	var rand = irandom(3);
	if(rand != 0){
		
	}
}

ds_list_destroy(reg0);



#endregion
*/
#region //Draw level and spawn walls and player

// Draw the level using the global.grid
var lay_id = layer_get_id("Tiles_Map");
var map_id = layer_tilemap_get_id(lay_id);

for(var yy = 0; yy < height; yy++) {
	for(var xx =  0; xx < width; xx++){
		if(global.grid[# xx, yy] == WALL) {
			// Draw the wall
			tilemap_set(map_id, wall, xx, yy);
			instance_create_layer(xx * CELL_WIDTH, yy * CELL_HEIGHT, "Instances", o_Wall);
		}
	}
}

mp_grid_add_instances(global.walkgrid, o_Wall, true);

//Create list of possible spawn points
global.spawn_list = ds_list_create();

for(var xx = 1; xx < 3; xx++;){
	for(var yy = 1; yy < (height - 1); yy++;){
		ds_list_add(global.spawn_list, datagrid[# xx, yy]);
	}
}
for(var xx = width - 3; xx < width - 1; xx++;){
	for(var yy = 1; yy < (height - 1); yy++;){
		ds_list_add(global.spawn_list, datagrid[# xx, yy]);
	}
}
for(var xx = 3; xx < (width - 3); xx++;){
	for(var yy = 1; yy < 3; yy++;){
		ds_list_add(global.spawn_list, datagrid[# xx, yy]);
	}
}
for(var xx = 3; xx < (width - 3); xx++;){
	for(var yy = (height - 3); yy < (height - 1); yy++;){
		ds_list_add(global.spawn_list, datagrid[# xx, yy]);
	}
}

var spawn_index = ds_list_size(global.spawn_list) - 1;
var rand = irandom(spawn_index);
var startx = ExtractXCoord(global.spawn_list[| rand]);
var starty = ExtractYCoord(global.spawn_list[| rand]);
if(global.grid[# startx, starty] == WALL){
	while(global.grid[# startx, starty] == WALL){
		var rand = irandom(spawn_index);
		startx = ExtractXCoord(global.spawn_list[| rand]);
		starty = ExtractYCoord(global.spawn_list[| rand]);
	}
}

startx = startx * CELL_WIDTH + CELL_WIDTH/2;
starty = starty * CELL_HEIGHT + CELL_HEIGHT/2;
instance_create_layer(startx, starty, "Instances", o_Player);
instance_create_layer(startx, starty, "Instances", o_Lighting);
		
	
#endregion

/*
#region //list of regions
//4 rooms
//regaa = ds_list_create();
//regab = ds_list_create();

//regba = ds_list_create();
//regbb = ds_list_create();

//8
//regaaa = ds_list_create();
//regaab = ds_list_create();

//regaba = ds_list_create();
//regabb = ds_list_create();

//regbaa = ds_list_create();
regbab = ds_list_create();

//regbba = ds_list_create();
//regbbb = ds_list_create();

//16
//regaaaa = ds_list_create();
//regaaab = ds_list_create();

//regaaba = ds_list_create();
//regaabb = ds_list_create();

//regabaa = ds_list_create();
//regabab = ds_list_create();

//regabba = ds_list_create();
//regabbb = ds_list_create();

//regbaaa = ds_list_create();
//regbaab = ds_list_create();

//regbaba = ds_list_create();
//regbabb = ds_list_create();

regbbaa = ds_list_create();
regbbab = ds_list_create();

regbbba = ds_list_create();
regbbbb = ds_list_create();

//List of walls
//4 rooms
//regwa = ds_list_create();
//regwb = ds_list_create();

//8
//regwaa = ds_list_create();
//regwab = ds_list_create();

//regwba = ds_list_create();
//regwbb = ds_list_create();

//16
//regwaaa = ds_list_create();
//regwaab = ds_list_create();

//regwaba = ds_list_create();
//regwabb = ds_list_create();

//regwbaa = ds_list_create();
//regwbab = ds_list_create();

regwbba = ds_list_create();
regwbbb = ds_list_create();
#endregion