%LEGTEST
clc, clear, close all

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