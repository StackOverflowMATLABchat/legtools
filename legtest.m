%LEGTEST
clc, clear, close all

%% Bug 1
figure
fplot(@cos)
hold on
fplot(@sin)
legend cos sin
legtools.adddummy(legend,'dummy','ok')
legtools.permute(legend,[3 2 1])
legtools.remove(legend,2)
legtools.append(legend,'sin')
% Bug:
% Append assumes the parent axes' children to be in the same order as the
% legend entries, which may not be case if legtools.permute has been called

%% Feature
% One dummy with all possible plot parameter set formats
legtools.adddummy(legend,'dummy 1')
legtools.adddummy(legend,'dummy 2','o-')
legtools.adddummy(legend,'dummy 3',{'o-'})
legtools.adddummy(legend,'dummy 4','o-','LineWidth',2)
legtools.adddummy(legend,'dummy 5',{'o-','LineWidth',2})

%% Feature
% Two or more dummies with all possible plot parameter set formats

% no plot parameters
legtools.adddummy(legend, {'dummy 6','dummy 7'})

% one set of plot parameters: one parameter
legtools.adddummy(legend, {'dummy 8','dummy 9'}, 'o')

% one set of plot parameters: two or more parameters
legtools.adddummy(legend, {'dummy 10','dummy 11'}, ...
    'o', 'LineWidth',2)

% one set of plot parameters: cell format
legtools.adddummy(legend, {'dummy 12','dummy 13'}, ...
    {'o','LineWidth',2})

% multiple sets of plot parameters, each in a cell
legtools.adddummy(legend, {'dummy 14','dummy 15'}, ...
    {'o','LineWidth',2}, {'s:'})

% multiple sets of plot parameters, cell of cells format
legtools.adddummy(legend, {'dummy 16','dummy 17'}, ...
    {{'o','LineWidth',2}, {'s:'}})