%% Fliter out bad sessions
% Exclusion criteria: >10% of the data with likelihood lower than 0.98

csv_path = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\Pupil\DeepLabCut\PMC_8point_coord\20220731_TD22\y03';
Videolist_csv = getAllFiles(csv_path,'*filtered.csv',1);
Videolist_csv(contains(Videolist_csv,'short')) = [];

opts = detectImportOptions(Videolist_csv{1});
opts.VariableNamesLine = 3;
opts.Delimiter = ',';
opts.RowNamesColumn = 1;
coords = readtable(Videolist_csv{1}, opts, 'ReadVariableNames', true);

likelihood_columns = coords{:,[4:3:25]};
n_LowerThan98 = nnz(likelihood_columns<0.98);
percent_LowerThan98 = n_LowerThan98/(numel(likelihood_columns));
