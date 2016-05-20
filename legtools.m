classdef legtools
% LEGTOOLS is a MATLAB class definition providing the user with a set of
% methods to modify existing Legend objects.
%
% This is an HG2 specific implementation and requires MATLAB R2014b or
% newer.
%
% legtools methods:
%      append - Adds string(s) to the end of the legend.
%
% See also legend

    methods
        function obj = legtools
            % Dummy constructor so we don't return an empty class instance
            clear obj
        end
    end

    methods (Static)
        function append(lh, newStrings)
            % APPEND appends strings, newStrings, to the specified Legend
            % object, lh. newStrings can be a 1D character array or a 1D
            % cell array of strings. Character arrays are treated as a
            % single string. If multiple Legend objects are specified, only
            % the first will be modified.
            %
            % The legend will only be updated with the new strings if the
            % number of strings in the existing legend plus the number of
            % strings in newStrings is the same as the number of plots on
            % the associated axes object (e.g. if you have 2 lineseries and
            % 2 legend entries already no changes will be made).
            legtools.verchk()

            % Make sure lh exists and is a legend object
            if ~exist('lh', 'var') || ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:append:InvalidLegendHandle', ...
                      'Invalid legend handle provided' ...
                      );
            end

            % Pick first legend handle if more than one is passed
            if numel(lh) > 1
                warning('legtools:append:TooManyLegends', ...
                        '%u Legend objects specified, modifying the first one only', ...
                        numel(lh) ...
                        );
                lh = lh(1);
            end

            % Make sure newString exists & isn't empty
            if ~exist('newStrings', 'var') || isempty(newStrings)
                error('legtools:append:EmptyStringInput', ...
                      'No strings provided' ...
                      );
            end

            % Validate the input strings
            newStrings = legtools.fixstrings(newStrings);

            % To make sure we target the right axes, pull the legend's
            % PlotChildren and get their parent axes object
            parentaxes = lh.PlotChildren(1).Parent;

            % Get line object handles
            plothandles = flipud(parentaxes.Children);  % Flip so order matches

            % Update legend with line object handles & new string array
            newlegendstr = [lh.String newStrings];  % Need to generate this before adding new plot objects
            lh.PlotChildren = plothandles;
            lh.String = newlegendstr;
        end
    end

    methods (Static, Access = private)
        function verchk()
            % Throw error if we're not using R2014b or newer
            if verLessThan('matlab','8.4')
                error('legtools:UnsupportedMATLABver', ...
                      'MATLAB releases prior to R2014b are not supported' ...
                      );
            end
        end


        function [newstr] = fixstrings(oldstr)
            newstr = oldstr;  % Lazy output initialization
            if ischar(newstr)
                % Input string is a character array, assume it's a single 
                % string and dump into a cell
                newstr = {newstr};
            end

            % Check shape of newStrings and make sure it's 1D
            if size(newstr, 1) > 1
                newstr = reshape(newstr', 1, []);
            end
        end
    end
end