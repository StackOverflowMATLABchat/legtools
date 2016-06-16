classdef legtools
    % LEGTOOLS is a MATLAB class definition providing the user with a set
    % of methods to modify existing Legend objects.
    %
    % This is an HG2 specific implementation and requires MATLAB R2014b or
    % newer.
    %
    % LEGTOOLS methods:
    %      append  - Add one or more entries to the end of the legend
    %      permute - Rearrange the legend entries
    %      remove  - Remove one or more legend entries
    %
    % See also LEGEND
    
    methods
        function obj = legtools
            % Dummy constructor so we don't return an empty class instance
            clear obj
        end % of legtools
    end % of methods
    
    methods (Static)
        function append(varargin)
            % APPEND appends strings, newStrings, to the specified Legend
            % object, lh. newStrings can be a 1D character array or a 1D
            % cell array of strings. Character arrays are treated as a
            % single string. If multiple or no Legend objects are
            % specified, only the Legend belonging to the current axes in
            % the current figure will be modified.
            %
            % The legend will only be updated with the new strings if the
            % number of strings in the existing legend plus the number of
            % strings in newStrings is the same as the number of plots on
            % the associated axes object (e.g. if you have 2 lineseries and
            % 2 legend entries already no changes will be made).
            legtools.verchk
            
            % Parse inputs
            switch nargin
                case 0
                    error('legtools:append:TooFewInputs', ...
                        'Too few input arguments' ...
                        )
                case 1
                    if isa(varargin{:}, 'matlab.graphics.illustration.Legend')
                        lh = varargin{:};
                        newStrings = {}; % This yields an error further down
                    elseif ischar(varargin{:}) || iscellstr(varargin{:})
                        lh = findobj(gcf,'Type','legend');
                        newStrings = varargin{:};
                    else
                        error('legtools:append:InvalidInput', ...
                            'Invalid input' ...
                            )
                    end
                case 2
                    lh = varargin{1};
                    newStrings = varargin{2};
                otherwise
                    error('legtools:append:TooManyInputs', ...
                        'Too many input arguments' ...
                        )
            end
            
            % Make sure lh is a legend object
            if ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:append:InvalidLegendHandle', ...
                    'Invalid legend handle provided' ...
                    )
            end
            
            % If multiple or no Legend objects are specified, only the
            % Legend belonging to the current axes in the current figure
            % will be modified.
            if ~isscalar(lh)
                lh = legtools.select(lh);
            end
            
            % Make sure newString exists & isn't empty
            if isempty(newStrings)
                error('legtools:append:EmptyStringInput', ...
                    'No new string(s) provided' ...
                    )
            end
            
            % Validate the input strings
            if ischar(newStrings)
                % Input string is a character array, assume it's a single
                % string and dump into a cell
                newStrings = {newStrings};
            end
            
            % Check shape of newStrings and make sure it's 1D
            if size(newStrings, 1) > 1
                newStrings = reshape(newStrings', 1, []);
            end
            
            % To make sure we target the right axes, pull the legend's
            % PlotChildren and get their parent axes object
            parentaxes = lh.PlotChildren(1).Parent;
            
            % Get line object handles
            plothandles = flipud(parentaxes.Children);  % Flip so order matches
            
            % Update legend with line object handles & new string array
            newlegendstr = [lh.String newStrings];  % Need to generate this before adding new plot objects
            lh.PlotChildren = plothandles;
            lh.String = newlegendstr;
        end % of append
        
        function permute(varargin)
            % PERMUTE rearranges the entries of the specified Legend
            % object, lh, so they are then the order specified by the
            % vector order. If multiple or no Legend objects are specified,
            % only the Legend belonging to the current axes in the current
            % figure will be modified. The length of order must be the same
            % as the number of legend entries. All elements of order must
            % be unique, real, positive, integer values.
            legtools.verchk
            
            % Parse inputs
            switch nargin
                case 0
                    order = [];
                    lh = [];
                case 1
                    if isa(varargin{:}, 'matlab.graphics.illustration.Legend')
                        lh = varargin{:};
                        order = [];
                    elseif isnumeric(varargin{:})
                        lh = [];
                        order = varargin{:};
                    else
                        error('legtools:append:InvalidInput', ...
                            'Invalid input' ...
                            )
                    end
                case 2
                    lh = varargin{1};
                    order = varargin{2};
                otherwise
                    error('legtools:append:TooManyInputs', ...
                        'Too many input arguments' ...
                        )
            end
            if isempty(lh), lh = findobj(gcf,'Type','legend'); end
            
            % Make sure lh is a legend object
            if ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:permute:InvalidLegendHandle', ...
                    'Invalid legend handle provided' ...
                    )
            end
            
            % If multiple or no Legend objects are specified, only the
            % Legend belonging to the current axes in the current figure
            % will be modified.
            if ~isscalar(lh)
                lh = legtools.select(lh);
            end
            
            if isempty(order)
                n = numel(lh.String);
                order = [n 1:n-1]; % Shift all elements one place and wrap around the last
            end
            
            % Catch length & uniqueness issues with order, let MATLAB deal
            % with the rest.
            if numel(order) ~= numel(lh.String)
                error('legtools:permute:TooManyIndices', ...
                    'Number of values in order must match the number of legend strings' ...
                    )
            end
            
            if numel(unique(order)) < numel(lh.String)
                error('legtools:permute:NotEnoughUniqueIndices', ...
                    'order must contain enough unique indices to index all legend strings' ...
                    )
            end
            
            % Permute the legend data source(s) and string(s)
            % MATLAB has a listener on the PlotChildren so when their order
            % is modified the string order is changed with it
            lh.PlotChildren = lh.PlotChildren(order);
        end % of permute
        
        function remove(varargin)
            % REMOVE removes the legend entries of the Legend object, lh,
            % at the locations specified by remidx. If multiple or no
            % Legend objects are specified, only the Legend belonging to
            % the current axes in the current figure will be modified. If
            % remidx is not provided the last legend entry is removed.
            % 
            % All elements of remidx must be real, positive, integer
            % values. If remidx specifies all the legend entries the Legend
            % object is deleted.
            legtools.verchk
            
            % Parse inputs
            switch nargin
                case 0
                    lh = [];
                    remidx = [];
                case 1
                    if isa(varargin{:}, 'matlab.graphics.illustration.Legend')
                        % remidx not provided
                        remidx = [];
                    elseif isnumeric(varargin{:})
                        lh = [];
                        remidx = varargin{:};
                    else
                        error('legtools:append:InvalidInput', ...
                            'Invalid input' ...
                            )
                    end
                case 2
                    lh = varargin{1};
                    remidx = varargin{2};
                otherwise
                    error('legtools:append:TooManyInputs', ...
                        'Too many input arguments' ...
                        )
            end
            if isempty(lh), lh = findobj(gcf,'Type','legend'); end
            
            % Make sure lh is a legend object
            if ~isa(lh, 'matlab.graphics.illustration.Legend')
                error('legtools:remove:InvalidLegendHandle', ...
                    'Invalid legend handle provided' ...
                    )
            end
            
            % If multiple or no Legend objects are specified, only the
            % Legend belonging to the current axes in the current figure
            % will be modified.
            if ~isscalar(lh)
                lh = legtools.select(lh);
            end
            
            % If remidx is empty, remove last legend entry
            if isempty(remidx)
                remidx = numel(lh.PlotChildren);
            end
            
            % Catch length issues, let MATLAB deal with the rest
            if numel(unique(remidx)) > numel(lh.String)
                error('legtools:remove:TooManyIndices', ...
                    ['Number of unique values in remidx must not be ' ...
                    'greater than the number of legend entries'] ...
                    )
            end
            
            if numel(unique(remidx)) == numel(lh.String)
                delete(lh);
                warning('legtools:remove:LegendDeleted', ...
                    'All legend entries specified for removal, deleting Legend Object' ...
                    )
            else
                lh.PlotChildren(remidx) = [];
            end
        end % of remove
    end % of Static methods
    
    methods (Static, Access = private)
        function verchk
            % Throw error if we're not using R2014b or newer
            if verLessThan('matlab','8.4')
                error('legtools:UnsupportedMATLABver', ...
                    'MATLAB releases prior to R2014b are not supported' ...
                    )
            end
        end % of verchk
        
        function lh = select(lh)
            % Select legend based on its PlotChildren being Children of the
            % current axes too.
            ax = gca;
            ac = ax.Children;
            lc = {lh.PlotChildren};
            fBest = 0;
            iLegend = [];
            for i = numel(lc):-1:1
                [~,j] = intersect(ac,lc{i});
                if any(j)
                    f = numel(j)/numel(ac); % Fraction of possible matches
                    if f>fBest
                        fBest = f;
                        iLegend = i;
                    end
                end
            end
            if ~isempty(iLegend)
                lh = lh(iLegend);
            else
                error('legtools:select:NoLegendFound', ...
                    'No legend found in current axes.' ...
                    )
            end
        end % of select
    end % of Static, Access = private methods
end % of classdef
