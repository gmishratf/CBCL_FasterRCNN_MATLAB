trafficvid = VideoReader('pkcrossing_grayscale.avi');
nFrames = trafficvid.NumberOfFrames;
I = read(trafficvid, 1);
taggedCars = zeros([size(I,1), size(I,2), 3 nFrames], class(I));

videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [650,400];
outputVideo = VideoWriter(fullfile('./', 'pkcrossing_det_no_blob.avi'));
outputVideo.FrameRate = trafficvid.FrameRate;
open(outputVideo);
cars_in = 0;
cars_out = 0;
for k = 1 : nFrames 
   sf = im2double(read(trafficvid, k));
   %sf = imresize(sf, 0.5);
   singleFrame_ = gpuArray(rgb2gray(sf));
   %singleFrame = imsharpen(SingleFrame);
   %singleFrame_ = imadjust(singleFrame_);
   %singleFrame_ = histeq(singleFrame_);
   %singleFrame_ = gather(singleFrame_);
   %singleFrame_ = adapthisteq(singleFrame_);
   cars_count(1) = cars_in;
   cars_count(2) = cars_out;
   textcoords = [10 10; 50 10];
   box_color = {'green', 'red'};
   try
       [bboxes, scores] = detect(detector, singleFrame_);
       Im = insertObjectAnnotation(sf, 'rectangle', bboxes, scores);
       numCars = size(bboxes, 1);
       %videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
       result = insertText(Im, [10 10], numCars, 'BoxOpacity', 1, 'FontSize', 14);
        
       %result = imresize(result, 2);
       result = min(max(result, 0.0), 1.0);
       step(videoPlayer, result);
       writeVideo(outputVideo, result);
   catch
       sf = min(max(sf, 0.0), 0.99999);
       writeVideo(outputVideo, sf);
       disp('No vehicle detected in frame');
   end
end

close(outputVideo);
release(trafficvid);