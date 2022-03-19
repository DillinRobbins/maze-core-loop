# maze-core-loop

You'll see several regions which are just repeatedly running the core loop. 

The main region is the second one, after the variables and building outer walls. 

That region seperates a grid into 2 subregions by grabbing a random cell in a random subregion, 
and attempting to add the cells around it to its same subregion. 

In  order to do that, It has to check if every cell around it is already occupied, 
a wall, or is adjacent to the opposite subregion cells. 

At the end it turns all non occupied cells into walls and creates doors placed randomly in them.


Algorithm:

Collect all the cells in the maze into a single region.

1. Split the region into two, using the following process:

2.1 Choose two cells from the region at random as “seeds”. Identify one as subregion A and one as subregion B. Put them into a set S.

 2.2 Choose a cell at random from S. Remove it from the set.

 2.3 For each of that cell’s neighbors, if the neighbor is not already associated with a subregion, 
add it to S, and associate it with the same subregion as the cell itself.


Repeat 2.2 and 2.3 until the entire region has been split into two.

3. Construct a wall between the two regions by identifying cells in one region that have neighbors in the other region. 
Leave a gap by omitting the wall from one such cell pair.

Repeat 2 and 3 for each subregion, recursively.
