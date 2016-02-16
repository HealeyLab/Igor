%Author: Dan Pollak
clear all
close all

%%
%FI
FIMeg = IBWread('8.24.15FICurves.ibw');
FIMeg = FIMeg.y;
FIBeethoven = IBWread('8.26.15FICurves.ibw');
FIBeethoven = FIBeethoven.y;
FIOpus = IBWread('8.27.15FICurves.ibw');
FIOpus = FIOpus.y;
FIMname = IBWread('9.2.15FICurves.ibw');
FIMname = FIMname.y;
FILincoln = IBWread('9.3.15FICurves.ibw');
FILincoln = FILincoln.y;
%FISelene = IBWread('9.1.15FICurves.ibw');
%FISelene = FISelene.y;

FIgroup1males = [FIBeethoven; FIOpus];
FIgroup2males = [FIMname; FILincoln];
FImales = [FIgroup1males; FIgroup2males];

%FIgroup1females = [FISelene'];
FIgroup1females = [];
FIgroup2females = FIMeg;
FIfemales = [FIgroup1females; FIgroup2females];
%%
%IV

IVMeg = IBWread('8.24.15IVCurves.ibw');
IVMeg = IVMeg.y;
IVBeethoven = IBWread('8.26.15IVCurves.ibw');
IVBeethoven = IVBeethoven.y;
IVOpus = IBWread('8.27.15IVCurves.ibw');
IVOpus = IVOpus.y;
IVMname = IBWread('9.2.15IVCurves.ibw');
IVMname = IVMname.y;
IVLincoln = IBWread('9.3.15IVCurves.ibw');
IVLincoln = IVLincoln.y;
%IVSelene = IBWread('9.1.15IVCurves.ibw');;
%IVSelene = IVSelene.y;

IVgroup1males = [IVBeethoven; IVOpus];
IVgroup2males = [IVMname; IVLincoln];
IVmales = [IVgroup1males; IVgroup2males];

%IVgroup1females = [IVSelene];
IVgroup1females = [];
IVgroup2females = IVMeg;
IVfemales = [IVgroup1females; IVgroup2females];
%% Here's what happened so far
%I concatenated the matrices vertically. Right now, the vectors I want to
%use are sideways. So in the partition below, I will correct this with the
%' operator.

%% Graphing. I may want to call figure from outside the for loop.
xAxis = [-50:10:90];
    %going through each .r value
    for i=1:numel(IVmales(1,1,:))
        figure;
        %going through each cell#
        %graph each vector perpendicular to the xz plane
        IVYAxis = IVmales(:,:,i)';
        
        plot(xAxis, IVYAxis)
        hold on;
        title(strcat(IVFilename, ' trial ', num2str(i)));
        ylabel('mV')
        xlabel('pA')
        
        %savefig('IVmales.fig'));
    end
