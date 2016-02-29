%Author: Dan Pollak
clear all
close all
!synclient HorizTwoFingerScroll=0
IVList = dir('*.*IV*.ibw');%the & ensures theres at least one character before 'IV...'
FIList = dir('*.*FI*.ibw');
N = size(IVList, 1);%both lists should be same size
for k=1:N
    %convert the igor files to matlab struct data types
    IVFilename = IVList(k).name;
    FIFilename = FIList(k).name;
    
    %read the structs
    IVc = IBWread(IVFilename);
    FIc = IBWread(FIFilename);
    
    %take relevant struct attribute
    IV = IVc.y;
    IV = IV(1:end/2, :, :);%because it doubles it for some reason
    FI = FIc.y;
    FI = FI(1:end/2, :, :);%because it doubles it for some reason
        
    %% New Graphing
    xAxis = -50:10:90;
    %averaging each cell#
    %graph each vector perpendicular to the xz plane
    %FI
    figure;plot(xAxis, mean(FI, 3)', 'LineWidth', 1.25)
    hold on;
    title(FIFilename);
    ax = gca;
    ax.XTick = -50:10:90;
    ax.XTickLabelRotation = 45;
    ylabel('Hz')
    xlabel('pa')
    savefig(strcat(FIFilename, '.fig'));
    %IV
    figure;plot(xAxis, mean(IV, 3)', 'LineWidth', 1.25)
    hold on;
    title(IVFilename);
    ax = gca;
    ax.XTick = -50:10:90;
    ax.XTickLabelRotation = 45;
    ylabel('mV')
    xlabel('pA')
    ax.YTick = -1.2:0.01:0;
    ylim([-.12, 0])
    
    savefig(strcat(IVFilename, '.fig'));
%         for j=1:numel(FI(:,1,1))%go through number of cells
%             %printing the num of spikes present
%             currentCell = FI(j,:,i);%vector, column, layer
%             currentCell%just displays the vector
%         end
        
   

end


