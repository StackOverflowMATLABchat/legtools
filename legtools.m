classdef legtools
    %LEGTOOLS A class of methods to modify existing Legend objects.
    %
    %   LEGTOOLS requires MATLAB R2014b or newer.
    %
    %   LEGTOOLS methods:
    %    append   - Append entries to legend
    %    permute  - Rearrange legend entries
    %    remove   - Remove one or more legend entries
    %    adddummy - Add one or more entries to the legend for unsupported
    %               graphics objects
    %
    %    See also legend
    
    methods
        function obj = legtools
            % Dummy constructor so we don't return an empty class instance
            clear obj
        end % of constructor
    end % of methods
    
    methods (Static)
        function append(lh, newStrings)
            %LEGTOOLS.APPEND Append entries to legend
            %
            %    LEGTOOLS.APPEND(lh,newStrings) appends strings specified
            %    by newStrings to the Legend object specified by lh.
            %    newStrings can be a 1D character array or a 1D cell array
            %    of strings. Character arrays are treated as a single
            %    string. From MATLAB R2016b onwards the string data type is
            %    also supported. If multiple Legend objects are specified
            %    in lh, only the first will be modified.
            %
            %    The total number of entries, i.e. the number of current
            %    entries in the legend plus the number of entries in
            %    newStrings, can exceed the number of graphics objects in
            %    the axes. However, any extra entries to append will not be
            %    added to the legend. For example, if you have plotted two
            %    lines and the current legend contains one entry, appending
            %    three new entries will only append the first of them.
            
            % Check number of input arguments
            narginchk(2,2)
            
            % Check MATLAB version
            legtools.verchk
            
            % Check legend handle
            lh = legtools.handlecheck('append', lh);
            
            % Check new strings
            newStrings = legtools.strcheck('append', newStrings);
            
            % To make sure we target the right axes, pull the legend's
            % PlotChildren and get their parent axes object
            ax = lh.PlotChildren(1).Parent;
            
            % Get graphics object handles
            axchildren = flip(ax.Children); % Flip so order matches
            legchildren = lh.PlotChildren;
            
            % Sort the children of the future legend object in an order
            % depending on current legend PlotChildren property, because
            % this may not be in the same order as axchildren, e.g. after
            % permuting the legend entries
            [~,~,icurrent] = intersect(legchildren,axchildren,'stable');
            [~,idiff] = setdiff(axchildren,legchildren,'stable');
            ifuture = [icurrent;idiff];
            axchildren = axchildren(ifuture);
            
            % Strings desired order for future legend
            newstr = [lh.String, newStrings];
            
            % Update legend with graphics object handles & new string array
            lh.PlotChildren = axchildren;
            lh.String = newstr;
        end % of append method
        
        function permute(lh, order)
            %LEGTOOLS.PERMUTE Rearrange legend entries
            %
            %   LEGTOOLS.PERMUTE(lh,order) rarranges the entries of the
            %   Legend object specified by lh in the order specified by
            %   order. order must be a vector with the same number of
            %   elements as the number of entries in the specified legend.
            %   All elements in order must be unique, real and positive
            %   integers.
            
            % Check number of input arguments
            narginchk(2,2)
            
            % Check MATLAB version
            legtools.verchk
            
            % Check legend handle
            lh = legtools.handlecheck('permute', lh);
            
            % Catch length & uniqueness issues with order, let MATLAB deal
            % with the rest
            assert( ...
                numel(order) == numel(lh.String), ...
                'legtools:permute:TooManyIndices', ...
                ['Number of values in order must match number ' ...
                'of legend strings.'] ...
                )
            
            assert( ...
                numel(unique(order)) == numel(lh.String), ...
                'legtools:permute:NotEnoughUniqueIndices', ...
                ['Input argument order must contain enough unique ' ...
                'indices to index all legend strings.'] ...
                )
            
            % Permute the legend data source(s) and string(s)
            % MATLAB has a listener on the PlotChildren so when their order
            % is modified the string order is changed with it
            lh.PlotChildren = lh.PlotChildren(order);
        end % of permute method
        
        function remove(lh, remidx)
            %LEGTOOLS.REMOVE Remove entries from legend
            %
            %   LEGTOOLS.REMOVE(lhm,remidx) removes the legend entries from
            %   the legend specified in lh at the locations specified by
            %   remidx. All elements of remidx must be real and positive
            %   integers.
            %
            %   If remidx specifies all the legend entries, the legend
            %   object is deleted.
            
            % Check number of input arguments
            narginchk(2,2)
            
            % Check MATLAB version
            legtools.verchk
            
            % Check legend handle
            lh = legtools.handlecheck('remove', lh);
            
            % Catch length issues, let MATLAB deal with the rest
            assert( ...
                numel(unique(remidx)) <= numel(lh.String), ...
                'legtools:remove:TooManyIndices', ...
                ['Number of unique values in remidx exceeds ' ...
                'number of legend entries.'] ...
                )
            
            assert( ...
                max(remidx) <= numel(lh.String), ...
                'legtools:remove:BadSubscript', ...
                'Index in remidx exceeds number of legend entries.' ...
                )
            
            % Remove specified legend entries
            if numel(unique(remidx)) == numel(lh.String)
                delete(lh)
            else
                % Check legend entries to be removed for dummy graphics
                % objects and delete them
                lc = lh.PlotChildren;
                obj2delete = gobjects(numel(remidx));
                for ii = numel(remidx):-1:1
                    ir = remidx(ii);
                    % Our dummy lineseries have the UserData property set
                    % to 'legtools.dummy'
                    if strcmp(lc(ir).UserData,'legtools.dummy')
                        % Deleting the graphics object here also deletes it
                        % from the legend, which screws up the one-liner
                        % plot children removal. Instead store the objects
                        % to be deleted and delete them after the legend is
                        % properly modified
                        obj2delete(ii) = lc(ir);
                    end
                end
                lh.PlotChildren(remidx) = [];
                delete(obj2delete);
            end
        end % of remove method
        
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
            
            % Check number of input arguments
            narginchk(2,3)
            
            % Check MATLAB version
            legtools.verchk
            
            % Check legend handle
            lh = legtools.handlecheck('adddummy', lh);
            
            % Check new strings
            newStrings = legtools.strcheck('adddummy', newStrings);
            
            % Check plot parameters
            if nargin<3
                plotParams = {{}};
            end
            
            % See if we have a character input for the single addition case
            % and put it into a cell
            if ischar(plotParams)
                plotParams = {{plotParams}};
            end
            
            % TODO: More plotParams error checking
            
            parentaxes = lh.PlotChildren(1).Parent;
            
            % Hold parent axes
            if ishold(parentaxes)
                washold = true;
            else
                washold = false;
                hold(parentaxes, 'on');
            end
            
            for ii = 1:length(newStrings)
                plot(parentaxes, NaN, ...
                    plotParams{ii}{:}, ... % Leave validation up to plot
                    'UserData', 'legtools.dummy')
            end
            if ~washold, hold(parentaxes, 'off'); end
            
            % Append dummy entries to legend
            legtools.append(lh, newStrings);
        end % of adddummy method
    end % of Static methods
    
    methods (Static, Access = private)
        function verchk
            % Throw error if we're not using R2014b or newer
            if verLessThan('matlab','8.4')
                error('legtools:UnsupportedMATLABver', ...
                    'MATLAB releases prior to R2014b are not supported.')
            end
        end % of verchk method
        
        function lh = handlecheck(src, lh)
            % Make sure lh exists and is a legend object
            assert( ...
                ~isempty(lh) && isgraphics(lh,'legend') && isvalid(lh), ...
                sprintf('legtools:%s:InvalidLegendHandle', src), ...
                'Invalid legend handle provided.' ...
                )
            
            % Keep first legend handle if more than one is passed
            if numel(lh) > 1
                warning( ...
                    sprintf('legtools:%s:TooManyLegends', src), ...
                    ['%u Legend objects specified, ' ...
                    'modifying the first one only.'], ...
                    numel(lh) ...
                    )
                lh = lh(1);
            end
        end % of handlecheck method
        
        function newString = strcheck(src, newString)
            % Make sure newString exists & isn't empty
            assert( ...
                ~isempty(newString), ...
                'legtools:append:EmptyStringInput', ...
                'No strings provided.' ...
                )
            
            % Validate the input strings
            if ischar(newString)
                % Input string is a character array, assume it's a single
                % string and dump into a cell
                newString = cellstr(newString);
            end
            
            % Message identifier for cellstr assertion below
            msgID = sprintf('legtools:%s:InvalidLegendString', src);
            
            % Check MATLAB version for support for string class
            if verLessThan('matlab','9.1')
                msgArgs = { ...
                    ['Invalid data type passed: '...
                    '%s\nData must be any of the following types: ' ...
                    '%s, %s'], ...
                    class(newString), class(cell.empty), class(char) ...
                    };
            else
                % MATLAB R2016b and newer support the string data type
                % Force conversion to cell array of strings
                newString = cellstr(newString);
                msgArgs = { ...
                    ['Invalid data type passed: %s\n'...
                    'Data must be any of the following types: ' ...
                    '%s, %s, %s'], ...
                    class(newString), ...
                    class(string), class(cell.empty), class(char) ...
                    };
            end
            
            % Check if we now have a cell array of strings
            assert(iscellstr(newString), msgID, msgArgs{:})
            
            % Check shape of newStrings and make sure it's 1D
            newString = newString(:)';
        end % of strcheck method
    end % of Static, Access = private methods
end