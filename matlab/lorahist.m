function lorahist(indata, hmin, hmax, xlbl, cnt)
    xx=linspace(hmin, hmax, cnt);
    histogram(indata, 'BinEdges', xx); grid on;
    xlim([hmin, hmax]);
    xlabel(xlbl);
    ylabel('Packet count');
end
