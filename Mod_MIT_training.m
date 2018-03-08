annotpath = '<ENTER YOUR CURRENT FOLDER PATH HERE>\MIT Car dataset\Anno_XML\*.xml';
imgpath = '<ENTER YOUR CURRENT FOLDER PATH HERE>\MIT Car dataset\Images\*.jpg';
vd = build_data(path);
for i =1:3547
    vd.vehicle{i} = round(vd.vehicle{i}/4);
    disp(i)
end


vehicleDataset = vd(1:3000, :);
%vehicleDataset(1:4, :)
%vehicleDataset
%dataDir = fullfile(toolboxdir('vision'),'visiondata');
%vehicleDataset.imageFilename = fullfile(dataDir, vehicleDataset.imageFilename);
I = imread(vehicleDataset.imageFilename{1});
I = insertShape(I, 'Rectangle', vehicleDataset.vehicle{1});
I = imresize(I, 3);
figure
imshow(I)


idx = floor(0.85 * height(vehicleDataset));
trainingData = vehicleDataset(1:idx, :);
testData = vehicleDataset(idx:end, :);
inputLayer = imageInputLayer([32 32]);
filterSize = [3 3];
numFilters = 32;


middleLayers = [
                convolution2dLayer(filterSize, numFilters, 'Padding', 1)
                reluLayer()
                convolution2dLayer(filterSize, numFilters, 'Padding', 1)
                reluLayer()
                maxPooling2dLayer(3, 'Stride', 2)
                ];

finalLayers = [
                fullyConnectedLayer(64)
                reluLayer()
                fullyConnectedLayer(width(vehicleDataset))
                softmaxLayer()
                classificationLayer()
                ];

layers = [
                inputLayer
                middleLayers
                finalLayers
                ]

optionsStage1 = trainingOptions('sgdm', ...
    'MaxEpochs', 50, ...
    'InitialLearnRate', 1e-5, ...
    'CheckpointPath', tempdir);

optionsStage2 = trainingOptions('sgdm', ...
    'MaxEpochs', 50, ...
    'InitialLearnRate', 1e-5, ...
    'CheckpointPath', tempdir);

optionsStage3 = trainingOptions('sgdm', ...
    'MaxEpochs', 50, ...
    'InitialLearnRate', 1e-6, ...
    'CheckpointPath', tempdir);

optionsStage4 = trainingOptions('sgdm', ...
    'MaxEpochs', 50, ...
    'InitialLearnRate', 1e-6, ...
    'CheckpointPath', tempdir);

options = [
            optionsStage1
            optionsStage2
            optionsStage3
            optionsStage4
            ];

doTrainingAndEval = true;


if doTrainingAndEval
    rng(0);
    detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
                                             'NegativeOverlapRange', [0 0.6], ...
                                             'PositiveOverlapRange', [0.7 1], ...
                                             'BoxPyramidScale', 1.2);
else
    detector = data.detector;
end


if doTrainingAndEval
    resultsStruct = struct([]);
    for i = 1:height(testData)
        I = imread(testData{i, 1});
        [bboxes, scores, labels] = detect(detector, I);
        resultsStruct(i).Boxes = bboxes;
        resultsStruct(i).Scores = scores;
        resultsStruct(i).Labels = labels;
    end
    results = struct2table(resultsStruct);
else
    results = data.results;
end


expectedResults = testData(:, 2:end);
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);


figure
plot(recall, precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.1f', ap))



