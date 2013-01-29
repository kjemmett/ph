function RunBarcode_dist(varargin)

% parse input arguments
job_id = varargin{1};
run_dir = varargin{2};
stream_type = varargin{3};
num_div = str2num(varargin{4});
max_filt = str2num(varargin{5});
max_dim = str2num(varargin{6});
if nargin>6
    ratio = str2num(varargin{7});
end

original_dir = pwd;

prefix = [job_id '.F' num2str(max_filt) '.D' num2str(num_div) '.d' num2str(max_dim)];
output_dir = [run_dir '/output'];

% load_javaplex
cd([run_dir '/src/javaplex'])
load_javaplex
cd(original_dir)

% load data
d = csvread([run_dir '/data/' job_id '.csv'], 1, 1);

% construct metric space from distance matrix
m_space = metric.impl.ExplicitMetricSpace(d);

% construct filtration
disp(['Constructing ' stream_type ' stream'])
if strcmp(stream_type, 'VietorisRips')
    stream = api.Plex4.createVietorisRipsStream(m_space, max_dim, max_filt, num_div);
elseif strcmp(stream_type, 'LazyWitness')
    num_landmarks = max(5,round(size(d,1)/ratio)) 
    maxmin_selector = api.Plex4.createMaxMinSelector(m_space, num_landmarks);
    maxmin_points = maxmin_selector.getLandmarkPoints()+1;
    stream = api.Plex4.createLazyWitnessStream(maxmin_selector, max_dim, max_filt, num_div);
    % h_landmark = h(maxmin_points);
    fid = fopen([output_dir '/' 'landmarks.txt'],'w');
    for i = 1:length(maxmin_points)
        fprintf(fid,'%d\n',maxmin_points(i));
        % fprintf(fid,'%d\t%s\n',maxmin_points(i),h_landmark{i});
    end
    fclose(fid);
end

disp('Computing Persistence')
persistence = api.Plex4.getModularSimplicialAlgorithm(max_dim, 2);
% persistence = api.Plex4.getRationalSimplicialAlgorithm(max_dim);

disp('Computing Annotated Intervals')
filt_index_intervals = persistence.computeAnnotatedIntervals(stream);

% save annotated intervals
betti_info = char(filt_index_intervals)
fid = fopen([output_dir '/' prefix '.betti_info.txt'],'w');
fprintf(fid,betti_info);
fclose(fid);

% plot barcodes
file_format = 'eps'
options.filename = [output_dir '/' prefix '.' file_format];
options.max_filtration_value = max_filt;
options.max_dimension = max_dim - 1;
options.caption = prefix;
options.file_format = file_format;
plot_barcodes(filt_index_intervals,options);
