% Example script which uses the function "verticesInEachComponent.m".
% The matrix "points" contains 30 points randomly located near the three
% points (1,0), (0,0) and (0,1) in the plane. Hence we expect three
% connected components.

NOISE_COEFFICIENT = 0.1;
locations = [1, 0; 0, 0; 0, 1];
point_cloud = locations(randi(3, 30, 1), :) + NOISE_COEFFICIENT * rand(30, 2);

max_dimension = 1;
max_filtration_value = 0.5;
num_divisions = 100;

stream = api.Plex4.createVietorisRipsStream(point_cloud, max_dimension + 1, max_filtration_value, num_divisions);
componentVertexIndices = verticesInEachComponent(stream, 0.5);

fprintf('\nBelow are the indices of the vertices in each component.\n')
for i = 1 : size(componentVertexIndices, 1)
    fprintf(['Component ', int2str(i), ':\n'])
    indices = componentVertexIndices{i};
    for j = 1 : size(indices, 2) - 1
        fprintf([int2str(indices(j)), ', ']);
    end
    fprintf([int2str(indices(size(indices, 2))), '\n'])
end

fprintf('\nBelow are the coordinates of the vertices in each component.\n')
for i = 1 : size(componentVertexIndices, 1)
    fprintf(['Component ', int2str(i), ':\n'])
    indices = componentVertexIndices{i};
    for j = 1 : size(indices, 2)
        fprintf([num2str(point_cloud(indices(j), 1), '%11.2f'), ', ', num2str(point_cloud(indices(j), 2), '%11.2f'), '\n']);
    end
end