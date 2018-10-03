close all; clc;

%read in video file
videoObj = VideoReader('../media/scripts.mp4'); %approx 30 page turns
template = imread('../media/examtemplate.jpg');

SURFpoints = detectSURFFeatures(rgb2gray(template));
imshow(template); 
hold on;
plot(SURFpoints);

numFrames = int16(videoObj.FrameRate * (videoObj.Duration -1)); %More loop iterations than frames so discard last second of video

diff = zeros(1, numFrames-1);

for frame=1:numFrames
   currFrame = readFrame(videoObj);
   
   if frame ~= 1
    diff(1, frame) = immse(currFrame, prevFrame);
   end
   
   prevFrame = currFrame;
end

bins = 60;

figure
title('Histogram Of MSE of Frames')
histogram(diff, bins)
xlabel('Mean Squared Error')
ylabel('Frequency')

%threshold = graythresh(diff);
bin_freq = histcounts(diff, bins);

temp = find(bin_freq == 0);
truncate_ind = temp(1);

max_mse = (max(diff) / bins) * truncate_ind;

indices = find(diff >= max_mse);
diff(indices) = [];

%{
%assuming bimodal histogram
[maxbin_val1, maxbin_ind1] = max(bin_freq);
temp = bin_freq;
temp(maxbin_ind1) = [];
[maxbin_val12, maxbin_ind2] = max(bin_freq);
maxbin_ind2 = maxbin_ind2 + 1;

%make sure maxbin_ind2 is further along array
if maxbin_ind2 < maxbin_ind1 
   val = maxbin_ind1;
   maxbin_ind1 = maxbin_ind2;
   maxbin_ind2 = val;
end

temp = bin_freq(maxbin_ind1:maxbin_ind2);

[minbin_val, minbin_ind] = min(temp);
%}

figure
title('Histogram Of MSE of Frames (Outliers Removed)')
histogram(diff, bins)
xlabel('Mean Squared Error')
ylabel('Frequency')

figure
plot(1:length(diff), diff)
title('Timeline Of MSE of Frames')
xlabel('Frame')
ylabel('MSE')

frame_capture = false;
still_frame_counter = 0;
still_frames_cap_threshold = 3;

analysis_images

while hasFrame(videoObj)
   currFrame = readFrame(videoObj);
   MSE = immse(currFrame, prevFrame);
   if MSE == 0 && frame_capture == false
       still_frame_counter = still_frame_counter + 1;
       if still_frame_counter >= still_frames_cap_threshold
          still_frame_counter = 0;
          frame_capture = true;
          analysis_images = [analysis_images currFrame];
       end
   elseif frame_capture == true && MSE > 0
       frame_capture = false;
   end 
   
   prevFrame = currFrame;
end
