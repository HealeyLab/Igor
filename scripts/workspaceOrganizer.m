%% Author: Dan Pollak
%Script to organize workspace into appropriate quadrants
%%
clear all
close all
%%
%FI
FIMeg = IBWread('8.24.15FICurves.ibw');
FIMeg = FIMeg.y;
FIMeg = FIMeg(1:end/2, :, :);%because it doubles it for some reason

FIBeethoven = IBWread('8.26.15FICurves.ibw');
FIBeethoven = FIBeethoven.y;
FIBeethoven = FIBeethoven(1:end/2, :, :);

FIOpus = IBWread('8.27.15FICurves.ibw');
FIOpus = FIOpus.y;
FIOpus = FIOpus(1:end/2, :, :);%because it doubles it for some reason

FIMname = IBWread('9.2.15FICurves.ibw');
FIMname = FIMname.y;
FIMname = FIMname(1:end/2, :, :);%because it doubles it for some reason

FILincoln = IBWread('9.3.15FICurves.ibw');
FILincoln = FILincoln.y;
FILincoln = FILincoln(1:end/2, :, :);%because it doubles it for some reason

FISelene = IBWread('9.1.15FICurves.ibw');
FISelene = cat(3, FISelene.y, zeros(8,15));
%FISelene = FISelene(1:end/2, :, :);%because it doubles it for some reason

FIgroup1males = [FIBeethoven; FIOpus];
FIgroup2males = [FIMname; FILincoln];
FImales = [FIgroup1males; FIgroup2males];

FIgroup1females = [FISelene];
FIgroup2females = [FIMeg];
FIfemales = [FIgroup1females; FIgroup2females];

FIgroup1 = [FIgroup1females; FIgroup1males];
FIgroup2 = [FIgroup2females; FIgroup2males];
%%
%IV

IVMeg = IBWread('8.24.15IVCurves.ibw');
IVMeg = IVMeg.y;
IVMeg = IVMeg(1:end/2, :, :);%because it doubles it for some reason

IVBeethoven = IBWread('8.26.15IVCurves.ibw');
IVBeethoven = IVBeethoven.y;
IVBeethoven = IVBeethoven(1:end/2, :, :);%because it doubles it for some reason

IVOpus = IBWread('8.27.15IVCurves.ibw');
IVOpus = IVOpus.y;
IVOpus = IVOpus(1:end/2, :, :);%because it doubles it for some reason

IVMname = IBWread('9.2.15IVCurves.ibw');
IVMname = IVMname.y;
IVMname = IVMname(1:end/2, :, :);%because it doubles it for some reason

IVLincoln = IBWread('9.3.15IVCurves.ibw');
IVLincoln = IVLincoln.y;
IVLincoln = IVLincoln(1:end/2, :, :);%because it doubles it for some reason

IVSelene = IBWread('9.1.15IVCurves.ibw');
IVSelene = cat(3, IVSelene.y, zeros(8,15));
%IVSelene = IVSelene(1:end/2, :, :);%because it doubles it for some reason

IVgroup1males = [IVBeethoven; IVOpus];
IVgroup2males = [IVMname; IVLincoln];
IVmales = [IVgroup1males; IVgroup2males];

IVgroup1females = [IVSelene];
IVgroup2females = IVMeg;
IVfemales = [IVgroup1females; IVgroup2females];

IVgroup1 = [IVgroup1females; IVgroup1males];
IVgroup2 = [IVgroup2females; IVgroup2males];
%% Here's what happened so far
%I concatenated the matrices vertically. Right now, the vectors I want to
%use are sideways. So in the partition below, I will correct this with the
%' operator.

%% Graphing. Just change the first TWO fields below.
toGraph = IVfemales;
name = 'IVfemales';
xAxis = -50:10:90;
%going through each cell#
%graph each vector perpendicular to the xz plane

toGraph = mean(toGraph, 3);
figure; 
handle = plot(xAxis, toGraph, 'LineWidth', 1.25);
hold on;
title(name);
ax = gca;
ax.XTick = -50:10:90;
ax.XTickLabelRotation = 45;
legend(handle, num2str((1:numel(toGraph(:,1,1)))'),'Location', 'Best');
if(strfind(name, 'IV') ~= 0)
    ylabel('mV')
    xlabel('pA')
    ax.YTick = -1.2:0.01:0;
    ylim([-.12, 0])
    sem = std(toGraph)/sqrt(length(toGraph(:,1,1)));%not sure if 2 is the right dimension here
    toGraph = mean(toGraph);%changing toGraph further, compressing it to one row
    errorbar(xAxis, toGraph, sem, 'color', 'b');
elseif(strfind(name, 'FI') ~= 0)
    ylabel('Hz')
    xlabel('pa')
end
savefig(strcat(name, '.fig'));

