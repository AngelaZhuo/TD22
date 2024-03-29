%% tagging ITI augmented: 2->3s
% edit 20200203 function name: added '_EPhys' 
% 20200302 
% -> added pause after first and second and before second IR LED trigger
% -> adjusted tagging script for DAT

function superflex_TD22_behavior(phase, animals, COMPort, setup)%, JitterButton)
%% create header-file, open serial connection to olfactometer.

%"animals" input in superflex_TD22_behavior() needs to be written in a cell array of two strings such as {"Y01" "Y02"}
%In the TD22 behavioral cohort, odd numbers represent WT(control) animals and even numbers represent D1R-KO (in VS) animals. One animal pair with one WT and one mutant mice is recorded in the same session.      


if all(ismember(animals, {'Y01' 'Y02' 'Y03' 'Y04' 'Y05' 'Y06' 'Y07' 'Y08'}))
    fprintf('morning sessions\n');
    if ~ismember(phase, {'TD22_M50' 'TD22_M100' 'TD22_M150' })
        fprintf('wrong animal-phase association!\n');
        return
    end
elseif all(ismember(animals, {'Y09' 'Y10' 'Y11' 'Y16' 'Y13' 'Y14' 'Y17' 'Y18' 'Y19' 'Y20' }))
    fprintf('afternoon sessions\n');
    if ~ismember(phase, {'TD22_A50' 'TD22_A100' 'TD22_A150' })
        fprintf('wrong animal-phase association!\n');
        return
    end
else
    fprintf('unexpected animal number\n');
end

fname={};
if size(animals,2)<2
    fname{1} = ['A_',animals{1}];   %If there is only one animal in a session, make sure the animal is in box A
else
    fname{1} = ['A_',animals{1}];    %The animal entered first should be in box A and the one entered second should be in box B
    fname{2} = ['B_',animals{2}];      
end
% if numel(animals) == 2
%     fname = ['A_',animals{1},'+ B_',animals{2}];    %The animal entered first should be in box A and the one entered second should be in box B
% elseif numel(animals) == 1
%     fname = ['A_',animals{1}];  %If there is only one animal in a session, make sure the animal is in box A
% end


sessionstart = tic;
% protocol_file = CreateHeader(fname);
protocol_file=[];
for a = 1:size(animals,2)
    protocol_file{a} = CreateHeader(fname{a});
end
s = SetupSerial(COMPort);

%% selection of parameters according to 'phase' input argument

    [chapter, session.trialmatrix,ex_vectors_cur]=do_constructTrialMatrix_TD22(phase);  
    session.trialmatrix_concatenated =  session.trialmatrix;
    
%% set up some initial conditions
if size(animals,2)>1
    fname_str=strcat(fname{1},'+ ',fname{2});
    protocol_file_str = strcat(protocol_file{1},'+ ',protocol_file{2});
else 
    fname_str=fname{1};
    protocol_file_str = protocol_file{1};
end

session.name = fname_str;
session.time = now;
session.chapter = chapter;
session.header_file = protocol_file_str;
session.setup = setup;

current_chapter = 1;
max_trials = chapter.max_trials;


%% Calculate session duration
% recdur     = sum([trialmatrix.ITI])+2e3*numel(trialmatrix);
% recdur_min = floor(recdur/1e3/60);
% recdur_sec = mod(recdur/1e3,60);
% waitfor(msgbox({['Protocol Time: ',num2str(recdur_min),':',num2str(recdur_sec),' min'],'Start Session?'}));

%%Show message box before starting session
waitfor(msgbox({'Start Recording this session.'}));
sessionstart = tic;
%% LED Trigger for Video Intan Alignment
        s1 = ['trialParams2' ' '...
     num2str(991)...
            ' ' num2str(0)...
%             ' ' num2str(current_trial(m).drop_or_not),...
% %             ' ' num2str(chapter.reward_delay),...
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
%         save(protocol_file, 'session');
        for a = 1:size(animals,2)
            save(protocol_file{a}, 'session');
        end
        disp('saved');
        pause(ITD);
       
        toc;
        
        
        
    end %end of paradigm
%% LED Trigger for Video Intan Alignment

  pause(5);
  
        s1 = ['trialParams2' ' '...
     num2str(990)...
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

%% End of session
%    save(protocol_file, 'session');
    for a = 1:size(animals,2)
            save(protocol_file{a}, 'session');
    end
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
header_directory = 'D:\TD22_behavior\Protocols';
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




