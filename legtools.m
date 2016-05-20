classdef legtools
    methods (Static)
        function append(lh, newString)
            % Make sure lh exists and is a legend object
            if ~exist('lh', 'var') || ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:append:InvalidLegendHandle', ...
                      'Invalid legend handle provided' ...
                      );
            end

            % Make sure newString exists & isn't empty
            if ~exist('newString', 'var') || isempty(newString)
                error('legtools:append:EmptyStringInput', ...
                      'No strings provided' ...
                      );
            end

            % Validate the input strings
            newString = legtools.fixstrings(newString);

            % To make sure we target the right axes, pull the legend's
            % PlotChildren and get their parent axes object
            parentaxes = lh.PlotChildren(1).Parent;

            % Get line object handles
            plothandles = flipud(parentaxes.Children); % Flip so order matches

            % Update legend with line object handles & new string array
            newlegendstr = [lh.String newString];  % Need to generate this before adding new plot objects
            lh.PlotChildren = plothandles;
            lh.String = newlegendstr;
        end
    end

    methods (Static, Access = private)
        function [newstr] = fixstrings(oldstr)
            newstr = oldstr;  % Lazy output initialization
            if ischar(newstr)
                % Input string is a character array, assume it's a single string and
                % dump into a cell
                newstr = {newstr};
            end

            % Check shape of newStrings and make sure it's 1D
            if size(newstr, 1) > 1
                newstr = reshape(newstr', 1, []);
            end
        end
    end
end