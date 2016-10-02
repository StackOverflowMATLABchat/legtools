[![MATLAB FEX](https://img.shields.io/badge/MATLAB%20FEX-legtools-brightgreen.svg)](http://www.mathworks.com/matlabcentral/fileexchange/57241-hg2-legend-tools) ![R2016b support](https://img.shields.io/badge/supports-R2016b%20(v9.1)-brightgreen.svg) ![Minimum Version](https://img.shields.io/badge/requires-R2014b%20(v8.4)-orange.svg)

# `legtools`
`legtools` is a MATLAB class of methods to modify existing Legend objects.

`legtools` requires MATLAB R2014b or newer.

## Methods
Name | Description
----------|--------------
[`append`](#append) | Append entries to legend
[`permute`](#permute) | Rearrange legend entries  
[`remove`](#remove) | Remove entries from legend
[`adddummy`](#adddummy) | Add dummy entries to legend

<a name="append"></a>
### `legtools.`*`append`*`(lh, newStrings)`
#### Syntax
`legtools.append(lh, newStrings)` appends strings specified
by `newStrings` to the Legend object specified by `lh`.
`newStrings` can be a 1D character array or a 1D cell array
of strings. Character arrays are treated as a single
string. From MATLAB R2016b onwards the string data type is
also supported. If multiple `Legend` objects are specified
in `lh`, only the first will be modified.

The total number of entries, i.e. the number of current
entries in the legend plus the number of entries in
`newStrings`, can exceed the number of graphics objects in
the axes. However, any extra entries to append will not be
added to the legend. For example, if you have plotted two
lines and the current legend contains one entry, appending
three new entries will only append the first of them.

#### Examples
##### Append one legend entry
```matlab
% Plot a sine!
figure
fplot(@sin)
lh = legend('sine');

% Append to axes and legend!
hold on
fplot(@cos)
legtools.append(lh, 'cosine')
```
![append1](../readme/img/append1.png)

#### Adding two legend entries
```matlab
% Plot a sine!
figure
fplot(@sin)
lh = legend('sine');

% Add two things!
hold on
fplot(@cos)
fplot(@tan)
legtools.append(lh, {'cosine', 'tangent'})
```
![append2](../readme/img/append2.png)

<a name="permute"></a>
### `legtools.`*`permute`*`(legendhandle, newOrder)`
#### Syntax
`legtools.permute(lh, order)` rarranges the entries of the
Legend object specified by `lh` in the order specified by
`order`. `order` must be a vector with the same number of
elements as the number of entries in the specified legend.
All elements in order must be unique, real and positive
integers.

#### Example
```matlab
% Plot a thing!
figure
fplot(@sin)
hold on
fplot(@cos)
fplot(@tan)
legend sine cosine tangent
lh = legend;

% Rearrange legend entries!
legtools.permute(lh, [3, 1, 2])
```
![permute](../readme/img/permute.png)

<a name="remove"></a>
### `legtools.`*`remove`*`(legendhandle, removeidx)`
#### Syntax            
`legtools.remove(lhm, remidx)` removes the legend entries from
the legend specified in `lh` at the locations specified by
`remidx`. All elements of `remidx` must be real and positive
integers.

If `remidx` specifies all the legend entries, the legend
object is deleted.

#### Example
```matlab
% Plot a thing!
figure
fplot(@sin)
hold on
fplot(@cos)
fplot(@tan)
legend sine cosine tangent
lh = legend;

% Remove entries one and three!
legtools.remove(lh, [3, 1])
```
![remove](../readme/img/remove.png)

<a name="adddummy"></a>
### `legtools.`*`adddummy`*`(legendhandle, newStrings, plotParams)`
#### Syntax
`legtools.adddummy(lh, newStrings)` appends strings, specified
by `newStrings`, to the Legend object, specified by `lh`, for
graphics objects that are not supported by legend. The
default line specification for a plot is used for the dummy
entries in the legend, i.e. a line.

`legtools.adddummy(lh, newStrings, plotParams)` additionally
uses plot parameters specified in `plotParams` for the
creation of the dummy legend entries.

The `plotParams` input argument can have multiple formats.
All formats are based on the LineSpec and Name-Value pair
arguments syntax of the built-in [`plot`](https://mathworks.com/help/matlab/ref/plot.html) function. `plotParams`
can be in the following formats (with example parameters):
- absent (like in the first syntax)
- empty, e.g. `''`, `[]` or `{}`
- one set of plot parameters for all dummy entries, e.g.:
 - `legtools.adddummy(lh, newStrings, ':', 'Color' ,'red')`. This is the regular `plot` syntax.
 - `legtools.adddummy(lh, newStrings, {'Color','red'})`. This is one set of plot parameters in a cell.
- two or more sets of plot parameters, e.g.:
 - `legtools.adddummy(lh, newStrings, {'k'}, {'--b'})`. These are two sets of plot parameters, each in a cell.
 - `legtools.adddummy(lh, newStrings, {{'r'}, {':m'}})`. These are two sets of plot parameters, each in a cell in a cell.

For more than two dummies, the previous syntaxes can be
extended with additional sets of plot parameters.

`legtools.adddummy` adds an invisible point to the parent
axes of the legend. More specifically, it adds a `Line`
object to the parent axes of `lh` consisting of a single `NaN`
value so nothing is visibly changed in the axes while
providing a valid object to include in the legend.

`legtools.remove` deletes dummy `Line` objects when their
corresponding legend entries are removed.

#### Examples
##### Add dummy legend entry for single annotation
```matlab
% Plot a thing!
figure
fplot(@sin)
lh = legend('sin');

% Add a box!
dim = [0.4 0.4 0.2 0.2];
annotation('rectangle', dim, 'Color', 'red')

% Add a legend entry for the box!
legtools.adddummy(lh, 'rectangle', 'Color', 'red')
```
![addummy](../readme/img/adddummy1.png)

##### Add dummy legend entries for multiple annotations
```matlab
% Plot a thing!
fplot(@sin)
lh = legend('sine');

% Add a box and a circle!
dim1 = [0.5 0.6 0.2 0.2];
annotation('rectangle', dim1, 'Color', 'red')
dim2 = [0.3 0.4 0.2 0.2];
annotation('ellipse', dim2, 'Color', 'green')

% Add legend entries!
newStrings = {'rectangle', 'ellipse'};
plotParams = {{'Color', 'red'}, {'g'}};
legtools.adddummy(lh, newStrings, plotParams)
```
![addummy2](../readme/img/adddummy2.png)
