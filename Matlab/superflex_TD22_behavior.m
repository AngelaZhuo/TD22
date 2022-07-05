%% tagging ITI augmented: 2->3s
% edit 20200203 function name: added '_EPhys' 
% 20200302 
% -> added pause after first and second and before second IR LED trigger
% -> adjusted tagging script for DAT

function superflex_TD22_behavior(COMPort, animals, setup)%, JitterButton)
%% create header-file, open serial connection to olfactometer.

if all(ismember(animals, {'Y01' 'Y02' 'Y03' 'Y04' 'Y05' 'Y06' 'Y07' 'Y08' 'Y09' 'Y10'}))
    fprintf('morning sessions\n');
    phase='TD_22_1_morning';
elseif all(ismember(animals, {'Y11' 'Y12' 'Y13' 'Y14' 'Y15' 'Y16' 'Y17' 'Y18' 'Y19' 'Y20'}))
    fprintf('afternoon sessions\n');
    phase='TD_22_1_afternoon';
else
    fprintf('unexpected animal number\n');
end

if numel(animals) == 2
    fname = ['A_',animals{1},'+ B_',animals{2}];    %The animal entered first should be in box A and the one entered second should be in box B
elseif numel(animals) == 1
    fname = ['A_',animals{1}];  %If there is only one animal in a session, make sure the animal is in box A
end

sessionstart = tic;
protocol_file = CreateHeader(fname);
s = SetupSerial(COMPort);

%% selection of parameters according to 'phase' input argument

    [chapter, session.trialmatrix,ex_vectors_cur]=do_constructTrialMatrix_TD22(phase);  
    session.trialmatrix_concatenated =  session.trialmatrix;
    
%% set up some initial conditions
session.name = fname;
session.time = now;
session.chapter = chapter;
session.header_file = protocol_file;
session.setup = setup;

current_chapter = 1;
max_trials = chapter.max_trials;


%% Calculate session duration
% recdur     = sum([trialmatrix.ITI])+2e3*numel(trialmatrix);
% recdur_min = floor(recdur/1e3/60);
% recdur_sec = mod(recdur/1e3,60);
% waitfor(msgbox({['Protocol Time: ',num2str(recdur_min),':',num2str(recdur_sec),' min'],'Start Session?'}));

%%Show message box before starting session
waitfor(msgbox({'Start Recording and connect laser.',  'Then start session.'}));
sessionstart = tic;
%% LED Trigger for Video Intan Alignment
        s1 = ['trialParams2' ' '...
     num2str(99)...
            ' ' num2str(0)...
%             ' ' num2str(current_trial(m).drop_or_not),...
%             ' ' num2str(chapter.reward_delay),...
%             ' ' num2str(current_trial(m).rew_size),...
            %' ' num2str(current_trial(m).odorcue_odor_dur),...
            %' ' num2str(current_trial(m).rewardcue_odor_dur),...
            ];
       

        try
            
              fprintf(s,s1);
        catch
            disp('Serial error occurred! Try to restart serial and send data...')
            ReleaseArduino(s)
            s = CreateArduinoComm(COMPort);
            fprintf(s,s1);
            %beep
        end
        
        
        
  pause(5);
%% start session

current_trial=table2struct(session.trialmatrix(1:max_trials,:));%(chapterblock*blocklength-blocklength+1:chapterblock*blocklength,:));  

%% Loop through session
    for m = 1:max_trials
        
        
        tic;
        
        i = m; 
        
        disp('___________________')
        fprintf('Trial %d: ',i);      
         
        
        ITD=(15.5+rand*2);        
 
        switch current_trial(m).trialtype
            case 1
                disp('A->C->Reward')
            case 2
                disp('A->C->NoReward')
            case 3
                disp('A->D->Reward')
            case 4
                disp('A->D->NoReward')
            case 5
                disp('B->C->Reward')
            case 6
                disp('B->C->NoReward')
            case 7
                disp('B->D->Reward')
            case 8
                disp('B->D->NoReward')
        end

% paramsAssemb = tic;


        s1 = ['trialParams' ' '...
     num2str(current_trial(m).odorcue_odor_num)...
            ' ' num2str(current_trial(m).rewardcue_odor_num)...
            ' ' num2str(current_trial(m).drop_or_not),...
            ' ' num2str(chapter.reward_delay),...
            ' ' num2str(current_trial(m).rew_size),...
            %' ' num2str(current_trial(m).odorcue_odor_dur),...
            %' ' num2str(current_trial(m).rewardcue_odor_dur),...
            ];

        
% trialAssemb = toc(paramsAssemb);
% disp('trialAssemb');
% disp(trialAssemb);
      
paramsToBCS = tic; 
        try
            
              fprintf(s,s1);
        catch
            disp('Serial error occurred! Try to restart serial and send data...')
            ReleaseArduino(s)
            s = CreateArduinoComm(COMPort);
            fprintf(s,s1);
            %beep
        end
        TimeForComm = toc(paramsToBCS);
        disp('TimeForComm');
        disp(TimeForComm);
        OClockString = now;
        flushinput(s);
        pause(0.5);
 
        % Start asynchronous reading
        
        % readasync(s);
        
        % Get the data from the serial object
        % the serialdata is in the format 'rewardCode, LickCount'
        %try
          %  serialdata = fscanf(s, '%s');
            
            %         disp(serialdata);
           % TrialEndTime = str2double(serialdata(1));
           % TrialEndTime = str2double(serialdata(2:3));
            fprintf('End of trial: %d \n');
        %catch
%             disp('Serial Error.')
%             ReleaseArduino(s)
%             pause(4);
%             s = CreateArduinoComm(COMPort);
%             
%             ReleaseArduino(s)
%             pause(4);
%             s = CreateArduinoComm(COMPort);
            %beep
            
        %end
        
        %% save and/or update header
        
        data(i).reward_size= current_trial(m).rew_size;
        data(i).curr_trialtype=current_trial(m).trialtype;        
        data(i).curr_odorcue_odor_num = current_trial(m).odorcue_odor_num;
        data(i).curr_rewardcue_odor_num = current_trial(m).rewardcue_odor_num;
        data(i).drop_or_not = current_trial(m).drop_or_not;
        data(i).curr_odorcue_odor_dur = current_trial(m).odorcue_odor_dur;
        data(i).curr_rewardcue_odor_dur = current_trial(m).rewardcue_odor_dur;
        data(i).reward_delay = chapter.reward_delay;
        data(i).OClockString = OClockString;
        
        
        
        session(1).data.trials=data;
        save(protocol_file, 'session');
        disp('saved');
        pause(ITD);
       
        toc;
        
        
        
    end %end of paradigm
%% LED Trigger for Video Intan Alignment

  pause(5);
  
        s1 = ['trialParams2' ' '...
     num2str(99)...
            ' ' num2str(0)...
%             ' ' num2str(current_trial(m).drop_or_not),...
%             ' ' num2str(chapter.reward_delay),...
%             ' ' num2str(current_trial(m).rew_size),...
            %' ' num2str(current_trial(m).odorcue_odor_dur),...
            %' ' num2str(current_trial(m).rewardcue_odor_dur),...
            ];
       

        try
            
              fprintf(s,s1);
        catch
            disp('Serial error occurred! Try to restart serial and send data...')
            ReleaseArduino(s)
            s = CreateArduinoComm(COMPort);
            fprintf(s,s1);
            %beep
        end
        pause(2);
disp('End of paradigm');
%% Tagging
disp('Start Tagging');
    
%load the case list
load('C:\Users\Anwender\Desktop\ExperimentalControl_21092018_LW\TD19\Matlab\CaseList');

    
    % define trial parameters 
    nt = 30;            %trials per case: 20 for D1 and D2
    case_num = [412, 414];     %case number from ephys setup: in D1 and D2 [412, 413, 414, 415] 
    
    
% construct trialmatrix2
trials = repmat(case_num,1,nt)';
trials = trials(randperm(numel(case_num)*nt));

% pseudorandomness
while CheckRepetitions(trials,3) > 0
   trials = trials(randperm(length(trials)));
end

% fill trials with CaseList information
for tr = 1:numel(trials)
   trialmatrix2(tr).trial_num    = tr;
   trialmatrix2(tr).case_num     = trials(tr);
   trialmatrix2(tr).case_name    = CaseList([CaseList.case_nr] == trials(tr)).odor_name;
   trialmatrix2(tr).odor_dur     = CaseList([CaseList.case_nr] == trials(tr)).odor_dur;
   trialmatrix2(tr).odor_num     = CaseList([CaseList.case_nr] == trials(tr)).odor_num;
   trialmatrix2(tr).odor_lat     = CaseList([CaseList.case_nr] == trials(tr)).odor_lat;
   trialmatrix2(tr).laser_pattern= CaseList([CaseList.case_nr] == trials(tr)).laser_pattern;
   trialmatrix2(tr).laser_lat    = CaseList([CaseList.case_nr] == trials(tr)).laser_lat;
   trialmatrix2(tr).ITI          = CaseList([CaseList.case_nr] == trials(tr)).ITI;
end

% define some fixed and useless constants for compatibility with txt-header
curr_sound_lat = 0;
curr_odor_stim = 0;

%% loop through trials
for tr = 1:size(trialmatrix2,2)
    s1 = ['trialParams2' ' '...
     num2str(trialmatrix2(tr).laser_pattern)...
            ' ' (trialmatrix2(tr).laser_lat)
            ];
    
%     s1 = sprintf('%s %d %d %d %d %d\r', 'trialParams2',...
%         uint16(trialmatrix2(tr).laser_pattern),...
%         uint16(trialmatrix2(tr).laser_lat));
%     
    % sending parameters to BCS
    try
        fprintf( s, s1);
%         fprintf( s, 'temp \r');
        session.trialmatrix2(tr).status = 1;
    catch
        disp('Serial error occurred! Try to restart serial...')
        ReleaseArduino(s)
        s = CreateArduinoComm(COMPort);
        fprintf( s, s1);
        fprintf( s, 'temp \r');        
        session.trialmatrix2(tr).status = 0;
        %beep
    end
    
    % printing parameters of trial in command window
    fprintf(     '%d%s   %d\t %d\t %d\t %d\t %d\t %d\t %d\n', tr, ': ', trialmatrix2(tr).laser_lat, trialmatrix2(tr).odor_dur, trialmatrix2(tr).odor_lat, trialmatrix2(tr).case_num, trialmatrix2(tr).ITI, curr_sound_lat,curr_odor_stim);
    disp(['Laser=' num2str(trialmatrix2(tr).laser_pattern) '   Sound=' num2str(0) '   Vial=' num2str(0) '   sound latency=' num2str(0)  '   odor stim=' num2str(trialmatrix2(tr).case_num)]);
    disp('-------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    % saving trial parameters to file
%     fprintf(fid, '%d%s\t %d\t\t %d\t\t %d\t\t %d\t\t %d\t\t %d\t\t %d\n', tr, ': ',  trialmatrix2(tr).laser_lat, trialmatrix2(tr).odor_dur, trialmatrix2(tr).odor_lat, trialmatrix2(tr).case_num, trialmatrix2(tr).ITI, curr_sound_lat,curr_odor_stim);
    
        tagging(tr).laser_lat = trialmatrix2(tr).laser_lat;
        tagging(tr).odor_dur = trialmatrix2(tr).odor_dur;
        tagging(tr).odor_lat = trialmatrix2(tr).odor_lat;
        tagging(tr).case_num = trialmatrix2(tr).case_num;
        tagging(tr).ITI = trialmatrix2(tr).ITI;
        tagging(tr).sound_lat = curr_sound_lat;
        tagging(tr).odor_lat = curr_odor_stim;
    
        session(1).tagging.trials=tagging;
        save(protocol_file, 'session');
        disp('saved');
        
    pause((trialmatrix2(tr).ITI/1e3) + (2*rand));
end
    
%% End of session
    save(protocol_file, 'session');
    disp('end of session saved');
    sessionduration = toc(sessionstart);
    disp('Session duration');
    disp(sessionduration/60);

    waitfor(msgbox('Stop Intan, disconnect Laser, take out animal, then press ok.'))
    

ReleaseArduino(s)
%beep; pause(0.5); beep; pause(0.5); beep;
pause(0.5);

end






function s = SetupSerial(COMPort)

% setting up serial port
delete(instrfindall);
s = CreateArduinoComm(COMPort);
fprintf( s, 'temp \r');
pause(10);

end


function header_file = CreateHeader(fname)

time = datestr(now,'yymmdd_HHMM');
header_name = [fname, '_', time, '_protocol'];
header_directory = 'C:\Users\Anwender\Desktop\TD19_EPhys Recordings\headers';
header_file = fullfile(header_directory, header_name);

end


function s = CreateArduinoComm(COMPort)

delete(instrfind)

s=serial(COMPort);

s.baudrate=115200;
s.flowcontrol='none';
s.inputbuffersize=10000;
s.bytesavailablefcnmode = 'terminator';

set(s,'Terminator','CR/LF');
set(s,'DataBits',8);
set(s,'StopBits',2);
set(s, 'TimeOut', 15);


fopen(s);
pause(0.1);
disp('Serial communication is ready')

end

function ReleaseArduino(s)
fclose(s);
delete(s)
clear s
end




