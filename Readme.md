![Minimum Version](https://img.shields.io/badge/Requires-R2014b%20%28v8.4%29-orange.svg)

# legappend
`legappend` appends new entries to a legend

This is an HG2 specific fork of [Chad Greene's `legappend`][1] and requires MATLAB R2014b or newer.

## Syntax
`legappend(newStrings)` appends `newStrings` to the existing legend. `newStrings` can be a 1D character array or a 1D cell array of strings. Character arrays are treated as a single string.

## Examples
#### Single Addition
    % Sample data
    x = 1:10;
    y1 = x;
    y2 = x + 1;

    % Plot a thing!
    figure
    plot(x, 'ro');
    legend('Circle', 'Location', 'NorthWest');

    % Add a thing!
    hold on
    plot(x, y2, 'bs');
    legappend('Square')

#### Multiple Additions
    % Sample data
    x = 1:10;
    y1 = x;
    y2 = x + 1;
    y3 = x + 2;

    % Plot a thing!
    figure
    plot(x, 'ro');
    legend('Circle', 'Location', 'NorthWest');

    % Add two things!
    hold on
    plot(x, y2, 'bs', x, y3, 'g+');
    legappend({'Square', 'Plus'})

## Current Limitations
If there are multiple legend objects in the current figure window (e.g. subplots), `legappend` operates only on the first legend object returned.


[1]: http://www.mathworks.com/matlabcentral/fileexchange/47228-legappend
