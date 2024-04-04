%% Total pipeline
clear
PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
addpath(genpath(PVdirectory))
Functions_directory = "\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\"; addpath(genpath(Functions_directory))
cd(Functions_directory)

%Load the d-struct
load("d.mat") % You might need to update this line
PVsmall = d;
Regions = ["Pupil"];
Sessions = numel(PVsmall.info);

%Index of the Sesser is the order of the day session, index 1 is the first 50-trial session 25.07.2022
%Sesser(x) contains all the d.info indices of the day session

% Sesser{24} = [417:432];     %Exclude y01&y02-20220819

for s = 29:31
        Sesser{s} = [505:505+17] + (s-29)*18
end

% Sesser{28} = [487:492,495:504]; %Exclude y07&y08-20220824
 
Sesser{34} = [595,596,597,598,599,600,601,602,603,605,606,608,609,610,611]; 

EndTime = 16.8; % in seconds
OC_time = [2.1, 3.3];
Jitter_time = 4.5;
RC_time = [5.7, 6.9];
R_time = 8.1;
XEvents = [OC_time, Jitter_time, RC_time, R_time, EndTime]*10;

% Matrix creation loop:
for s = [29:31, 34]
    teil = 1;
    Matrices.(Regions{teil}).matrix =[];
    Matrices.(Regions{teil}).trialMatrix =[];
    Matrices.(Regions{teil}).jitter = [];
    Matrices.(Regions{teil}).mouse = [""];
    Matrices.(Regions{teil}).events = XEvents;
    uu = 0;
    for u = Sesser{s}
    %     diam = PVsmall.pupil(u).raw_trace;
        diam = PVsmall.pupil(u).aligned_trace;
        diam(diam == 0) = NaN;
        if isempty(diam) || all(isnan(diam)); warning("diam is defective"); continue; end
        uu = uu+1;
        BinSize = .100; %Seconds
        diamTime = (1:numel(diam)).*BinSize;

        Session = PVsmall.events(u); Session = Session{1};
        Trials = size(Session, 2); % Compare with PVsmall.TrialMatrix(UnitIndex(u), :, :);
        if Trials == 140; Session(126:end) = []; Trials = 125; end    %Y07 and Y08 on 20220917, FV crashed at Trial 126
        TotalTime = Session(Trials).reward_time + 10;

        diamTime(diamTime>TotalTime) = [];
        diam(numel(diamTime)+1:end) = [];
        for tr = 1:Trials
            % 2-second Baseline; 20 bins of .100s 
            Bins1 = int64(Session(tr).fv_on_odorcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_odorcue/BinSize-1); Bins1 = Bins1(end-int64(2/BinSize)+1:end);
            % CS1 plus 1.2 seconds; 24 bins of .100s
            Bins2 = Bins1(end)+1 : Bins1(end)+1 + 2.4/BinSize; Bins2 = Bins2(1:int64(2.4/BinSize));
            % 1.2s before CS2; 12 bins of .100s
            Bins3 = int64(Session(tr).fv_on_rewcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_rewcue/BinSize-1); Bins3 = Bins3(end-int64(1.1/BinSize):end);
            % CS2, Reward and 8s afrer Reward; 112 bins of .100s
            Bins4 = Bins3(end)+1 : Bins3(end)+1 + int64(11.2/BinSize); Bins4 = Bins4(1:int64(11.2/BinSize));
            
            if tr == 150 && Bins4(end) > length(diam)
               diam((length(diam)+1):Bins4(end)) = NaN;
            end
                    
            Matrices.(Regions{teil}).matrix(uu, :, tr) = diam([Bins1, Bins2, Bins3, Bins4]);
            Matrices.(Regions{teil}).jitter(uu, tr) = (Session(tr).fv_on_rewcue - Session(tr).fv_off_odorcue) - 1.2;
        end
        
        Matrices.(Regions{teil}).mouse(uu, 1) = string(PVsmall.info(u).animal);
        % Create trial matrix;
        TM = NaN(1, 3, Trials);
        CS1 = [Session.curr_odorcue_odor_num];
        CS2 = [Session.curr_rewardcue_odor_num];
        US = [Session.drop_or_not];
        TM(1, 1, :) = CS1; TM(1, 2, :) = CS2; TM(1, 3, :) = US;
        if Trials == 125; TM(1, :, 126:150) = NaN; end
        Matrices.(Regions{teil}).trialMatrix(uu, :, :) = TM;
    end
    
    Matrices.Pupil.trialMatrix(Matrices.Pupil.trialMatrix==10)=6;
    
    % Make 5->6 and 6->5 in afternoon session mice (and same for CS2)
    % Change odor identity to the likelihood of the CS1 and CS2 (5 means odor A; 6 means odor B; 7 means odor C; 8 means odor D) 
    Afternoon = ["y09","y10","y11","y16","y13","y14","y17","y18","y19","y20"];
    idx = ismember(Matrices.Pupil.mouse, Afternoon);
    TM = Matrices.Pupil.trialMatrix(idx, :, :);
    New = NaN(size(TM));
    New(:, 3, :) = TM(:, 3, :);
    New(TM == 5) = 6;
    New(TM == 6) = 5;
    New(TM == 7) = 8;
    New(TM == 8) = 7;
    Matrices.Pupil.trialMatrix(idx, :, :) = New;
    Matrices.Pupil.matrix(Matrices.Pupil.matrix==0) = NaN;
    % Matrices.Pupil.trialMatrix(:,:,1:5) = [];
    % Matrices.Pupil.matrix(:,:,1:5) = [];    %Remove the first 5 trials from matrix and trialmatrix to make the baseline for A and B equal
    % Save Before
    parsave("\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\Sessions\Session_" + num2str(s), Matrices);
end
% 
% %%
% clear
% PVdirectory = "\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct";
% addpath(genpath(PVdirectory))
% Functions_directory = "\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\"; addpath(genpath(Functions_directory))
% cd(Functions_directory)
% 
% %Load the d-struct
% load("d_devaluation.mat") % You might need to update this line or load d_devaluation.mat by hand
% PVsmall = d;
% Regions = ["Pupil"];
% Sessions = numel(PVsmall.info);
% 
% Before = [505:594]; % The index number in the d-struct of the sessions BEFORE injection that you want
% After = [595,596,597,598,599,600,601,602,603,605,606,608,609,610,611]; % The index number in the d-struct of the sessions AFTER injection that you want
% 
% EndTime = 16.8; % in seconds
% OC_time = [2.1, 3.3];
% Jitter_time = 4.5;
% RC_time = [5.7, 6.9];
% R_time = 8.1;
% XEvents = [OC_time, Jitter_time, RC_time, R_time, EndTime]*10;
% 
% teil = 1;
% Matrices.(Regions{teil}).matrix =[];
% Matrices.(Regions{teil}).trialMatrix =[];
% Matrices.(Regions{teil}).jitter = [];
% Matrices.(Regions{teil}).mouse = [""];
% Matrices.(Regions{teil}).events = XEvents;
% % Matrix creation loop:
% uu = 0;
% for u = After
% 
%     diam = PVsmall.pupil(u).aligned_trace;
%     diam(diam == 0) = NaN;
%     if ~isempty(diam) && ~all(isnan(diam))
%         uu = uu+1;
%         BinSize = .100; %Seconds
%         diamTime = (1:numel(diam)).*BinSize;
% 
%         Session = PVsmall.events(u); Session = Session{1};
%         Trials = size(Session, 2); % Compare with PVsmall.TrialMatrix(UnitIndex(u), :, :);
%         if Trials == 140; Session(126:end) = []; Trials = 125; end   %Y07 and Y08 on 20220917, FV crashed at Trial 126
%         TotalTime = Session(Trials).reward_time + 10;
% 
%         diamTime(diamTime>TotalTime) = [];
%         diam(numel(diamTime)+1:end) = [];
%         for tr = 1:Trials
%             % 2-second Baseline; 20 bins of .100s 
%             Bins1 = int64(Session(tr).fv_on_odorcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_odorcue/BinSize-1); Bins1 = Bins1(end-int64(2/BinSize)+1:end);
%             % CS1 plus 1.2 seconds; 24 bins of .100s
%             Bins2 = Bins1(end)+1 : Bins1(end)+1 + 2.4/BinSize; Bins2 = Bins2(1:int64(2.4/BinSize));
%             % 1.2s before CS2; 12 bins of .100s
%             Bins3 = int64(Session(tr).fv_on_rewcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_rewcue/BinSize-1); Bins3 = Bins3(end-int64(1.1/BinSize):end);
%             % CS2, Reward and 8s afrer Reward; 112 bins of .100s
%             Bins4 = Bins3(end)+1 : Bins3(end)+1 + int64(11.2/BinSize); Bins4 = Bins4(1:int64(11.2/BinSize));
% 
%             Matrices.(Regions{teil}).matrix(uu, :, tr) = diam([Bins1, Bins2, Bins3, Bins4]);
%             Matrices.(Regions{teil}).jitter(uu, tr) = Session(tr).fv_on_rewcue - Session(tr).fv_off_odorcue - 1.2;
%         end
%         Matrices.(Regions{teil}).mouse(uu, 1) = string(PVsmall.info(u).animal);
%         % Create trial matrix;
%         TM = NaN(1, 3, Trials);
%         CS1 = [Session.curr_odorcue_odor_num];
%         CS2 = [Session.curr_rewardcue_odor_num];
%         US = [Session.drop_or_not];
%         TM(1, 1, :) = CS1; TM(1, 2, :) = CS2; TM(1, 3, :) = US;
%         if Trials == 125; TM(1, :, 126:150) = NaN; end
%         Matrices.(Regions{teil}).trialMatrix(uu, :, :) = TM;
%     end
% end
% Matrices.Pupil.trialMatrix(Matrices.Pupil.trialMatrix==10)=6;
% 
% % Make 5-> 6 and 6->5 in afternoon session mice (and same for CS2)
% Afternoon = ["y09","y10","y11","y16","y13","y14","y17","y18","y19","y20"];
% 
% idx = ismember(Matrices.Pupil.mouse, Afternoon);
% TM = Matrices.Pupil.trialMatrix(idx, :, :);
% New = zeros(size(TM));
% New(:, 3, :) = TM(:, 3, :);
% New(TM == 5) = 6;
% New(TM == 6) = 5;
% New(TM == 7) = 8;
% New(TM == 8) = 7;
% Matrices.Pupil.trialMatrix(idx, :, :) = New;
% Matrices.Pupil.matrix(Matrices.Pupil.matrix==0) = NaN;
% Matrices.Pupil.trialMatrix(:,:,1:5) = [];
% Matrices.Pupil.matrix(:,:,1:5) = [];    %Remove the first 5 trials from matrix and trialmatrix to make the baseline for A and B equal
% % Save After
% parsave("\\zisvfs12\Home\yi.zhuo\Documents\GitHub\TD22\Analysis\Pupil\Master_GLM\After1", Matrices);
































