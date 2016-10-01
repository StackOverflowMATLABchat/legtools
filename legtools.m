classdef legtools
    %LEGTOOLS A class of methods to modify existing Legend objects.
    %
    %   LEGTOOLS requires MATLAB R2014b or newer.
    %
    %   LEGTOOLS methods:
    %    append   - Add one or more entries to the end of the legend
    %    permute  - Rearrange the legend entries
    %    remove   - Remove one or more legend entries
    %    adddummy - Add one or more entries to the legend for unsupported
    %               graphics objects
    %
    %    See also legend
    
    methods
        function obj = legtools
            % Dummy constructor so we don't return an empty class instance
            clear obj
        end
    end
    
    methods (Static)
        function append(lh, newStrings)
            % APPEND Append entries to legend
            %
            %    LEGTOOLS.APPEND(lh,newStrings) appends strings,
            %    newStrings, to the specified Legend object, lh. newStrings
            %    can be a 1D character array or a 1D cell array of strings.
            %    Character arrays are treated as a single string. If
            %    multiple Legend objects are specified, only the first will
            %    be modified.
            %
            %    The total number of entries, i.e. the number of current
            %    entries plus the number of entries in newStrings, must not
            %    exceed the number of graphics objects in the axes. Any
            %    extra entries to append will not be added to the legend.
            %    For example, if you have plotted two lines and the current
            %    legend contains one entry, appending three new entries
            %    will only append the first of them.
            legtools.verchk()
            lh = legtools.handlecheck('append', lh);
            
            % Make sure newString exists & isn't empty
            if ~exist('newStrings', 'var') || isempty(newStrings)
                error('legtools:append:EmptyStringInput', ...
                    'No strings provided' ...
                    );
            end
            
            newStrings = legtools.strcheck('append', newStrings);
            
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
        
        
        function permute(lh, order)
            % PERMUTE rearranges the entries of the specified Legend
            % object, lh, so they are then the order specified by the
            % vector order. order must be the same length as the number of
            % legend entries in lh. All elements of order must be unique,
            % real, positive, integer values.
            legtools.verchk()
            
            % TODO: Add check for presence of order
            
            lh = legtools.handlecheck('permute', lh);
            
            % Catch length & uniqueness issues with order, let MATLAB deal
            % with the rest.
            if numel(order) ~= numel(lh.String)
                error('legtools:permute:TooManyIndices', ...
                    'Number of values in order must match the number of legend strings' ...
                    );
            end
            
            if numel(unique(order)) < numel(lh.String)
                error('legtools:permute:NotEnoughUniqueIndices', ...
                    'order must contain enough unique indices to index all legend strings' ...
                    );
            end
            
            % Permute the legend data source(s) and string(s)
            % MATLAB has a listener on the PlotChildren so when their order
            % is modified the string order is changed with it
            lh.PlotChildren = lh.PlotChildren(order);
        end
        
        
        function remove(lh, remidx)
            % REMOVE removes the legend entries of the legend object, lh,
            % at the locations specified by remidx. All elements of remidx
            % must be real, positive, integer values.
            %
            % If remidx specifies all the legend entries, the legend
            % object is deleted
            legtools.verchk()
            lh = legtools.handlecheck('remove', lh);
            
            % Catch length issues, let MATLAB deal with the rest
            if numel(unique(remidx)) > numel(lh.String)
                error('legtools:remove:TooManyIndices', ...
                    'Number of unique values in remidx exceeds number of legend entries' ...
                    );
            end
            
            if numel(unique(remidx)) == numel(lh.String)
                delete(lh);
                warning('legtools:remove:LegendDeleted', ...
                    'All legend entries specified for removal, deleting Legend Object' ...
                    );
            else
                % Check legend entries to be removed for dummy lineseries
                % objects and delete them
                count = 1;
                for ii = remidx
                    % Our dummy lineseries contain a single NaN YData entry
                    if length(lh.PlotChildren(ii).YData) == 1 && isnan(lh.PlotChildren(ii).YData)
                        % Deleting the graphics object here also deletes it
                        % from the legend, which screws up the one-liner
                        % plot children removal. Instead store the objects
                        % to be deleted and delete them after the legend is
                        % properly modified
                        objtodelete(count) = lh.PlotChildren(ii);
                        count = count + 1;
                    end
                end
                lh.PlotChildren(remidx) = [];
                delete(objtodelete);
            end
        end
        
        function adddummy(lh, newStrings, plotParams)
            % ADDDUMMY appends strings, newStrings, to the Legend Object,
            % lh, for graphics objects that are not supported by legend.
            %
            % For a single dummy legend entry, plotParams is defined as a
            % cell array of strings that follow MATLAB's PLOT syntax.
            % Entries can be either a LineSpec or a series of Name/Value
            % pairs. For multiple dummy legend entries, plotParams is
            % defined as a cell array of cells where each top-level cell
            % corresponds to a string in newStrings.
            %
            % ADDDUMMY adds a Chart Line Object to the parent axes of lh
            % consisting of a single NaN value so nothing is rendered in
            % the axes but it provides a valid object for legend to include
            %
            % LEGTOOLS.REMOVE will remove this Chart Line Object if its
            % legend entry is removed.
            
            legtools.verchk()
            lh = legtools.handlecheck('addummy', lh);
            
            % Make sure newStrings exists & isn't empty
            if ~exist('newStrings', 'var') || isempty(newStrings)
                error('legtools:adddummy:EmptyStringInput', ...
                    'No string provided' ...
                    );
            end
            
            newStrings = legtools.strcheck('adddummy', newStrings);
            
            % See if we have a character input for the single addition case
            % and put it into a cell
            if ischar(plotParams)
                plotParams = {{plotParams}};
            end
            
            % TODO: More plotParams error checking
            
            parentaxes = lh.PlotChildren(1).Parent;
            hold(parentaxes, 'on');
            for ii = 1:length(newStrings)
                plot(parentaxes, NaN, plotParams{ii}{:});  % Leave input validation up to plot
            end
            hold(parentaxes, 'off');
            
            legtools.append(lh, newStrings);  % Add legend entries
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
        
        function [lh] = handlecheck(src, lh)
            % Make sure lh exists and is a legend object
            if ~isgraphics(lh,'legend')
                msgID = sprintf('legtools:%s:InvalidLegendHandle', src);
                error(msgID, 'Invalid legend handle provided');
            end
            
            % Pick first legend handle if more than one is passed
            if numel(lh) > 1
                msgID = sprintf('legtools:%s:TooManyLegends', src);
                warning(msgID, ...
                    '%u Legend objects specified, modifying the first one only', ...
                    numel(lh) ...
                    );
                lh = lh(1);
            end
        end
        
        function [newString] = strcheck(src, newString)
            % Validate the input strings
            if ischar(newString)
                % Input string is a character array, assume it's a single
                % string and dump into a cell
                newString = {newString};
            end
            
            % Check to see if we now have a cell array
            if ~iscell(newString)
                msgID = sprintf('legtools:%s:InvalidLegendString', src);
                error(msgID, ...
                    'Invalid Data Type Passed: %s\n\nData must be of type(s): %s, %s', ...
                    class(newString), class({}), class('') ...
                    );
            end
            
            % Check shape of newStrings and make sure it's 1D
            if size(newString, 1) > 1
                newString = reshape(newString', 1, []);
            end
            
            % Check to make sure we're only passing strings
            for ii = 1:length(newString)
                % Check for characters, let MATLAB handle errors for data
                % types not compatible with num2str
                if ~ischar(newString{ii})
                    msgID = sprintf('legtools:%s:ConvertingInvalidLegendString', src);
                    warning(msgID, ...
                        'Input legend ''string'' is of type %s, converting to %s', ...
                        class(newString{ii}), class('') ...
                        );
                    newString{ii} = num2str(newString{ii});
                end
            end
        end
    end
end