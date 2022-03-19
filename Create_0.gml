/// @description Build the level

#region //Variables and room edge walls

room_width = CELL_WIDTH * 27;
room_height = CELL_HEIGHT * 27;


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

iteration += 1;

var reg_list_index_cap = ds_list_size(reg0)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = reg0[| irand1];
var rand_coord2 = reg0[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(reg0, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(rega, datagrid[# s1x, s1y]);
ds_list_add(regb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, rega[| 0], regb[| 0]);

var set_size_index_cap = ds_list_size(set)-1;

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

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
	
	reg_list_index_cap -= 1;
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regw);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regw)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
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

//4 rooms
#region //Divide a and b


//Check the total area of the region a. If room is too big,
//recursively run this funcion on that region.
if(ds_list_size(rega) >= 30 and !ds_list_empty(rega)){

#region region a

//Create 2 lists to store subregions and another to store walls
regaa = ds_list_create();
regab = ds_list_create();
regwa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(rega)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = rega[| irand1];
var rand_coord2 = rega[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(rega, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaa, datagrid[# s1x, s1y]);
ds_list_add(regab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaa[| 0], regab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaa, north_Cell);
var isregEa = RegionACheck(regaa, east_Cell);
var isregSa = RegionACheck(regaa, south_Cell);
var isregWa = RegionACheck(regaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(east_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(south_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(west_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(north_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regab, north_Cell);
var isregEb = RegionBCheck(regab, east_Cell);
var isregSb = RegionBCheck(regab, south_Cell);
var isregWb = RegionBCheck(regab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(east_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(south_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(west_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(north_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwa);

#endregion
}
else if(12 < ds_list_size(rega) < 30 and !ds_list_empty(rega)){
	var rand = irandom(3);
	if(rand != 0){ 
		
#region //region a

//Create 2 lists to store subregions and another to store walls
regaa = ds_list_create();
regab = ds_list_create();
regwa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(rega)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = rega[| irand1];
var rand_coord2 = rega[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(rega, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaa, datagrid[# s1x, s1y]);
ds_list_add(regab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaa[| 0], regab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaa, north_Cell);
var isregEa = RegionACheck(regaa, east_Cell);
var isregSa = RegionACheck(regaa, south_Cell);
var isregWa = RegionACheck(regaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(east_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(south_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(west_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(north_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regab, north_Cell);
var isregEb = RegionBCheck(regab, east_Cell);
var isregSb = RegionBCheck(regab, south_Cell);
var isregWb = RegionBCheck(regab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(east_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(south_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(west_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwa)){
		for(xx = 0; xx < ds_list_size(regwa); xx++;){
			if(north_Cell == regwa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwa);

#endregion
	}
}

//Do the same for region b
if(ds_list_size(regb) > 15 and !ds_list_empty(regb)){
	
#region //region b

//Create 2 lists to store subregions and another to store walls
regba = ds_list_create();
regbb = ds_list_create();
regwb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regb[| irand1];
var rand_coord2 = regb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regba, datagrid[# s1x, s1y]);
ds_list_add(regbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regba[| 0], regbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regba, north_Cell);
var isregEa = RegionACheck(regba, east_Cell);
var isregSa = RegionACheck(regba, south_Cell);
var isregWa = RegionACheck(regba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(east_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(south_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(west_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(north_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbb, north_Cell);
var isregEb = RegionBCheck(regbb, east_Cell);
var isregSb = RegionBCheck(regbb, south_Cell);
var isregWb = RegionBCheck(regbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(east_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(south_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(west_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(north_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwb);

#endregion
}
else if(8 < ds_list_size(regb) < 15 and !ds_list_empty(regb)){
	var rand = irandom(3);
	if(rand != 0){
		#region //region b

//Create 2 lists to store subregions and another to store walls
regba = ds_list_create();
regbb = ds_list_create();
regwb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regb[| irand1];
var rand_coord2 = regb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regba, datagrid[# s1x, s1y]);
ds_list_add(regbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regba[| 0], regbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regba, north_Cell);
var isregEa = RegionACheck(regba, east_Cell);
var isregSa = RegionACheck(regba, south_Cell);
var isregWa = RegionACheck(regba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(east_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(south_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(west_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(north_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbb, north_Cell);
var isregEb = RegionBCheck(regbb, east_Cell);
var isregSb = RegionBCheck(regbb, south_Cell);
var isregWb = RegionBCheck(regbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(east_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(south_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(west_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwb)){
		for(xx = 0; xx < ds_list_size(regwb); xx++;){
			if(north_Cell == regwb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwb);

#endregion
	}
}

ds_list_destroy(reg0);



#endregion

//8 rooms
#region //Divide aa and ab


if(ds_list_size(regaa) >= 30 and !ds_list_empty(regaa)){


#region //region aa

//Create 2 lists to store subregions and another to store walls
regaaa = ds_list_create();
regaab = ds_list_create();
regwaa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaa)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaa[| irand1];
var rand_coord2 = regaa[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaa, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaaa, datagrid[# s1x, s1y]);
ds_list_add(regaab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaaa[| 0], regaab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaaa, north_Cell);
var isregEa = RegionACheck(regaaa, east_Cell);
var isregSa = RegionACheck(regaaa, south_Cell);
var isregWa = RegionACheck(regaaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regaab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(east_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regaab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(south_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regaab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(west_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regaab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(north_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regaab, north_Cell);
var isregEb = RegionBCheck(regaab, east_Cell);
var isregSb = RegionBCheck(regaab, south_Cell);
var isregWb = RegionBCheck(regaab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(east_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(south_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(west_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(north_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaa);

#endregion
ds_list_destroy(regaaa);
ds_list_destroy(regaab);
}
else if(12 < ds_list_size(regaa) < 30 and !ds_list_empty(regaa)){
	var rand = irandom(3);
	if(rand != 0){ 
		

#region //region aa

//Create 2 lists to store subregions and another to store walls
regaaa = ds_list_create();
regaab = ds_list_create();
regwaa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaa)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaa[| irand1];
var rand_coord2 = regaa[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaa, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaaa, datagrid[# s1x, s1y]);
ds_list_add(regaab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaaa[| 0], regaab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaaa, north_Cell);
var isregEa = RegionACheck(regaaa, east_Cell);
var isregSa = RegionACheck(regaaa, south_Cell);
var isregWa = RegionACheck(regaaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regaab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(east_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regaab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(south_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regaab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(west_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regaab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(north_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regaab, north_Cell);
var isregEb = RegionBCheck(regaab, east_Cell);
var isregSb = RegionBCheck(regaab, south_Cell);
var isregWb = RegionBCheck(regaab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(east_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(south_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(west_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaa)){
		for(xx = 0; xx < ds_list_size(regwaa); xx++;){
			if(north_Cell == regwaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaa);

#endregion
ds_list_destroy(regaaa);
ds_list_destroy(regaab);
	}
}

if(ds_list_size(regab) > 15 and !ds_list_empty(regab)){
	
	
#region //region ab

//Create 2 lists to store subregions and another to store walls
regaba = ds_list_create();
regabb = ds_list_create();
regwab = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regab)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regab[| irand1];
var rand_coord2 = regab[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regab, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaba, datagrid[# s1x, s1y]);
ds_list_add(regabb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaba[| 0], regabb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaba, north_Cell);
var isregEa = RegionACheck(regaba, east_Cell);
var isregSa = RegionACheck(regaba, south_Cell);
var isregWa = RegionACheck(regaba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regabb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(east_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regabb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(south_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regabb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(west_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regabb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(north_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regabb, north_Cell);
var isregEb = RegionBCheck(regabb, east_Cell);
var isregSb = RegionBCheck(regabb, south_Cell);
var isregWb = RegionBCheck(regabb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(east_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(south_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(west_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(north_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwab);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwab)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwab);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwab[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwab, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwab);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwab[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwab);

#endregion
ds_list_destroy(regaba);
ds_list_destroy(regabb);
}
else if(8 < ds_list_size(regab) < 15 and !ds_list_empty(regab)){
	var rand = irandom(3);
	if(rand != 0){
		
#region //region ab

//Create 2 lists to store subregions and another to store walls
regaba = ds_list_create();
regabb = ds_list_create();
regwab = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regab)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regab[| irand1];
var rand_coord2 = regab[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regab, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaba, datagrid[# s1x, s1y]);
ds_list_add(regabb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaba[| 0], regabb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaba, north_Cell);
var isregEa = RegionACheck(regaba, east_Cell);
var isregSa = RegionACheck(regaba, south_Cell);
var isregWa = RegionACheck(regaba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regabb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(east_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regabb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(south_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regabb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(west_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regabb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(north_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regabb, north_Cell);
var isregEb = RegionBCheck(regabb, east_Cell);
var isregSb = RegionBCheck(regabb, south_Cell);
var isregWb = RegionBCheck(regabb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(east_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(south_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(west_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwab)){
		for(xx = 0; xx < ds_list_size(regwab); xx++;){
			if(north_Cell == regwab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwab, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwab);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwab)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwab);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwab[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwab, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwab);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwab[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwab);

#endregion
ds_list_destroy(regaba);
ds_list_destroy(regabb);
	}
}

ds_list_destroy(rega);



#endregion

#region //Divide ba and bb


//Check the total area of the region a. If room is too big,
//recursively run this funcion on that region.
if(ds_list_size(regba) >= 30 and !ds_list_empty(regba)){


#region //region ba

//Create 2 lists to store subregions and another to store walls
regbaa = ds_list_create();
regbab = ds_list_create();
regwba = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regba)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regba[| irand1];
var rand_coord2 = regba[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regba, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbaa, datagrid[# s1x, s1y]);
ds_list_add(regbab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbaa[| 0], regbab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbaa, north_Cell);
var isregEa = RegionACheck(regbaa, east_Cell);
var isregSa = RegionACheck(regbaa, south_Cell);
var isregWa = RegionACheck(regbaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(east_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(south_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(west_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(north_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbab, north_Cell);
var isregEb = RegionBCheck(regbab, east_Cell);
var isregSb = RegionBCheck(regbab, south_Cell);
var isregWb = RegionBCheck(regbab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(east_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(south_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(west_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(north_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwba);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwba)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwba);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwba[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwba, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwba);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwba[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwba);

#endregion
ds_list_destroy(regbaa);
ds_list_destroy(regbab);
}
else if(12 < ds_list_size(regba) < 30 and !ds_list_empty(regba)){
	var rand = irandom(3);
	if(rand != 0){ 
		
#region //region ba

//Create 2 lists to store subregions and another to store walls
regbaa = ds_list_create();
regbab = ds_list_create();
regwba = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regba)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regba[| irand1];
var rand_coord2 = regba[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regba, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbaa, datagrid[# s1x, s1y]);
ds_list_add(regbab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbaa[| 0], regbab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbaa, north_Cell);
var isregEa = RegionACheck(regbaa, east_Cell);
var isregSa = RegionACheck(regbaa, south_Cell);
var isregWa = RegionACheck(regbaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(east_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(south_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(west_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(north_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbab, north_Cell);
var isregEb = RegionBCheck(regbab, east_Cell);
var isregSb = RegionBCheck(regbab, south_Cell);
var isregWb = RegionBCheck(regbab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(east_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(south_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(west_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwba)){
		for(xx = 0; xx < ds_list_size(regwba); xx++;){
			if(north_Cell == regwba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwba, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwba);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwba)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwba);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwba[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwba, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwba);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwba[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwba);

#endregion
ds_list_destroy(regbaa);
ds_list_destroy(regbab);
	}
}

//Do the same for region b
if(ds_list_size(regbb) > 15 and !ds_list_empty(regbb)){
	

#region //region bb

//Create 2 lists to store subregions and another to store walls
regbba = ds_list_create();
regbbb = ds_list_create();
regwbb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbb[| irand1];
var rand_coord2 = regbb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbba, datagrid[# s1x, s1y]);
ds_list_add(regbbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbba[| 0], regbbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbba, north_Cell);
var isregEa = RegionACheck(regbba, east_Cell);
var isregSa = RegionACheck(regbba, south_Cell);
var isregWa = RegionACheck(regbba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(east_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(south_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(west_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(north_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbbb, north_Cell);
var isregEb = RegionBCheck(regbbb, east_Cell);
var isregSb = RegionBCheck(regbbb, south_Cell);
var isregWb = RegionBCheck(regbbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(east_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(south_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(west_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(north_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbb);

#endregion
ds_list_destroy(regbba);
ds_list_destroy(regbbb);
}
else if(8 < ds_list_size(regbb) < 15 and !ds_list_empty(regbb)){
	var rand = irandom(3);
	if(rand != 0){


#region //region bb

//Create 2 lists to store subregions and another to store walls
regbba = ds_list_create();
regbbb = ds_list_create();
regwbb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbb[| irand1];
var rand_coord2 = regbb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbba, datagrid[# s1x, s1y]);
ds_list_add(regbbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbba[| 0], regbbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbba, north_Cell);
var isregEa = RegionACheck(regbba, east_Cell);
var isregSa = RegionACheck(regbba, south_Cell);
var isregWa = RegionACheck(regbba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(east_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(south_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(west_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(north_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbbb, north_Cell);
var isregEb = RegionBCheck(regbbb, east_Cell);
var isregSb = RegionBCheck(regbbb, south_Cell);
var isregWb = RegionBCheck(regbbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(east_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(south_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(west_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbb)){
		for(xx = 0; xx < ds_list_size(regwbb); xx++;){
			if(north_Cell == regwbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbb);

#endregion
ds_list_destroy(regbba);
ds_list_destroy(regbbb);
	}
}

ds_list_destroy(regb);



#endregion
/*
//16rooms
#region //Divide regaaa and regaab


if(ds_list_size(regaaa) >= 30 and !ds_list_empty(regaaa)){


#region //region aaa

//Create 2 lists to store subregions and another to store walls
regaaaa = ds_list_create();
regaaab = ds_list_create();
regwaaa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaaa)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaaa[| irand1];
var rand_coord2 = regaaa[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaaa, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaaaa, datagrid[# s1x, s1y]);
ds_list_add(regaaab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaaaa[| 0], regaaab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaaaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaaaa, north_Cell);
var isregEa = RegionACheck(regaaaa, east_Cell);
var isregSa = RegionACheck(regaaaa, south_Cell);
var isregWa = RegionACheck(regaaaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regaaab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(east_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regaaab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(south_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regaaab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(west_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regaaab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(north_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regaaab, north_Cell);
var isregEb = RegionBCheck(regaaab, east_Cell);
var isregSb = RegionBCheck(regaaab, south_Cell);
var isregWb = RegionBCheck(regaaab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaaaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(east_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaaaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(south_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaaaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(west_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaaaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(north_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaaa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaaa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaaa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaaa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaaa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaaa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaaa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaaa);

#endregion
}
else if(12 < ds_list_size(regaaa) < 30 and !ds_list_empty(regaaa)){
	var rand = irandom(3);
	if(rand != 0){ 
		

#region //region aaa

//Create 2 lists to store subregions and another to store walls
regaaaa = ds_list_create();
regaaab = ds_list_create();
regwaaa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaaa)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaaa[| irand1];
var rand_coord2 = regaaa[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaaa, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaaaa, datagrid[# s1x, s1y]);
ds_list_add(regaaab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaaaa[| 0], regaaab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaaaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaaaa, north_Cell);
var isregEa = RegionACheck(regaaaa, east_Cell);
var isregSa = RegionACheck(regaaaa, south_Cell);
var isregWa = RegionACheck(regaaaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regaaab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(east_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regaaab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(south_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regaaab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(west_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regaaab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(north_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regaaab, north_Cell);
var isregEb = RegionBCheck(regaaab, east_Cell);
var isregSb = RegionBCheck(regaaab, south_Cell);
var isregWb = RegionBCheck(regaaab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaaaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(east_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaaaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(south_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaaaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(west_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaaaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaaa)){
		for(xx = 0; xx < ds_list_size(regwaaa); xx++;){
			if(north_Cell == regwaaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaaa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaaa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaaa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaaa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaaa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaaa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaaa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaaa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaaa);

#endregion
	}
}

if(ds_list_size(regaab) > 15 and !ds_list_empty(regaab)){
	

#region //region aab

//Create 2 lists to store subregions and another to store walls
regaaba = ds_list_create();
regaabb = ds_list_create();
regwaab = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaab)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaab[| irand1];
var rand_coord2 = regaab[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaab, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaaba, datagrid[# s1x, s1y]);
ds_list_add(regaabb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaaba[| 0], regaabb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaaba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaaba, north_Cell);
var isregEa = RegionACheck(regaaba, east_Cell);
var isregSa = RegionACheck(regaaba, south_Cell);
var isregWa = RegionACheck(regaaba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regaabb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(east_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regaabb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(south_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regaabb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(west_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regaabb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(north_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regaabb, north_Cell);
var isregEb = RegionBCheck(regaabb, east_Cell);
var isregSb = RegionBCheck(regaabb, south_Cell);
var isregWb = RegionBCheck(regaabb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaaba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaabb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(east_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaaba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaabb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(south_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaaba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaabb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(west_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaaba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaabb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(north_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaab);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaab)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaab);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaab[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaab, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaab);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaab[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaab);

#endregion
}
else if(8 < ds_list_size(regaab) < 15 and !ds_list_empty(regaab)){
	var rand = irandom(3);
	if(rand != 0){
		

#region //region aab

//Create 2 lists to store subregions and another to store walls
regaaba = ds_list_create();
regaabb = ds_list_create();
regwaab = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaab)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaab[| irand1];
var rand_coord2 = regaab[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaab, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regaaba, datagrid[# s1x, s1y]);
ds_list_add(regaabb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regaaba[| 0], regaabb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regaaba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regaaba, north_Cell);
var isregEa = RegionACheck(regaaba, east_Cell);
var isregSa = RegionACheck(regaaba, south_Cell);
var isregWa = RegionACheck(regaaba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regaabb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaaba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(east_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regaabb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaaba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(south_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regaabb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaaba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(west_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regaabb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaaba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(north_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regaabb, north_Cell);
var isregEb = RegionBCheck(regaabb, east_Cell);
var isregSb = RegionBCheck(regaabb, south_Cell);
var isregWb = RegionBCheck(regaabb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regaaba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regaabb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(east_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regaaba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regaabb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(south_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regaaba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regaabb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(west_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regaaba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regaabb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaab)){
		for(xx = 0; xx < ds_list_size(regwaab); xx++;){
			if(north_Cell == regwaab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaab, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaab);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaab)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaab);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaab[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaab, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaab);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaab[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaab);

#endregion
	}
}

ds_list_destroy(regaa);
#endregion

#region //Divide regaba and regabb


if(ds_list_size(regaba) >= 30 and !ds_list_empty(regaba)){


#region //region aba

//Create 2 lists to store subregions and another to store walls
regabaa = ds_list_create();
regabab = ds_list_create();
regwaba = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaba)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaba[| irand1];
var rand_coord2 = regaba[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaba, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regabaa, datagrid[# s1x, s1y]);
ds_list_add(regabab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regabaa[| 0], regabab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regabaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regabaa, north_Cell);
var isregEa = RegionACheck(regabaa, east_Cell);
var isregSa = RegionACheck(regabaa, south_Cell);
var isregWa = RegionACheck(regabaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regabab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(east_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regabab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(south_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regabab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(west_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regabab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(north_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regabab, north_Cell);
var isregEb = RegionBCheck(regabab, east_Cell);
var isregSb = RegionBCheck(regabab, south_Cell);
var isregWb = RegionBCheck(regabab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regabaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(east_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regabaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(south_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regabaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(west_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regabaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(north_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaba);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaba)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaba);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaba[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaba, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaba);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaba[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaba);

#endregion
}
else if(12 < ds_list_size(regaba) < 30 and !ds_list_empty(regaba)){
	var rand = irandom(3);
	if(rand != 0){ 
		

#region //region aba

//Create 2 lists to store subregions and another to store walls
regabaa = ds_list_create();
regabab = ds_list_create();
regwaba = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regaba)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regaba[| irand1];
var rand_coord2 = regaba[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regaba, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regabaa, datagrid[# s1x, s1y]);
ds_list_add(regabab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regabaa[| 0], regabab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regabaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regabaa, north_Cell);
var isregEa = RegionACheck(regabaa, east_Cell);
var isregSa = RegionACheck(regabaa, south_Cell);
var isregWa = RegionACheck(regabaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regabab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(east_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regabab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(south_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regabab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(west_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regabab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(north_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regabab, north_Cell);
var isregEb = RegionBCheck(regabab, east_Cell);
var isregSb = RegionBCheck(regabab, south_Cell);
var isregWb = RegionBCheck(regabab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regabaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(east_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regabaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(south_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regabaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(west_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regabaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwaba)){
		for(xx = 0; xx < ds_list_size(regwaba); xx++;){
			if(north_Cell == regwaba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwaba, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwaba);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwaba)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwaba);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwaba[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwaba, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwaba);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwaba[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwaba);

#endregion
	}
}

if(ds_list_size(regabb) > 15 and !ds_list_empty(regabb)){
	

#region //region abb

//Create 2 lists to store subregions and another to store walls
regabba = ds_list_create();
regabbb = ds_list_create();
regwabb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regabb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regabb[| irand1];
var rand_coord2 = regabb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regabb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regabba, datagrid[# s1x, s1y]);
ds_list_add(regabbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regabba[| 0], regabbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regabba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regabba, north_Cell);
var isregEa = RegionACheck(regabba, east_Cell);
var isregSa = RegionACheck(regabba, south_Cell);
var isregWa = RegionACheck(regabba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regabbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(east_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regabbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(south_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regabbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(west_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regabbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(north_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regabbb, north_Cell);
var isregEb = RegionBCheck(regabbb, east_Cell);
var isregSb = RegionBCheck(regabbb, south_Cell);
var isregWb = RegionBCheck(regabbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regabba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(east_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regabba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(south_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regabba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(west_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regabba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(north_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwabb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwabb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwabb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwabb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwabb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwabb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwabb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwabb);

#endregion
}
else if(8 < ds_list_size(regabb) < 15 and !ds_list_empty(regabb)){
	var rand = irandom(3);
	if(rand != 0){
		

#region //region abb

//Create 2 lists to store subregions and another to store walls
regabba = ds_list_create();
regabbb = ds_list_create();
regwabb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regabb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regabb[| irand1];
var rand_coord2 = regabb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regabb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regabba, datagrid[# s1x, s1y]);
ds_list_add(regabbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regabba[| 0], regabbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regabba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regabba, north_Cell);
var isregEa = RegionACheck(regabba, east_Cell);
var isregSa = RegionACheck(regabba, south_Cell);
var isregWa = RegionACheck(regabba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regabbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(east_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regabbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(south_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regabbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(west_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regabbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(north_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regabbb, north_Cell);
var isregEb = RegionBCheck(regabbb, east_Cell);
var isregSb = RegionBCheck(regabbb, south_Cell);
var isregWb = RegionBCheck(regabbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regabba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regabbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(east_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regabba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regabbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(south_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regabba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regabbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(west_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regabba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regabbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwabb)){
		for(xx = 0; xx < ds_list_size(regwabb); xx++;){
			if(north_Cell == regwabb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwabb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwabb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwabb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwabb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwabb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwabb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwabb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwabb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwabb);

#endregion
	}
}

ds_list_destroy(regab);



#endregion

#region //Divide regbaa and regbab


if(ds_list_size(regbaa) >= 30 and !ds_list_empty(regbaa)){


#region //region baa

//Create 2 lists to store subregions and another to store walls
regbaaa = ds_list_create();
regbaab = ds_list_create();
regwbaa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbaa)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbaa[| irand1];
var rand_coord2 = regbaa[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbaa, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbaaa, datagrid[# s1x, s1y]);
ds_list_add(regbaab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbaaa[| 0], regbaab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbaaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbaaa, north_Cell);
var isregEa = RegionACheck(regbaaa, east_Cell);
var isregSa = RegionACheck(regbaaa, south_Cell);
var isregWa = RegionACheck(regbaaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbaab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(east_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbaab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(south_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbaab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(west_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbaab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(north_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbaab, north_Cell);
var isregEb = RegionBCheck(regbaab, east_Cell);
var isregSb = RegionBCheck(regbaab, south_Cell);
var isregWb = RegionBCheck(regbaab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbaaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(east_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbaaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(south_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbaaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(west_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbaaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(north_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbaa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbaa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbaa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbaa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbaa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbaa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbaa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbaa);

#endregion
}
else if(12 < ds_list_size(regbaa) < 30 and !ds_list_empty(regbaa)){
	var rand = irandom(3);
	if(rand != 0){ 
		

#region //region baa

//Create 2 lists to store subregions and another to store walls
regbaaa = ds_list_create();
regbaab = ds_list_create();
regwbaa = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbaa)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbaa[| irand1];
var rand_coord2 = regbaa[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbaa, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbaaa, datagrid[# s1x, s1y]);
ds_list_add(regbaab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbaaa[| 0], regbaab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbaaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbaaa, north_Cell);
var isregEa = RegionACheck(regbaaa, east_Cell);
var isregSa = RegionACheck(regbaaa, south_Cell);
var isregWa = RegionACheck(regbaaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbaab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(east_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbaab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(south_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbaab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(west_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbaab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(north_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbaab, north_Cell);
var isregEb = RegionBCheck(regbaab, east_Cell);
var isregSb = RegionBCheck(regbaab, south_Cell);
var isregWb = RegionBCheck(regbaab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbaaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(east_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbaaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(south_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbaaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(west_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbaaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbaa)){
		for(xx = 0; xx < ds_list_size(regwbaa); xx++;){
			if(north_Cell == regwbaa[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbaa, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbaa);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbaa)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbaa);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbaa[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbaa, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbaa);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbaa[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbaa);

#endregion
	}
}

if(ds_list_size(regbab) > 15 and !ds_list_empty(regbab)){
	

#region //region bab

//Create 2 lists to store subregions and another to store walls
regbaba = ds_list_create();
regbabb = ds_list_create();
regwbab = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbab)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbab[| irand1];
var rand_coord2 = regbab[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbab, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbaba, datagrid[# s1x, s1y]);
ds_list_add(regbabb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbaba[| 0], regbabb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbaba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbaba, north_Cell);
var isregEa = RegionACheck(regbaba, east_Cell);
var isregSa = RegionACheck(regbaba, south_Cell);
var isregWa = RegionACheck(regbaba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbabb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(east_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbabb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(south_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbabb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(west_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbabb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(north_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbabb, north_Cell);
var isregEb = RegionBCheck(regbabb, east_Cell);
var isregSb = RegionBCheck(regbabb, south_Cell);
var isregWb = RegionBCheck(regbabb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbaba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbabb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(east_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbaba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbabb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(south_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbaba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbabb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(west_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbaba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbabb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(north_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbab);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbab)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbab);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbab[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbab, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbab);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbab[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbab);

#endregion
}
else if(8 < ds_list_size(regbab) < 15 and !ds_list_empty(regbab)){
	var rand = irandom(3);
	if(rand != 0){
		

#region //region bab

//Create 2 lists to store subregions and another to store walls
regbaba = ds_list_create();
regbabb = ds_list_create();
regwbab = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbab)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbab[| irand1];
var rand_coord2 = regbab[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbab, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbaba, datagrid[# s1x, s1y]);
ds_list_add(regbabb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbaba[| 0], regbabb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbaba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbaba, north_Cell);
var isregEa = RegionACheck(regbaba, east_Cell);
var isregSa = RegionACheck(regbaba, south_Cell);
var isregWa = RegionACheck(regbaba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbabb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbaba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(east_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbabb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbaba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(south_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbabb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbaba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(west_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbabb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbaba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(north_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbabb, north_Cell);
var isregEb = RegionBCheck(regbabb, east_Cell);
var isregSb = RegionBCheck(regbabb, south_Cell);
var isregWb = RegionBCheck(regbabb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbaba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbabb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(east_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbaba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbabb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(south_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbaba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbabb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(west_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbaba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbabb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbab)){
		for(xx = 0; xx < ds_list_size(regwbab); xx++;){
			if(north_Cell == regwbab[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbab, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbab);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbab)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbab);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbab[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbab, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbab);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbab[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbab);

#endregion
	}
}

ds_list_destroy(regba);



#endregion

#region //Divide regbba and regbbb


if(ds_list_size(regbba) >= 30 and !ds_list_empty(regbba)){


#region //region bba

//Create 2 lists to store subregions and another to store walls
regbbaa = ds_list_create();
regbbab = ds_list_create();
regwbba = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbba)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbba[| irand1];
var rand_coord2 = regbba[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbba, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbbaa, datagrid[# s1x, s1y]);
ds_list_add(regbbab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbbaa[| 0], regbbab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbbaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbbaa, north_Cell);
var isregEa = RegionACheck(regbbaa, east_Cell);
var isregSa = RegionACheck(regbbaa, south_Cell);
var isregWa = RegionACheck(regbbaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbbab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(east_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbbab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(south_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbbab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(west_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbbab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(north_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbbab, north_Cell);
var isregEb = RegionBCheck(regbbab, east_Cell);
var isregSb = RegionBCheck(regbbab, south_Cell);
var isregWb = RegionBCheck(regbbab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbbaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(east_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbbaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(south_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbbaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(west_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbbaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(north_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbba);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbba)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbba);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbba[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbba, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbba);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbba[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbba);

#endregion
}
else if(12 < ds_list_size(regbba) < 30 and !ds_list_empty(regbba)){
	var rand = irandom(3);
	if(rand != 0){ 
		

#region //region bba

//Create 2 lists to store subregions and another to store walls
regbbaa = ds_list_create();
regbbab = ds_list_create();
regwbba = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbba)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbba[| irand1];
var rand_coord2 = regbba[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbba, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbbaa, datagrid[# s1x, s1y]);
ds_list_add(regbbab, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbbaa[| 0], regbbab[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbbaa, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbbaa, north_Cell);
var isregEa = RegionACheck(regbbaa, east_Cell);
var isregSa = RegionACheck(regbbaa, south_Cell);
var isregWa = RegionACheck(regbbaa, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbbab, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbaa, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(east_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbbab, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbaa, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(south_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbbab, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbaa, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(west_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbbab, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbaa, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(north_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbbab, north_Cell);
var isregEb = RegionBCheck(regbbab, east_Cell);
var isregSb = RegionBCheck(regbbab, south_Cell);
var isregWb = RegionBCheck(regbbab, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbbaa, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbab, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(east_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbbaa, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbab, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(south_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbbaa, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbab, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(west_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbbaa, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbab, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbba)){
		for(xx = 0; xx < ds_list_size(regwbba); xx++;){
			if(north_Cell == regwbba[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbba, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbba);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbba)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbba);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbba[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbba, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbba);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbba[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbba);

#endregion
	}
}

if(ds_list_size(regbbb) > 15 and !ds_list_empty(regbbb)){
	

#region //region bbb

//Create 2 lists to store subregions and another to store walls
regbbba = ds_list_create();
regbbbb = ds_list_create();
regwbbb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbbb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbbb[| irand1];
var rand_coord2 = regbbb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbbb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbbba, datagrid[# s1x, s1y]);
ds_list_add(regbbbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbbba[| 0], regbbbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbbba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbbba, north_Cell);
var isregEa = RegionACheck(regbbba, east_Cell);
var isregSa = RegionACheck(regbbba, south_Cell);
var isregWa = RegionACheck(regbbba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbbbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(east_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbbbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(south_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbbbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(west_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbbbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(north_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbbbb, north_Cell);
var isregEb = RegionBCheck(regbbbb, east_Cell);
var isregSb = RegionBCheck(regbbbb, south_Cell);
var isregWb = RegionBCheck(regbbbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbbba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(east_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbbba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(south_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbbba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(west_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbbba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(north_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbbb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbbb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbbb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbbb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbbb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbbb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbbb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbbb);

#endregion
}
else if(8 < ds_list_size(regbbb) < 15 and !ds_list_empty(regbbb)){
	var rand = irandom(3);
	if(rand != 0){
		

#region //region bbb

//Create 2 lists to store subregions and another to store walls
regbbba = ds_list_create();
regbbbb = ds_list_create();
regwbbb = ds_list_create();

iteration += 1;

var reg_list_index_cap = ds_list_size(regbbb)-1;

//Choose 2 random index values from the region array
var irand1 = irandom(reg_list_index_cap);
var irand2 = irandom(reg_list_index_cap);

//convert to real coordinates from datagrid
var rand_coord1 = regbbb[| irand1];
var rand_coord2 = regbbb[| irand2];

//Check all sides of rand_coord1 and its own cell for rand_coord2 using datagrid and RegionSeedRandomizer function
var c2x = ExtractXCoord(rand_coord2);
var c2y = ExtractYCoord(rand_coord2);

if(rand_coord1 == rand_coord2 or (rand_coord1 == datagrid[# c2x+1, c2y]) or (rand_coord1 == datagrid[# c2x-1, c2y]) or (rand_coord1 == datagrid[# c2x, c2y+1]) or (rand_coord1 == datagrid[# c2x, c2y-1]))
rand_coord2 = RegionSeedRerandomize(regbbb, datagrid, rand_coord1, rand_coord2);

//set random values for seed coordinates random index values from the region array
var s1x = ExtractXCoord(rand_coord1);
var s1y = ExtractYCoord(rand_coord1);
var s2x = ExtractXCoord(rand_coord2);
var s2y = ExtractYCoord(rand_coord2);

//Create an array for each region
ds_list_add(regbbba, datagrid[# s1x, s1y]);
ds_list_add(regbbbb, datagrid[# s2x, s2y]);

//Add the seed coordinates to the set list
ds_list_add(set, regbbba[| 0], regbbbb[| 0]);

//Repeat the Cell division until the set is empty
while(ds_list_size(set) > 0){
	//repeat(50){

//Add the region seeds to a set to keep track o
var set_size_index_cap = ds_list_size(set)-1;
var rand = irandom(set_size_index_cap);
pop_seed = set[| rand];

cx = ExtractXCoord(pop_seed);
cy = ExtractYCoord(pop_seed);

//Create adjacent cell global.grid index value variables
var east_Cell = datagrid[# cx+1, cy];
var south_Cell = datagrid[# cx, cy-1];
var west_Cell = datagrid[# cx-1, cy];
var north_Cell = datagrid[# cx, cy+1];

//Check if the pop_seed is regiona
isregiona = RegionACheck(regbbba, pop_seed);

//check adjacent cells for other region a cells to prevent duplicates
if(isregiona = true){
var isregNa = RegionACheck(regbbba, north_Cell);
var isregEa = RegionACheck(regbbba, east_Cell);
var isregSa = RegionACheck(regbbba, south_Cell);
var isregWa = RegionACheck(regbbba, west_Cell);

//check all adjacent cells of East cell for bordering region b cells(1 cell seperation for walls)
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEa){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionBCheck(regbbbb, b1, b2, b3)
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbba, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(east_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, east_Cell)
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSa){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionBCheck(regbbbb, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbba, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(south_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWa){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionBCheck(regbbbb, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbba, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(west_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNa){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionBCheck(regbbbb, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbba, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(north_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, north_Cell);
	}
	
	//After all adjacent cells have been added or skipped, remove the original seed_cell from the set list
	ds_list_delete(set, pop_seed);
}
}
else{
var isregNb = RegionBCheck(regbbbb, north_Cell);
var isregEb = RegionBCheck(regbbbb, east_Cell);
var isregSb = RegionBCheck(regbbbb, south_Cell);
var isregWb = RegionBCheck(regbbbb, west_Cell);

//Check East Region for conflicts
if(global.grid[# cx+1, cy] != WALL and global.grid[# cx+1, cy] != DOOR and !isregEb){
	var b1 = datagrid[# cx+1, cy+1];
	var b2 = datagrid[# cx+2, cy];
	var b3 = datagrid[# cx+1, cy-1];
	var iscellEbad = RegionACheck(regbbba, b1, b2, b3)
	
	
	//if no conflicts exist, add the cell's index value to the region and list
	if(!iscellEbad){
		ds_list_add(regbbbb, east_Cell);
		ds_list_add(set, east_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(east_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, east_Cell);
	}
}

// do the same for South
if(global.grid[# cx, cy-1] != WALL and global.grid[# cx, cy-1] != DOOR and !isregSb){
	var b1 = datagrid[# cx+1, cy-1];
	var b2 = datagrid[# cx, cy-2];
	var b3 = datagrid[# cx-1, cy-1];
	var iscellSbad = RegionACheck(regbbba, b1, b2, b3);
	
	if(!iscellSbad){
		ds_list_add(regbbbb, south_Cell);
		ds_list_add(set, south_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(south_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, south_Cell);
	}
}

//and West
if(global.grid[# cx-1, cy] != WALL and global.grid[# cx-1, cy] != DOOR and !isregWb){
	var b1 = datagrid[# cx-1, cy-1];
	var b2 = datagrid[# cx-2, cy];
	var b3 = datagrid[# cx-1, cy+1];
	var iscellWbad = RegionACheck(regbbba, b1, b2, b3)
	
	if(!iscellWbad){
		ds_list_add(regbbbb, west_Cell);
		ds_list_add(set, west_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(west_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, west_Cell);
	}
}

//and North
if(global.grid[# cx, cy+1] != WALL and global.grid[# cx, cy+1] != DOOR and !isregNb){
	var b1 = datagrid[# cx-1, cy+1];
	var b2 = datagrid[# cx, cy+2];
	var b3 = datagrid[# cx+1, cy+1];
	var iscellNbad = RegionACheck(regbbba, b1, b2, b3)
	
	if(!iscellNbad){
		ds_list_add(regbbbb, north_Cell);
		ds_list_add(set, north_Cell);
	}
	else{
		var dup = false;
		if(!ds_list_empty(regwbbb)){
		for(xx = 0; xx < ds_list_size(regwbbb); xx++;){
			if(north_Cell == regwbbb[| xx]){
				var dup = true;
				break;
			}
			}
		}
			if(!dup) ds_list_add(regwbbb, north_Cell);
	}
	}
}
var seed = ds_list_find_index(set, pop_seed);
	ds_list_delete(set, seed);
}

//Determine number of doors to spawn by wall length
var regw_size = ds_list_size(regwbbb);

//if(8 < regw_size) var xx = 2;
//else if(  regw_size < 8) var xx = 1;
//else if(regw_size == 0) var xx = 0;

if(!ds_list_empty(regwbbb)){
//Set doors
if(regw_size > 15) xx = 3;
else if(1 < regw_size < 15){
var door_count = 2;
var rand_doors = irandom(door_count)
if(rand_doors == 0) var xx = 2;
}
else xx = 1;

for(var draw = 0; draw < xx; draw++;){
	var regw_index_cap = ds_list_size(regwbbb);
	regw_index_cap -= 1;
	var rand = irandom(regw_index_cap);
	var door = regwbbb[| rand];
	var doorx = ExtractXCoord(door);
	var doory = ExtractYCoord(door);
	global.grid[# doorx, doory] = DOOR;
	ds_list_delete(regwbbb, rand);
}
}

//Set walls
var regw_size = ds_list_size(regwbbb);
for(xx = 0; xx < regw_size; xx++;){
	var wallloc = regwbbb[| xx];
	var wallx = ExtractXCoord(wallloc);
	var wally = ExtractYCoord(wallloc);
	global.grid[# wallx, wally] = WALL;
}

ds_list_destroy(regwbbb);

#endregion
	}
}

ds_list_destroy(regbb);



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