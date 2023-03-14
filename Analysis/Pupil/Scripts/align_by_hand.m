clear;
control_button = 0;

load('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d_devaluation.mat')

% vid_path = ["\\zistfs02.zi.local\NoSeA\Angela\TD22_videos\20220913_TD22_Devaluation" "\\zistfs02.zi.local\NoSeA\Angela\TD22_videos\20220917_TD22_Extinction"];
% Videolist = [];
% for vd = 1:numel(vid_path)
%     Videolist = cat(1,Videolist, getAllFiles(vid_path{vd},'*.wmv',1));
% end
% Videolist(28) = [];
load('align_by_hand_videolist.mat');

dig_path = ["\\zisvfs12\Home\yi.zhuo\Documents\Devaluation_Dig\Combined_DigFiles\20220913_TD22_Devaluation" "\\zisvfs12\Home\yi.zhuo\Documents\Devaluation_Dig\Combined_DigFiles\20220917_TD22_Extinction"];
Diglist = [];
for dg = 1:numel(dig_path)
    Diglist = cat(1,Diglist, getAllFiles(dig_path{dg},'*digital.mat',1));
end

IX = 1:numel(Videolist); 
% IX(28) = [];    %y11-20220917_143611 pupil file was corrupted
        
control_button = 1;

for vx = IX

    % find the digital file from this session
    [~,video_name] = fileparts(Videolist{vx});
    current_animal_name = video_name(1:3);
    current_date = video_name(5:12);
    
    d_info_index = find(ismember({d.info.animal}, current_animal_name) & ismember({d.info.date}, current_date));
    
    % load the digital file
    load(Diglist{contains(Diglist,current_animal_name) & contains(Diglist,current_date)});
    
    % find the intan signal for switching the light on
    freq = 20000; % samplerate
    led_trace = dchannels(:,5);
    led_on_timestamp = find(diff(led_trace)==1)/freq;
    led_off_timestamp = find(diff(led_trace)==-1)/freq;
    
    assert(led_on_timestamp<d.events{d_info_index}(1).fv_on_odorcue); %sanity check
    
    % load the video:
    % construct a multimedia reader object, that can read in video data from a
    % multimedia file.
    v = VideoReader(Videolist{contains(Videolist,current_animal_name) & contains(Videolist,current_date)});
    
    framecounter=1; % for creating "bright1" variable ...
    dur = 100; % in s; v.CurrentTime is in s ...
    % dur = 40; %before, changed to 100 to capture late LED-Triggers
    if control_button == 1 
        f=figure;
        suptitle(video_name);
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    end
    while v.CurrentTime < dur % read first minute
        % read predefined frames
        video = readFrame(v);

        % bright1 = variable containing mean intesity values frame by frame ...
        bright1(framecounter) = mean(video(:,:,1),'all'); %the readFrame gives an output of a video frame
                                                          %video(pixel# on the width:pixel# on the length:RGB values). Here (:,:,1) selects the R value of all the pixels
        
        % plot the intensity values for visual control ...
        if control_button
            plot(gca, bright1);
        end
        %When the plot is generated, one can click the "data tips" button (looks like comment) and move to the line and it'll show the x and
        %y coordinate. X value would be the frame number of IR light start
        
        % modify counter ...
        framecounter=framecounter+1;
    end
    
    FrameBegin = input('Input the frame of infrared light start: ');
    
    % visual control
%     hold on
%     plot(gca,FrameBegin,bright1(FrameBegin),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
%     title([current_animal_name,' on the ',current_date]);
%     exportgraphics(gcf,fullfile('\\zisvfs12\Home\Yi.Zhuo\Documents\Devaluation_Dig\plots\Video_LED_brightness\',[current_animal_name,'_',current_date,'.png']))
%     close all;
% 
    d.info(d_info_index).LED_on_trigger_intan = led_on_timestamp;
    d.info(d_info_index).LED_on_trigger_camera = FrameBegin/10; % convert from samples to seconds
    close all;
    vx
end

save('\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Angela\DATA\TD22\D-struct\d_devaluation.mat','d');