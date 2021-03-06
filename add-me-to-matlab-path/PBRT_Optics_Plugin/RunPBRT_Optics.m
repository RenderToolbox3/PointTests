%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the PBRT_Optics renderer.
%   @param sceneFile filename or path of a PBRT-native text scene file.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Invoke the PBRT_Optics renderer on the given PBRT-native text @a
% sceneFile. This function handles some of the boring details of invoking
% PBRT_Optics with Matlab's unix() command.
%
% @details
% if @a hints.isPlot is provided and true, displays an sRGB representation
% of the output image in a new figure.
%
% @details
% Returns the numeric status code and text output from PBRT_Optics.
% Also returns the name of the expected output file from PBRT_Optics.
%
% Usage:
%   [status, result, output] = RunPBRT_Optics(sceneFile, hints)
function [status, result, output] = RunPBRT_Optics(sceneFile, hints)

if nargin < 2
    hints = GetDefaultHints();
end

InitializeRenderToolbox();

%% Where to get/put the input/output
[scenePath, sceneBase] = fileparts(sceneFile);
output = fullfile(scenePath, [sceneBase '.dat']);

%% Invoke PBRT.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% find the PBRT executable
pbrt = getpref('PBRT_Optics', 'executable');
renderCommand = sprintf('%s --outfile %s %s', pbrt, output, sceneFile);
fprintf('%s\n', renderCommand);

% run PBRT in the destination folder to capture all ouput there
originalFolder = pwd();
if exist(scenePath, 'dir')
    cd(scenePath);
end
[status, result] = RunCommand(renderCommand, hints);
cd(originalFolder)

% restore the library search path
setenv(libPathName, originalLibPath);

%% Show a warning or figure?
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneBase)
    
elseif hints.isPlot
    multispectral = ReadDAT(output);
    S = getpref('PBRT_Optics', 'S');
    toneMapFactor = 10;
    isScale = true;
    sRGB = MultispectralToSRGB(multispectral, S, toneMapFactor, isScale);
    ShowXYZAndSRGB([], sRGB, sceneBase);
end
