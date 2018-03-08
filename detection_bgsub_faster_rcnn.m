fgd = vision.ForegroundDetector('NumGaussians', 3, 'NumTrainingFrames', 30);

loadfile = 'pkcrossing_grayscale.avi';
savefile = 'pkcrossing_bg_detected.avi';
trafficvid = vision.VideoFileReader(loadfile);
td = VideoReader(loadfile);

videoPlayer = vision.VideoPlayer('Name', 'Detected Cars');
videoPlayer.Position(3:4) = [650,400];
outputVideo = VideoWriter(fullfile('./', savefile));
outputVideo.FrameRate = 4*td.FrameRate;
open(outputVideo);
clear td;

for k = 1:10
    frame = step(trafficvid);
    fg = step(fgd, frame);
end

se = strel('square', 3);
filt_fg = imopen(fg, se);

blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
                                   'AreaOutputPort', false, ...
                                   'CentroidOutputPort', false, ...
                                   'MinimumBlobArea', 150);
bbox = step(blobAnalysis, filt_fg);
cars_in = 0;
cars_out = 0;
while ~isDone(trafficvid)
    sf = step(trafficvid);
    fg = step(fgd, sf);
    filt_fg = imopen(fg, se);
    bbox = step(blobAnalysis, filt_fg);
    [n_o tat] = size(bbox);
    cars_count = double.empty(0, 2);
    
    cars_count(1) = cars_in;
    cars_count(2) = cars_out;
    textcoords = [10 10; 50 10];
    box_color = {'green', 'red'};
    for i=1:n_o
        singleBox = rgb2gray(imcrop(sf, bbox(i, :)));

        [xB yB] = size(singleBox);
        singleBox = padarray(singleBox, max(max(32-xB, 32-yB), 0));
        
        try
           [bboxes, scores] = detect(detector, singleBox);
           s_m = mean(scores);
           if (s_m>0.50)
               Im = insertObjectAnnotation(sf, 'rectangle', bbox(i, :), s_m);
               Im = insertShape(Im, 'Line', [152 38 268 126], 'Color', 'green');
               Im = insertShape(Im, 'Line', [273 131 438 214], 'Color', 'red');
               cir_x = bbox(i,1) + bbox(i,3)/2;
               cir_y = bbox(i,2) + bbox(i,4)/2;
               radius_needed = 3;
               result = insertShape(Im, 'Circle', [cir_x cir_y 5], 'Color', 'blue');
               [add_x add_y] = linecirc(0.763, -78.175, cast(cir_x, 'single'), cast(cir_y, 'single'), radius_needed);
               [sub_x sub_y] = linecirc(0.502, -5.571, cast(cir_x, 'single'), cast(cir_y, 'single'), radius_needed);
               if(~isequaln(add_x(1),NaN))
                   cars_in = cars_in + 1;
               end
               if(~isequaln(sub_x(1),NaN))
                   cars_out = cars_out + 1;
               end
               result = insertText(result, textcoords, cars_count, 'BoxColor', box_color, 'BoxOpacity', 1, 'FontSize', 14);
            
               result = min(max(result, 0.0), 1.0);
               step(videoPlayer, result);
               writeVideo(outputVideo, result);

           else
               sf = insertShape(sf, 'Line', [152 38 268 126], 'Color', 'green');
               sf = insertShape(sf, 'Line', [273 131 438 214], 'Color', 'red');
               Im = sf;
               result = insertText(Im, textcoords, cars_count, 'BoxColor', box_color, 'BoxOpacity', 1, 'FontSize', 14);
               result = min(max(result, 0.0), 1.0);
               step(videoPlayer, result);
               writeVideo(outputVideo, result);
           end

        catch
           sf = insertShape(sf, 'Line', [152 38 268 126], 'Color', 'green');
           sf = insertShape(sf, 'Line', [273 131 438 214], 'Color', 'red');
           sf = min(max(sf, 0.0), 0.99999);
           result = insertText(Im, textcoords, cars_count, 'BoxColor', box_color, 'BoxOpacity', 1, 'FontSize', 14);
           result = min(max(result, 0.0), 1.0);
           step(videoPlayer, result);
           writeVideo(outputVideo, result);
           disp('No vehicle detected in frame');
        end
   end
end

close(outputVideo);
release(trafficvid);