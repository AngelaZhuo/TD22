% create random experimental vectors
clear all
close all

% shuffle random number generator
rng shuffle;

trials_per_block = 50;
perc_randomness = 5; % percentage of most random vectors to select
perc_std_diff = 15;

% hcue_reward_prob = 0.80;
% lcue_reward_prob = 0.20;
% odor_prob = 0.80;

%% order of different trial types in a block -> type 1 to 8



my_vect =[ones(floor(trials_per_block*0.32),1);ones(ceil(trials_per_block*0.08),1)*2;ones(ceil(trials_per_block*0.02),1)*3;ones(floor(trials_per_block*0.08),1)*4;
ones(floor(trials_per_block*0.08),1)*5;ones(ceil(trials_per_block*0.02),1)*6;ones(ceil(trials_per_block*0.08),1)*7;ones(floor(trials_per_block*0.32),1)*8];

num_permutations = 100000;

type_perm_mtx = zeros(numel(my_vect),num_permutations);
type_perm_Q = zeros(1,num_permutations);
type_perm_std = zeros(1,num_permutations);

for i=1:num_permutations
    my_vect = my_vect(randperm(numel(my_vect)));
    
    % use Ljung�Box test to test for randomness
    [h,pValue,stat,cValue] = lbqtest(my_vect);    
    type_perm_Q(1,i) = stat; % Ljung-Box test statistic
    
    % test standard deviation of difference vector
    type_perm_std(1,i) = std(diff(my_vect));
    
    % put vector into matrix
    type_perm_mtx(:,i) = my_vect;
end

% identify most random vectors
type_perm_Q_sorted = sort(type_perm_Q);
Q_thresh = type_perm_Q_sorted(ceil(numel(type_perm_Q_sorted)/100)*perc_randomness);

% identify vectors with highest std of diff
type_perm_std_sorted = sort(type_perm_std);
std_thresh = type_perm_std_sorted(ceil(numel(type_perm_std_sorted)/100)*(100-perc_std_diff));

type_perm_mtx_select = type_perm_mtx(:,((type_perm_Q<Q_thresh)&(type_perm_std>std_thresh)));

% delete duplicate vectors
[row,col] = find(round(triu(corrcoef(type_perm_mtx_select),1),2)==1);
type_perm_mtx_select(:,unique(col)) = [];

%% combine trial type and reward vectors

blocks = 3;

num_diff_exps = 600;
experiments = zeros(blocks * trials_per_block,4,num_diff_exps);

for j=1:num_diff_exps

    exp_vector = zeros(blocks * trials_per_block,4); % column 1: odorcue_odor; column 2: rewardcue_odor; column 3: reward; column 4: trial type

    % make sure that the same type vectors are not repeatedly chosen in the
    % time course
    block_sel = randperm(size(type_perm_mtx_select,2));

    for i=1:blocks

        % select one type vector
        type_vec_sel = type_perm_mtx_select(:,block_sel(i));
        
        % stack type definitions
        case_vect = type_vec_sel;
        trial_vect = zeros (size(case_vect,1),4);
        
        % trial types:
        type_1 = [1 1 1 1];
        type_2 = [1 1 0 2];
        type_3 = [1 0 1 3];
        type_4 = [1 0 0 4];
        type_5 = [0 1 1 5];
        type_6 = [0 1 0 6];
        type_7 = [0 0 1 7];
        type_8 = [0 0 0 8];
      
for ii=1:size(case_vect,1)
    
    switch(case_vect(ii))
        
        case 1 
            trial_vect(ii,:) = type_1;
        case 2 
            trial_vect(ii,:) = type_2;
        case 3 
            trial_vect(ii,:) = type_3;
        case 4 
            trial_vect(ii,:) = type_4;
        case 5 
            trial_vect(ii,:) = type_5;
        case 6 
            trial_vect(ii,:) = type_6;
        case 7 
            trial_vect(ii,:) = type_7;
        case 8
            trial_vect(ii,:) = type_8;
    end
            
             
  end

       % put into exp_vector
       start_trial_block = ((i-1)*trials_per_block)+1;
       exp_vector(start_trial_block:(start_trial_block+(trials_per_block-1)),:) = trial_vect;
%        

    end
    
    experiments(:,:,j) = exp_vector;
    
end

save experiments.mat experiments
