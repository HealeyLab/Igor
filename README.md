# Igor
<h2>How to use this repo</h2>
<h3>For analyzing current step data</h3>
<p>Important: This project uses traces obtained from a HEKA amplifier protocol which takes <strong>15</strong> current injection traces from patch clamp configurations, going from <strong>-50 pA</strong> to <strong>90 pA</strong>, at intervals of <strong>10 pA</strong>. Importantly, these traces must each be <strong>6.5</strong> seconds long, in the following format:</p>
<table style="width:100%">
  <tr>
    <td>3s</td>
    <td>.5s</td> 
    <td>3s</td>
  </tr>
  <tr>
    <td>------>------>------</td>
    <td>------</td> 
    <td>------>------>------</td>
  </tr>
  <tr>
    <td>spontaneous</td>
    <td>current injection</td>
    <td>spontaneous</td>
  </tr>
</table>
<br>

<ol>
  <li>Load PULSE/PM file into your Igor environment using the Patcher's Power Tools package available online</li>
  <!-- ![Igor Patcher's Power Tools menu](https://github.com/zeebie15/Igor/edit/PPTMenu.jpg) -->
  <ul>
    <li>Find your .dat file using the top toolbar.</li>
    <li>Only select one HEKA stimulus/protocol, the one corresponding to <strong>current steps</strong>, if there is more than one (highlighted in blue)</li>
    <li>Select the 'include' radio button.</li>
    <li>Do It! (bottom left)</li>
  </ul>
  <li>Open and compile Renamewaves.ipf and Driver.ipf</li>
  <li>Run the procedure Do It All.ipf by selecting GL->Do It All Waves</li>
  <ul>
    <li>Input the date on which the experiment was performed using the given format</li>
    <li>Input whether you are doing current steps or spontaneous recordings by inputting either "Spont" or "Current."</li>
    <li>Make sure the bottom one has RenameWaves selected in the dropdown menu</li>
    <li>Hit continue</li>
  </ul>
  <li>Run the procedure Driver.ipf by selecting Curves->Run cStep Analysis</li>
  <ul>
    <li>(NOTE: you will want to change the path it saves to. Search "NewPath/O" to get to the right line and change the Path accordingly, again using the format provided. You may want to make it the same directory where you have the scripts folder from the .zip, since you will need it there later for matlab).</li>
  </ul>
  <li>Congratulations! You have analyzed one packed experiment file (.pxp).</li>
  <li>Now open Matlab and change the working directory to the scripts folder from the .zip. You are now free to edit the Matlab script as you please to visualize your FI and IV data</li>
</ol>
<!-- 




-->
<h3>For analyzing spontaneous data</h3>
<p>Important: This part of the analysis uses traces obtained from a HEKA amplifier protocol which takes <strong>1 60 s</strong> trace recording from a patch clamp configuration.  
<br>
<ol>
  <li>Load PULSE/PM file into your Igor environment using the Patcher's Power Tools package available online</li>
  <!-- ![Igor Patcher's Power Tools menu](hamdanspam.github.com/zeebie15/Igor/edit/PPTMenu.jpg) -->
  <ul>
    <li>Find your .dat file using the top toolbar.</li>
    <li>Only select one HEKA stimulus/protocol, the one corresponding to <strong>60 s spontaneous recordings</strong>, if there is more than one (highlighted in blue)</li>
    <li>Select the 'include' radio button.</li>
    <li>Do It! (bottom left)</li>
  </ul>
  <li>Open and compile Renamewaves.ipf and NewDriver.ipf</li>
  <li>Run the procedure Do It All.ipf by selecting GL->Do It All Waves</li>
  <ul>
    <li>Input the date on which the experiment was performed using the given format</li>
    <li>Input whether you are doing current steps or spontaneous recordings by inputting either "Spont" or "Current"</li>
    <li>Make sure the bottom one has RenameWaves selected in the dropdown menu</li>
    <li>Hit continue</li>
  </ul>
  <li>Run the procedure NewDriver.ipf by selecting RS->Run Analysis</li>
  <ul>
    <li>If this results in error, ensure your debugger is enabled by right clicking in a procedure window and clicking "enable debugger"</li>
    <li>Rerun analysis, and if the debugger pops up, hit the escape key</li>
    <li>This should eventually open up statsWave and indexWave.</li>
  </ul>
</ol>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<p style="font-size":"1">Many thanks to Geng-Lin Li, who provided the code for Do It All Waves.ipf and RenameWaves.ipf.</p>
<p style="font-size":"1">Many thanks to Jakub Bialek for the use of his library. Copyright © 2009, Jakub Bialek

Thanks to jonas from the MATLAB file exchange community, whose code I use to create beeswarm plots.
