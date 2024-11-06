function Extract_dynamic_frames(video_path)

% video_path example: '/zi-flstorage/data/Luise/DA_Experiments/AM_Videos/All_rounds_NoSeA/AM1/Round2/small_arena/fc2_save_2022-04-27-124816-0000.avi'
% Modified from Eda/David's script "video_with_relevant_frames_thirty.m"
%AZ 2024.10.14

% Path to save dynamic videos
% output_dir = '/zi-flstorage/data/Luise/DA_Experiments/AM_Videos/All_rounds_NoSeA/AM1/Round2/small_arena/dynamic_30min_vids/';
% output_prefix = 'fc2_save_2022-05-01-100706-0000_dynamic_';
vid_filesep = strfind(video_path,filesep);
snippet_pthpre = [video_path(vid_filesep(1):vid_filesep(end)),'5-min_vids',video_path(vid_filesep(end):end-4),'_'];
output_dir = [video_path(vid_filesep(1):vid_filesep(end)),'dynamic_30min_vids/'];
if ~isfolder(output_dir)
    mkdir(output_dir)
end
output_prefix = [video_path(vid_filesep(end)+1:end-4),'_dynamic_'];
snippet_folder = [video_path(vid_filesep(1):vid_filesep(end)),'5-min_vids'];
all_snippets = dir(snippet_folder);
if_snippets = contains({all_snippets.name},video_path(vid_filesep(end)+1:end-4));
num_snippets = sum(if_snippets);

% v_out = VideoWriter(vid_dynamic);
% open(v_out);

part_counter = 1;
framecounter=0;

% Function to create a new video writer
file_ext = video_path(end-3:end);
create_video_writer = @(part_num) VideoWriter([output_dir, output_prefix, num2str(part_num), file_ext]);

% Initialize the first video output
v_out = create_video_writer(part_counter);
open(v_out);

for vid = 0:num_snippets-1
    
    % video_path = ['/home/edadilara.turgut/Videos/original/6/fc2_save_2023-06-24-124752-0000_',num2str(vid),'.avi'];
    snippet_video_path = [snippet_pthpre,num2str(vid),file_ext];
    v = VideoReader(snippet_video_path);

    
    disp(['current snippet video: _',num2str(vid)]); %adjust here
    v.CurrentTime = 0;
    k = 1; 
    while hasFrame(v) 
        mov(k).cdata = readFrame(v);  %Get image color data for each frame
        k = k+1;    
    end

    k = 2;
    framemove = [];
    while k<min(numel(mov))
    % while k<min([numel(mov),4500])   %in original:min([numel(mov),54000])  try 54000, problem now: it doesnt even look at all ks so it doesnt search through the complete video

        % diff_image = abs(rgb2gray(mov(k).cdata(50:430,60:580,:))-rgb2gray(mov(k-1).cdata(50:430,60:580,:)));
        diff_image = abs(rgb2gray(mov(k).cdata(40:480,50:560,:))-rgb2gray(mov(k-1).cdata(40:480,50:560,:)));
        B = imgaussfilt(diff_image,3);
        tmp(k) = max(B,[],'all');
        k = k+1;
        
        
        % check if currentFrame has mice and the framecounter is within limits 
        if max(B,[],'all') > 5   %Eda used max(B,[],'all')>10; I keep it more conservative
            % If framecounter exceeds 54000 (30min), close current video and open a new one
            if framecounter >= 54000
                close(v_out);
                part_counter = part_counter +1;
                v_out = create_video_writer(part_counter); %create a new video file
                open(v_out);
                framecounter = 0;
            end
            
            writeVideo(v_out,mov(k).cdata);
            framecounter=framecounter+1;
%             framemove = [framemove;k];
        end
        
        
    end

end

% close the final video file
close(v_out);

disp('all dynamic frames were extracted');

end