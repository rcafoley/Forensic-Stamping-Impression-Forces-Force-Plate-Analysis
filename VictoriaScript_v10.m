clear all;
clc;

dbstop if error;

% Loads all .txt files in the folder & create a structure housing their
% details called 'stampData' & signal in a nested cell array called
% forceraw

stampData = dir('*.txt'); 
N = length(stampData);
forceraw = cell(1, N);

for k = 1:N
  forceraw{k} = importdata(stampData(k).name); 
end

% creates a cell array of the file names
filenames = extractfield(stampData,'name');

load('d.mat');

%find max values from each column of data for each trial
for i = 1:N
    
    %index into the first cell of the aray
    
    stamptrial{i} = forceraw{1,i};
    
    %index into each column of the matrix and label as corresponding force
    %channel for that trial
    
    trialfx{i} = stamptrial{i}(1:end,1);
    trialfy{i} = stamptrial{i}(1:end,2);
    trialfz{i} = stamptrial{i}(1:end,3);
    trialmx{i} = stamptrial{i}(1:end,4);
    trialmy{i} = stamptrial{i}(1:end,5);
    trialmz{i} = stamptrial{i}(1:end,6);
    
%   %replace zeroes with NaN and removes the data
    
    trialfx{i}(trialfx{i}==0) = NaN;
    trialfx{i} = trialfx{i}(~isnan(trialfx{i}));
    trialfy{i}(trialfy{i}==0) = NaN;
    trialfy{i} = trialfy{i}(~isnan(trialfy{i})); 
    trialfz{i}(trialfz{i}==0) = NaN;
    trialfz{i} = trialfz{i}(~isnan(trialfz{i})); 
    trialmx{i}(trialmx{i}==0) = NaN;
    trialmx{i} = trialmx{i}(~isnan(trialmx{i})); 
    trialmy{i}(trialmy{i}==0) = NaN;
    trialmy{i} = trialmy{i}(~isnan(trialmy{i})); 
    trialmz{i}(trialmz{i}==0) = NaN;
    trialmz{i} = trialmz{i}(~isnan(trialmz{i})); 
    
    %Filter the data - 50Hz lowpass 4th order Butterworth
    
    trialfx{i} = filtfilt(SOS,G,trialfx{i}); 
    trialfy{i} = filtfilt(SOS,G,trialfy{i}); 
    trialfz{i} = filtfilt(SOS,G,trialfz{i}); 
    trialmx{i} = filtfilt(SOS,G,trialmx{i});
    trialmy{i} = filtfilt(SOS,G,trialmy{i}); 
    trialmz{i} = filtfilt(SOS,G,trialmz{i}); 
    
    %de-bias signals
    
    trialfx100ms{i} = trialfx{i}(1:100,1);
        fx{i} = trialfx{i}(1:end,1)-mean(trialfx100ms{i});
    
    trialfy100ms{i} = trialfy{i}(1:100,1);
        fy{i} = trialfy{i}(1:end,1)-mean(trialfy100ms{i});
    
    trialfz100ms{i} = trialfz{i}(1:100,1);
        fz{i} = trialfz{i}(1:end,1)-mean(trialfz100ms{i});
    
    trialmx100ms{i} = trialmx{i}(1:100,1);
        mx{i} = trialmx{i}(1:end,1)-mean(trialmx100ms{i});
    
    trialmy100ms{i} = trialmy{i}(1:100,1);
        my{i} = trialmy{i}(1:end,1)-mean(trialmy100ms{i});
    
    trialmz100ms{i} = trialmz{i}(1:100,1);
        mz{i} = trialmz{i}(1:end,1)-mean(trialmz100ms{i});
    
    %finds max(s)

    fxmax{i} = max(fx{i});
    fymax{i} = max(fy{i});
    fzmax{i} = max(fz{i});
    mxmax{i} = max(mx{i});
    mymax{i} = max(my{i});
    mzmax{i} = max(mz{i});
    
    %finds duration of force
    fz100ms{i} = fz{i}(1:100,1);
    threshLevelfz{i} = 5*(mean(abs(fz100ms{i})));
    
    durationsamples{i} = nnz(fz{i} > threshLevelfz{i});
    forcedurationfz{i} = (durationsamples{i}/1000);


    %COP calculations
%     copx{i} = (-1)*(my{i}/fz{i});
%     copy{i} = mx{i}/fz{i};

end

%take max data and put it into a cell array, then a table

processeddata1 = [filenames; fxmax; fymax; fzmax; mxmax; mymax; mzmax; forcedurationfz;]';
processeddata = cell2table(processeddata1,'VariableNames',{'Filenames','FxMax_N','FyMax_N','FzMax_N','MxMax_N','MyMax_N','MzMax_N','DurationOfForce_secs'});

%all data is in Newtons
%export
writetable(processeddata, 'stampingforcedataday2.xlsx')