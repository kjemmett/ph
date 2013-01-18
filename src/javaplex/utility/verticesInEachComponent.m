% Note: in order to find the connected components, I use a union-find 
% algorithm. See 
% http://en.wikipedia.org/wiki/Disjoint-set_data_structure.
% This is NOT as efficient as using a breadth-first search. See
% http://en.wikipedia.org/wiki/Connected_component_(graph_theory) and
% http://en.wikipedia.org/wiki/Breadth-first_search and
% http://books.google.com/books?id=7XUSn0IKQEgC&lpg=PA166&ots=z6dJMTORZg&dq=connected%20component%20of%20graph%20breadth&pg=PA166#v=onepage&q=connected%20component%20of%20graph%20breadth&f=false

% The reason why I use the union-find algorithm instead of a breadth-first
% search is that my data structure for the graph (the 1-skeleton of the 
% simplicial complex) stores edges in a global list, instead of storing 
% each edge as pointers between the two vertices. The latter data structure
% is needed for a breadth-first search.

% It would certainly be possible to store edges as "pointers" in Matlab, 
% and then use a breadth-first search, but I have not done this yet. My
% current union-find algorithm seems sufficiently fast.

function  componentVertexIndices = verticesInEachComponent(stream, cutoff)

% This function first finds the vertices and edges in the filtered
% simplicial complex 'stream' with filtration value less than 'cutoff'. It
% then returns the indices of the vertices in each connected component.
%
% INPUT:
%   stream - an instance of the javaPlex Java class SimplexStream.
%   cutoff - the largest filtration value of included simplices.
%
% OUTPUT:
%   componentVertexIndices - a cell array of length equal to the number of
%       connected components. Entry i contains the list of the vertex
%       indices in the i-th connected component.
%
% henrya@math.stanford.edu

numVertices = 0;
numEdges = 0;
iterator = stream.iterator();
while (iterator.hasNext())
  simplex = iterator.next();
  if simplex.getDimension() == 0 && stream.getFiltrationValue(simplex) <= cutoff
      numVertices = numVertices + 1;
  elseif simplex.getDimension() == 1 && stream.getFiltrationValue(simplex) <= cutoff
      numEdges = numEdges + 1;
  end
end

vertices = zeros(numVertices, 1);
edges = zeros(numEdges, 2);
i = 0;
j = 0;
iterator = stream.iterator();
while (iterator.hasNext())
  simplex = iterator.next();
  if simplex.getDimension() == 0 && stream.getFiltrationValue(simplex) <= cutoff
      i = i + 1;
      vertices(i) = simplex.getVertices() + 1;
  elseif simplex.getDimension() == 1 && stream.getFiltrationValue(simplex) <= cutoff
      j = j + 1;
      edges(j, :) = simplex.getVertices() + 1;
  end
end

% Performs the union-find algorithm on vertices to get the connected 
% components. A better method would be to use a breadth-first search.
tree = 1 : numVertices;
for i = 1 : numEdges
    tree = union(tree, edges(i, 1), edges(i, 2));
end

for i = 1 : numVertices
    tree(i) = treeFind(tree, i);
end

numComponents = size(unique(tree), 2);
componentVertexIndices = cell(numComponents, 1);

% Could be made more efficient.
count = 1;
for i = 1 : numVertices
    if tree(i) ~= -1
        component = i;
        for j = i + 1 : numVertices
            if tree(i) == tree(j)
                component = [component, j];
                tree(j) = -1;
            end
        end
        componentVertexIndices{count} = component;
        count = count + 1;
    end
end

% One could make this function more efficient, for instance by using
% treeFind more frequently.
function tree = union(tree, i, j)
x = treeFind(tree, i);
y = treeFind(tree, j);
if x ~= y
    tree(x) = y;
end

function x = treeFind(tree, i)
if tree(i) ~= i
    x = treeFind(tree, tree(i));
else
    x = i;
end