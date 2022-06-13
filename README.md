# maze-core-loop

The code works by seperating a data-structure grid into 2 regions by placing 2 seeds randomly that spread to fill a region, and placing a wall between those generated regions. It repeats this algorithm recursively until a determined room size threshhold is achieved. However, GMS has difficulty with recursion, so i had to copy and paste the core loop under a finite number of iterations.

The code is titled: Create_0.gml

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
