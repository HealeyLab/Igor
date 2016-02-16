%Author: Dan Pollak
clear all
close all

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
    FI = FIc.y;
    
    xAxis = (-50:10:90);
    
    %%
    %going through each .r value
%     for i=1:numel(IV(1,1,:))
%         figure;
%         %going through each cell#
%         %graph each vector perpendicular to the xz plane
%         IVYAxis = IV(:,:,i);
%         
%         plot(IVYAxis, xAxis)
%         hold on;
%         title(strcat(IVFilename, ' trial ', num2str(i)));
%         ylabel('pA')
%         xlabel('mV')
%         
%         savefig(strcat(IVFilename, '.fig'));
%         
%     end
%     
    for i=1:numel(FI(1,1,:))
%         %going through each cell#
%         figure;
%         %graph each file along the xz plane
%         %this takes the ith "page"
%         FIYAxis = FI(:,:,i);
%         
%         plot(xAxis, FIYAxis)
%         hold on;
%         
%         title(strcat(FIFilename, ' trial ', num2str(i)));
%         xlabel('pA');
%         ylabel('Hz');
%         
%         savefig(strcat(FIFilename, '.fig'));
        
        strcat(IVFilename, ':')
        for j=1:numel(FI(:,1,1))%go through number of cells
            %printing the num of spikes present
            currentCell = FI(j,:,i);%vector, column, layer
            currentCell%just displays the vector
        end
        
    end

end


