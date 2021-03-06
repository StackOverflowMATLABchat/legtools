[![MATLAB FEX](https://img.shields.io/badge/MATLAB%20FEX-legtools-brightgreen.svg)](http://www.mathworks.com/matlabcentral/fileexchange/57241-hg2-legend-tools) ![Minimum Version](https://img.shields.io/badge/Requires-R2014b%20%28v8.4%29-orange.svg)

# LEGTOOLS
`legtools` is a MATLAB class definition providing the user with a set of methods to modify existing Legend objects.

This is an HG2 specific implementation and requires MATLAB R2014b or newer.

## Methods
* [`append`](#append)  - Add one or more entries to the end of the legend  
* [`permute`](#permute) - Rearrange the legend entries  
* [`remove`](#remove)  - Remove one or more legend entries
* [`adddummy`](#adddummy) - Add legend entries for one or more unsupported graphics objects

<a name="append"></a>
### *legtools*.**append**(*legendhandle*, *newStrings*)
#### Description
Append string(s), `newStrings`, to the specified `Legend` object, `legendhandle`. `newStrings` can be a 1D character array or a 1D cell array of strings. Character arrays are treated as a single string. If multiple `Legend` objects are specified, only the first will be modified.

The legend will only be updated with the new strings if the number of strings in the existing legend plus the number of strings in `newStrings` is the same as the number of plots on the associated `Axes` object (e.g. if you have 2 lineseries and 2 legend entries already no changes will be made).

**NOTE**: For MATLAB R2017a or newer, the `legend` object's [`'AutoUpdate'`](https://www.mathworks.com/help/matlab/ref/matlab.graphics.illustration.legend-properties.html#bt7bgi4-1-AutoUpdate) property *must* be set to `'off'` before adding additional lineseries to the plot.

#### Examples
##### Adding one legend entry
    % Sample data
    x = 1:10;
    y1 = x;
    y2 = x + 1;

    % Plot a thing!
    figure
    plot(x, y1, 'ro');
    lh = legend('Circle', 'Location', 'NorthWest');

    % Add a thing!
    hold on
    plot(x, y2, 'bs');
    legtools.append(lh, 'Square')

![append1](https://github.com/sco1/sco1.github.io/blob/master/legtools/append1.png)

#### Adding two legend entries

    % Sample data
    x = 1:10;
    y1 = x;
    y2 = x + 1;
    y3 = x + 2;

    % Plot a thing!
    figure
    plot(x, y1, 'ro');
    lh = legend('Circle', 'Location', 'NorthWest');

    % Add two things!
    hold on
    plot(x, y2, 'bs', x, y3, 'g+');
    legtools.append(lh, {'Square', 'Plus'})

![append2](https://github.com/sco1/sco1.github.io/blob/master/legtools/append2.png)

<a name="permute"></a>
### *legtools*.**permute**(*legendhandle*, *newOrder*)
#### Description
Rearrange the entries of the specified `Legend` object, `legendhandle`, so they are in the order specified by the vector `newOrder`. `newOrder` must be the same length as the number of legend entries in `legendhandle`. All elements of order must be unique, real, positive, integer values.

**NOTE**: `legtools.append` is currently unsupported for MATLAB >= R2017a

#### Example
    % Sample data
    x = 1:10;
    y1 = x;
    y2 = x + 1;
    y3 = x + 2;

    % Plot a thing!
    figure
    plot(x, y1, 'ro', x, y2, 'bs', x, y3, 'g+');
    lh = legend({'One', 'Two', 'Three'}, 'Location', 'NorthWest');

    legtools.permute(lh, [3, 1, 2]);

![permute](https://github.com/sco1/sco1.github.io/blob/master/legtools/permute.png)

<a name="remove"></a>
### *legtools*.**remove**(*legendhandle*, *removeidx*)
#### Description            
Remove the legend entries of the `Legend` object, `legendhandle`, at the locations specified by `removeidx`. All elements of `removeidx` must be real, positive, integer values.

If `removeidx` specifies all the legend entries the `Legend` object, `legendhandle`, is deleted.

If a legend entry to be removed is one generated by `legtools.adddummy`, its corresponding Chart Line Object will also be deleted.

**NOTE**: `legtools.remove` is currently unsupported for MATLAB >= R2017a

#### Example
    % Sample data
    x = 1:10;
    y1 = x;
    y2 = x + 1;
    y3 = x + 2;

    % Plot a thing!
    figure
    plot(x, y1, 'ro', x, y2, 'bs', x, y3, 'g+');
    lh = legend({'One', 'Two', 'Three'}, 'Location', 'NorthWest');

    legtools.remove(lh, [3, 1]);

![remove](https://github.com/sco1/sco1.github.io/blob/master/legtools/remove.png)

<a name="adddummy"></a>
### *legtools*.**addummy**(*legendhandle*, *newStrings*, *plotParams*)
#### Description
`adddummy` appends strings, `newStrings`, to the Legend Object, `lh`, for graphics objects that are not supported by `legend`.

For a single dummy legend entry, `plotParams` is defined as a cell array of strings that follow MATLAB's `plot` syntax. Entries can be either a `LineSpec` or a series of Name/Value pairs. For multiple dummy legend entries, `plotParams` is  defined as a cell array of cells where each top-level cell corresponds to a string in `newStrings`.

`adddummy` adds a Chart Line Object to the parent axes of `lh` consisting of a single `NaN` value. Nothing is rendered in the axes but it provides a valid object for `legend` to include. `legtools.remove` will remove this Chart Line Object if its legend entry is removed.


#### Examples
##### Add legend entry for single annotation
    % Sample data
    x = 1:10;
    y1 = x;

    % Plot a thing!
    figure
    plot(x, y1);
    lh = legend('My Data', 'Location', 'NorthWest');

    % Add a box!
    dim = [0.4 0.4 0.2 0.2];
    annotation('rectangle', dim, 'Color', 'red')

    % Add a legend entry for the box!
    legtools.adddummy(lh, 'A Red Rectangle', {'Color', 'red'})

![addummy](https://github.com/sco1/sco1.github.io/blob/master/legtools/adddummy.png)

##### Add legend entries for multiple annotations

    % Sample data
    x = 1:10;
    y = x;

    % Plot a thing!
    plot(x, y);
    lh = legend('My Data', 'Location', 'NorthWest');

    % Add a box and a circle!
    dim1 = [0.5 0.6 0.2 0.2];
    annotation('rectangle', dim1, 'Color', 'red')
    dim2 = [0.3 0.4 0.2 0.2];
    annotation('ellipse', dim2, 'Color', 'green')

    % Add legend entries!
    newStrings = {'A Red Rectangle', 'A Green Ellipse'};
    plotParams = {{'Color', 'Red'}, {'Color', 'green'}};
    legtools.adddummy(lh, newStrings, plotParams)

![addummy2](https://github.com/sco1/sco1.github.io/blob/master/legtools/adddummy2.png)