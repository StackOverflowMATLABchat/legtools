function legappend(newStrings)
% LEGAPPEND appends new entries to a legend
%
% LEGAPPEND(newStrings) appends newStrings to the existing legend.
% newStrings can be a 1D character array or a 1D cell array of strings.
% Character arrays are treated as a single string.
%
% If there are multiple legend objects in the current figure window (e.g.
% subplots), LEGAPPEND operates only on the first legend object returned.
%
% LEGAPPEND requires MATLAB R2014b or newer
%
% This is an HG2 specific fork of Chad Greene's LEGAPPEND
% http://www.mathworks.com/matlabcentral/fileexchange/47228-legappend

if verLessThan('matlab','8.4')
    % MATLAB versions older than R2014b unsupported
    error('legappend:UnsupportedMATLABver', ...
          'MATLAB releases prior to R2014b are not supported' ...
          );
end

% Validate the input strings
newStrings = checkstrings(newStrings);

% Find the legend object to operate on
lh = findlegend();

% Add strings to legend
newstr = [lh.String newStrings];
appendtolegend(lh, newstr)
end

function appendtolegend(lh, newstr)
% Get line object handles
% To make sure we target the right axes, pull the current legend
% PlotChildren and get the parent axes object
parentaxes = lh.PlotChildren(1).Parent;
plothandles = flipud(parentaxes.Children); % Flip so order matches

% Update legend with line object handles & new string array
lh.PlotChildren = plothandles;
lh.String = newstr;
end

function newStrings = checkstrings(newStrings)
% Make sure input isn't empty
if ~exist('newStrings', 'var') || isempty(newStrings)
    error('legappend:EmptyInput', ...
          'No strings provided' ...
         );
end

if ischar(newStrings)
    % Input string is a character array, assume it's a single string and
    % dump into a cell
    newStrings = {newStrings};
end

% Check shape of newStrings and make sure it's 1D
if size(newStrings, 1) > 1
    newStrings = reshape(newStrings', 1, []);
end

end

function [lh] = findlegend()
legendhandles = findobj(gcf, 'Type', 'legend');

if ~isempty(legendhandles)
    % Operate only on the first legend handle returned
    lh = legendhandles(1);
else
    error('legappend:NoLegend', ...
          'No legend objects present in current figure' ...
          );
end
end