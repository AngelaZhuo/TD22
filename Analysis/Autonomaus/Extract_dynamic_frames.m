% Modified from Eda/David's script "video_with_relevant_frames_thirty.m"
%AZ 2024.10.14

clear;
% video_path = '/home/edadilara.turgut/Desktop/fc2_save_2023-05-19-163321-0000.avi';
% video_path = '/home/edadilara.turgut/Documents/fc2_save_2023-05-19-163321-0000_150.avi';
% video_path = '/home/edadilara.turgut/Documents/fc2_save_2023-05-19-163334-0000_151.avi';
% v = VideoReader(video_path);
% disp('input video-object created');

vid_dynamic_snip = '\\zistfs02.zi.local\NoSeA\Luise\Autonomouse_Videos_misc\AutonomouseVideos\D1_rounds\AM4\Round2_3\large_arena\fc2_save_2022-04-27-125823-0000_snip_dynamic.avi';
% short_video_with_mice = '/home/edadilara.turgut/Documents/fc2_save_2023-05-19-163321-0000_150_select.avi';
% short_video_with_mice = '/home/edadilara.turgut/Documents/fc2_save_2023-05-19-163334-0000_151_select.avi';
v_out = VideoWriter(vid_dynamic_snip);
open(v_out);

% disp('output video-object created');

% get empty frame
% empty_frame_big_arena = rgb2gray(mov(1).cdata);
% load('/home/edadilara.turgut/Documents/MATLAB/empty_frame_big_arena.mat');

framecounter=0;

for vid = 0:250
    
    % video_path = ['/home/edadilara.turgut/Videos/original/6/fc2_save_2023-06-24-124752-0000_',num2str(vid),'.avi'];
    video_path = '\\zistfs02.zi.local\NoSeA\Luise\Autonomouse_Videos_misc\AutonomouseVideos\D1_rounds\AM4\Round2_3\large_arena\fc2_save_2022-04-27-125823-0000_snip.avi';
    v = VideoReader(video_path);

    
    % disp(['video: ',num2str(vid)]); %adjust here
    v.CurrentTime = 0;
    k = 1; 
    while hasFrame(v) 
        mov(k).cdata = readFrame(v);  %Get image color data for each frame
        k = k+1;    
    end

    k = 2;
    framemove = [];
    while k<min([numel(mov),5400])
    % while k<min([numel(mov),4500])   %in original:min([numel(mov),54000])  try 54000, problem now: it doesnt even look at all ks so it doesnt search through the complete video

        % diff_image = abs(rgb2gray(mov(k).cdata(50:430,60:580,:))-rgb2gray(mov(k-1).cdata(50:430,60:580,:)));
        diff_image = abs(rgb2gray(mov(k).cdata(40:480,50:560,:))-rgb2gray(mov(k-1).cdata(40:480,50:560,:)));
        B = imgaussfilt(diff_image,3);
        tmp(k) = max(B,[],'all');
        k = k+1;
        
        
        % check if currentFrame has mice
        if max(B,[],'all') > 5 && framecounter<=54000  %Eda used max(B,[],'all')>10; I keep it more conservative
            writeVideo(v_out,mov(k).cdata);
            framecounter=framecounter+1;
            framemove = [framemove;k];
        end
        
        
    end

end


close(v_out);

