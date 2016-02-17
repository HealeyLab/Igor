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

FIgroup1females = [FIgroup2females; FIgroup2females];
FIgroup1males = [FIgroup2males; FIgroup2males];

FIgroup1 = [FIgroup1females; FIgroup1males];
FIgroup2 = [FIgroup2females; FIgroup2males];
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

IVgroup1 = [IVgroup1females; IVgroup1males];
IVgroup2 = [IVgroup2females; IVgroup2males];
%% Here's what happened so far
%I concatenated the matrices vertically. Right now, the vectors I want to
%use are sideways. So in the partition below, I will correct this with the
%' operator.

%% Graphing. just change the field up below.
toGraph = IVgroup2;
name = 'IVgroup2';
xAxis = -50:10:90;
%going through each cell#
%graph each vector perpendicular to the xz plane

plot(xAxis, mean(toGraph, 3)')
hold on;
title(name);
ax = gca;
ax.XTick = [-50:10:90];
ax.XTickLabelRotation = 45;
if(findstr(name, 'IV') ~= 0)
    ylabel('mV')
    xlabel('pA')
    ax.YTick = [-1.2:0.01:0];
    ylim([-.12, 0])
elseif(findstr(name, 'IV') ~= 0)
    ylabel('Hz')
    xlabel('pa')
end
savefig(strcat(name, '.fig'));

