
% Import the Excel file as a table
filename = '\\zisvfs12\Home\yi.zhuo\Desktop\Autonomouse\D1KO_Injury_score.xlsx';  % Replace with your actual file name
%filename = 'C:\Users\zhuo_\Desktop\Autonomouse\D1KO_Injury_score.xlsx';

% Read the first row (dates) as text
opts = detectImportOptions(filename);
opts.DataRange = '1:1';  % Only import the first row (date row)
opts.VariableTypes(:) = {'char'};  % Treat all columns as text

% Read the first row (dates)
dateRow = readtable(filename, opts);

% Inspect the raw date values (to check the format)
rawDates = table2cell(dateRow(1, 3:end));  % Skip Animal ID column
%disp('Raw Date Values:');
%disp(rawDates);

% Convert the raw date strings into datetime format
% Adjust the 'InputFormat' to match the actual format you observe
dates = datetime(rawDates, 'InputFormat', 'dd-MMM-yyyy');  % <-- Change format if needed

%Read the rest of the file
opts = detectImportOptions(filename);
opts.DataRange = '2:43';  % Start from the second row onward
opts.VariableTypes{1} = 'double';  % Animal ID as string
opts.VariableTypes{2} = 'logical';  % Mutant column as logical
opts = setvartype(opts, 3:length(opts.VariableNames), 'double');  % Set rest of the columns as numeric

data = readtable(filename, opts);
data = table2array(data);
total_injuries = sum(data(:,3:end)); %by date
isMutant = logical(data(:,2));


%% Import the housing_info excel sheet
%As of 30.09.2024, housing sheet only contains either unknown = 0 or autonomouse = 3 
housing_sheet = '\\zisvfs12\Home\yi.zhuo\Desktop\Autonomouse\D1KO_housing.xlsx';
opts_h = detectImportOptions(housing_sheet);
opts_h.DataRange = '2:43';  % Start from the second row onward
opts_h.VariableTypes{1} = 'double';  % Animal ID as string
opts_h.VariableTypes{2} = 'logical';  % Mutant column as logical
opts_h = setvartype(opts_h, 3:length(opts_h.VariableNames), 'double');  % Set rest of the columns as numeric
housing_data = readtable(housing_sheet,opts_h);  %matches the dimension of data 



%% Plot average injury score
% Average injury score in mutants and WTs by date
figure
bar(total_injuries)
xticklabels(rawDates(1:20:end))
title('Total_injuries_by_date','Interpreter','none','FontSize',15)

mutant_injuries = sum(data(isMutant,3:end))./sum(isMutant);
bar(mutant_injuries)
title('Mutant Injury Score Average','Interpreter','none','FontSize',15)
xticklabels(rawDates(1:20:end))
ylabel("Injury Score per Animal",'Interpreter','none','FontSize',13)

AM_mutant = sum(housing_data(isMutant,3:end)); %when mutants were in AM
AM_mutant = table2array(AM_mutant);
AM_mutant_date = find(AM_mutant);
hold on
AM_dates = plot(AM_mutant_date, repmat(0.1,length(AM_mutant_date)),"hexagram",'MarkerFaceColor','g');
legend(AM_dates,{'AM dates'},'Interpreter','none')
hold off

figure
WT_injuries = sum(data(~isMutant,3:end))./sum(~isMutant);
bar(WT_injuries)
title('WT Injury Score Average','Interpreter','none','FontSize',15)
xticklabels(rawDates(1:20:end))
ylabel("Injury Score per Animal",'Interpreter','none','FontSize',13)

AM_WT = sum(housing_data(~isMutant,3:end)); %when WTs were in AM
AM_WT = table2array(AM_WT);
AM_WT_date = find(AM_WT);
hold on
AM_dates = plot(AM_WT_date, repmat(0.1,length(AM_WT_date)),"hexagram",'MarkerFaceColor','g');
legend(AM_dates,{'AM dates'},'Interpreter','none')
hold off



%% Plot injured animals% each AM day 
% To see if the injured WT and mutants were clustered or scattered among AM groups
%Run the first section


%Import the AMgroups excel sheet
group_sheet = '\\zisvfs12\Home\yi.zhuo\Desktop\Autonomouse\D1KO_AMgroups.xlsx';
opts_g = detectImportOptions(group_sheet);
opts_g.DataRange = '2:43';
group_data = readtable(group_sheet,opts_g);
group_data = table2array(group_data);

num_days = size(data,2)-2;
num_groups = 8;

figure;
t = tiledlayout('flow');
title(t,'Injured animals% in the AMs','Interpreter','none','FontWeight','bold','Fontsize',17)

%Loop over each day and each group
for day = 1:num_days
    injury_scores = data(:,day+2);
    if day>2
        prev_group_assignments = group_data(:,day+1);
    else
        prev_group_assignments = [];
    end
    group_assignments = group_data(:,day+2);
    if day<170
        next_group_assignments = group_data(:,day+3);
    else
        next_group_assignments = [];
    end
    
    valid_groups = group_assignments>0;
    has_injuries = any(injury_scores>0);
    if ~has_injuries || ~any(valid_groups)  %skip the days with no injuries or no group assignments
        continue;
    end

    injured_count_per_group_WT = zeros(num_groups,1); %Initialize the array
    injured_count_per_group_mutant = zeros(num_groups,1);
    total_animals_per_group = zeros(num_groups,1);
    
    %Loop through each animal to count injured and total animals
    for ax = 1:size(data,1)
        group_code = group_assignments(ax);
        injury_score = injury_scores(ax);

        if group_code>0
            if group_code <= 9
                % if any(group_assignments>8) && group_code == next_group_assignments(ax) && prev_group_assignments(ax) == 0
                %     continue; end   %skip if it's a switch day and the group assignment belongs to the next round 
                if any(group_assignments>8) && group_code == prev_group_assignments(ax) && next_group_assignments(ax) == 0
                    continue; end   %skip if it's a switch day and the group assignment belongs to the previous round
                group = group_code;
                total_animals_per_group(group) = total_animals_per_group(group) +1;
                if injury_score > 0
                    if ax > 14
                        injured_count_per_group_WT(group) = injured_count_per_group_WT(group)+1;
                    else
                        injured_count_per_group_mutant(group) = injured_count_per_group_mutant(group)+1;
                    end
                end
            else
                m = floor(log10(group_code));
                group_digits = mod(floor(group_code ./ 10 .^ (m:-1:0)), 10);
                % group1 = group_digits(1);
                group2 = group_digits(2);

                % total_animals_per_group(group1) = total_animals_per_group(group1)+1;
                % if injury_score>0
                %     if ax > 14
                %         injured_count_per_group_WT(group1) = injured_count_per_group_WT(group1)+1;
                %     else
                %         injured_count_per_group_mutant(group1) = injured_count_per_group_mutant(group1)+1;
                %     end
                % 
                % end

                %Count the group assignment belongs to the next round on a switch day 
                total_animals_per_group(group2) = total_animals_per_group(group2)+1;
                if injury_score>0
                    if ax > 14
                        injured_count_per_group_WT(group2) = injured_count_per_group_WT(group2)+1;
                    else
                        injured_count_per_group_mutant(group2) = injured_count_per_group_mutant(group2)+1;
                    end

                end
            end
        end
    end

    %Plot the total animals and injured animals for this day
    nexttile
    bar(1:num_groups,[injured_count_per_group_mutant,injured_count_per_group_WT, total_animals_per_group - injured_count_per_group_WT - injured_count_per_group_mutant],'stacked');
    title(datestr(dates(day)),'FontSize',13)
    xlabel('Group Number')
    ylabel('Number of Animals')
    ylim([0, max(total_animals_per_group)+1])

    hold on
    for gp = 1:num_groups
        if total_animals_per_group(gp) > 0 
            total_injured(gp) = injured_count_per_group_mutant(gp) + injured_count_per_group_WT(gp);
            percentage_injured = (total_injured(gp) / total_animals_per_group(gp))*100;
            text(gp,total_injured(gp)+0.5 ,...
                sprintf('%.1f%%', percentage_injured), 'HorizontalAlignment','center');
        end
    end
    hold off

end

lgd = legend({'Injured Mutant','Injured WT','Healthy Animals'},'Location','northeastoutside','FontSize',12);
lgd.Layout.Tile = 'east';


%% Plot fraction of mutants/WT with injuries and actual injury scores
%Run the first section

group_sheet = '\\zisvfs12\Home\yi.zhuo\Desktop\Autonomouse\D1KO_AMgroups.xlsx';
opts_g = detectImportOptions(group_sheet);
opts_g.DataRange = '2:43';
group_data = readtable(group_sheet,opts_g);
group_data = table2array(group_data);

num_days = size(data,2)-2;
num_groups = 8;

figure
t = tiledlayout('flow');
title(t,'Injured animals% and Injury Scores in the AMs','Interpreter','none','FontWeight','bold','Fontsize',17)

%Loop over each day and each group
for day = 1:num_days
    injury_scores = data(:,day+2);
    if day>2
        prev_group_assignments = group_data(:,day+1);
    else
        prev_group_assignments = [];
    end
    group_assignments = group_data(:,day+2);
    if day<170
        next_group_assignments = group_data(:,day+3);
    else
        next_group_assignments = [];
    end
    
    valid_groups = group_assignments>0;
    has_injuries = any(injury_scores>0);
    if ~has_injuries || ~any(valid_groups)  %skip the days with no injuries or no group assignments
        continue;
    end

    injured_count_per_group_WT = zeros(num_groups,1); %Initialize the array
    injured_count_per_group_mutant = zeros(num_groups,1);
    total_animals_per_group = zeros(num_groups,1);
    injury_score_per_group = zeros(num_groups,2);
    
    %Loop through each animal to count injured and total animals
    for ax = 1:size(data,1)
        group_code = group_assignments(ax);
        injury_score = injury_scores(ax);

        if group_code>0
            if group_code <= 9
                % if any(group_assignments>8) && group_code == next_group_assignments(ax) && prev_group_assignments(ax) == 0
                %     continue; end   %skip if it's a switch day and the group assignment belongs to the next round 
                if any(group_assignments>8) && group_code == prev_group_assignments(ax) && next_group_assignments(ax) == 0
                    continue; end   %skip if it's a switch day and the group assignment belongs to the previous round
                group = group_code;
                total_animals_per_group(group) = total_animals_per_group(group) +1;
                if injury_score > 0
                    if ax > 14
                        injured_count_per_group_WT(group) = injured_count_per_group_WT(group)+1;
                        injury_score_per_group(group,2) = injury_score_per_group(group,2)+injury_score;
                    else
                        injured_count_per_group_mutant(group) = injured_count_per_group_mutant(group)+1;
                        injury_score_per_group(group,1) = injury_score_per_group(group,1)+injury_score;
                    end
                end
            else
                m = floor(log10(group_code));
                group_digits = mod(floor(group_code ./ 10 .^ (m:-1:0)), 10);
                % group1 = group_digits(1);
                group2 = group_digits(2);

                % total_animals_per_group(group1) = total_animals_per_group(group1)+1;
                % if injury_score>0
                %     if ax > 14
                %         injured_count_per_group_WT(group1) = injured_count_per_group_WT(group1)+1;
                %     else
                %         injured_count_per_group_mutant(group1) = injured_count_per_group_mutant(group1)+1;
                %     end
                % 
                % end

                %Count the group assignment belongs to the next round on a switch day 
                total_animals_per_group(group2) = total_animals_per_group(group2)+1;
                if injury_score>0
                    if ax > 14
                        injured_count_per_group_WT(group2) = injured_count_per_group_WT(group2)+1;
                        injury_score_per_group(group2,2) = injury_score_per_group(group2,2)+injury_score;
                    else
                        injured_count_per_group_mutant(group2) = injured_count_per_group_mutant(group2)+1;
                        injury_score_per_group(group2,1) = injury_score_per_group(group2,1)+injury_score;
                    end

                end
            end
        end
    end

    %Plot the total animals and injured animals for this day
    nexttile
    bar(1:num_groups,[injured_count_per_group_mutant,injured_count_per_group_WT, total_animals_per_group - injured_count_per_group_WT - injured_count_per_group_mutant],'stacked');
    title(datestr(dates(day)),'FontSize',13)
    xlabel('Group Number')
    ylabel('Number of Animals')
    ylim([0, max(total_animals_per_group)+1])

    % hold on
    % for gp = 1:num_groups
    %     if total_animals_per_group(gp) > 0 
    %         total_injured(gp) = injured_count_per_group_mutant(gp) + injured_count_per_group_WT(gp);
    %         percentage_injured = (total_injured(gp) / total_animals_per_group(gp))*100;
    %         text(gp,total_injured(gp)+0.5 ,...
    %             sprintf('%.1f%%', percentage_injured), 'HorizontalAlignment','center');
    %     end
    % end
    % hold off
    nexttile
    bar(1:num_groups,injury_score_per_group,'grouped');
    title(datestr(dates(day)),'FontSize',13)
    xlabel('Group Number')
    ylabel('Total Injury Score')
    ylim([0, max(max(injury_score_per_group))+1])

end
% 
lgd = legend({'Injured Mutant','Injured WT','Healthy Animals'},'Location','northeastoutside','FontSize',12);
lgd = legend({'Injured Mutant','Injured WT'},'Location','northeastoutside','FontSize',12);
lgd.Layout.Tile = 'east';

%% Initial injured mutants - injury score in the AMs

%Run the first section
%D1-KO were put into groups of 2/3 for socialisation around 23.02.2022 (Luise' note)

group_sheet = '\\zisvfs12\Home\yi.zhuo\Desktop\Autonomouse\D1KO_AMgroups.xlsx';
opts_g = detectImportOptions(group_sheet);
opts_g.DataRange = '2:43';
group_data = readtable(group_sheet,opts_g);
group_data = table2array(group_data);

%Initial injured animals(IIA) before AMs (due to brief group housing)
[IIA_row,IIA_col] = find(data(:,14:71)>0);
IIA_row_sorted = sort(IIA_row);

figure
% t_IIA = tiledlayout('flow');
t_IIA = tiledlayout(3,2);
title(t_IIA,'Initial Injured Animals: Injury Scores and AM Participation','Interpreter','none','FontWeight','bold','Fontsize',15)


%Loop over IIAs to plot
for iax = 1:numel(IIA_row_sorted)
    
    %Get injury scores between Feb20 (1st group house - Feb23) and June26 (last AM date - June23) 
    injury_score_cur = data(IIA_row_sorted(iax),11:137);
    AM_date_cur = group_data(IIA_row_sorted(iax),11:137);
    inAM = find(AM_date_cur);
    if isempty(inAM)
        continue
    end

    nexttile
    if IIA_row_sorted(iax)>14
        bar(injury_score_cur,'FaceColor',[0.9290 0.6940 0.1250]);
        title({"WT "+data(IIA_row_sorted(iax),1)},'Interpreter','none','FontSize',14)
    else
        bar(injury_score_cur,'b');
        title({"Mutant "+data(IIA_row_sorted(iax),1)},'Interpreter','none','FontSize',14)
    end
    xticks([0 20 40 60 80 100 120])
    ylim([0,5])
    xticklabels(rawDates(8:20:135))
    ylabel("Injury Score",'Interpreter','none','FontSize',13)
    hold on
    AM_dates = plot(inAM, repmat(0.5,length(inAM)),"hexagram",'MarkerFaceColor','g');
    legend(AM_dates,{'AM dates'},'Interpreter','none')
    hold off

end