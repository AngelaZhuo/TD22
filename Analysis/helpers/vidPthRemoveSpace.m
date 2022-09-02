function vidPthRemoveSpace
viddir = '\\zistfs02.zi.local\NoSeA\Angela\TD22_videos';
all_vids = getAllFiles(viddir,'*.wmv',1);

for vx = 1:length(all_vids)
   currVidPth =  all_vids{vx};
   currVidPthNew = strrep(currVidPth,' ','');
   if ~strcmp(currVidPth,currVidPthNew)
       movefile(currVidPth,currVidPthNew)
   end
end