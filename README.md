# Igor
<link rel="stylesheet" type="text/css" href="readme.css">
<h2>How to use this repo</h2>
<h3>Important: This project uses traces obtained from a HEKA amplifier protocol which takes <strong>15</strong> current injection traces from patch clamp configurations, going from <strong>-50 pA</strong> to <strong>90 pA</strong>, at intervals of <strong>10 pA</strong>. Importantly, these traces must each be 6.5 seconds long, in the following format:
<br>
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


</h3>
<ol><li>Load PULSE/PM file into your Igor environment using the Patcher's Power Tools package available online</li>
<li>Open and compile Do It All Waves.ipf, Renamewaves.ipf, and Driver.ipf</li>
<li>Run the procedure Do It All.ipf by selecting GL->Do It All Waves</li>
<ul><li>Input the date on which the experiment was performed using the given format</li>
<li>Make sure the bottom one has RenameWaves selected in the dropdown menu</li>
<li>Hit continue</li></ul>
<li>Run the procedure Driver.ipf by selecting Curves->Run cStep Analysis</li>
<ul><li>(NOTE: you will want to change the path it saves to. Search "NewPath/O" to get to the right line and change the Path accordingly, again using the format provided. You may want to make it the same directory where you have the scripts folder from the .zip, since you will need it there later for matlab).</li></ul>
<li>Congratulations! You have analyzed one packed experiment file (.pxp).</li>
<li>Now open Matlab and change the working directory to the scripts folder from the .zip. You are now free to edit the Matlab script as you please to visualize your FI and IV data</li></ol>


<p>Many thanks to Jakub Bialek for the use of his library.</p>
<h0>Copyright © 2009, Jakub Bialek
All rights reserved.

Many thanks to Geng-Lin Li, who provided the base code for Do It All Waves.ipf and RenameWaves.ipf.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.</h0>
