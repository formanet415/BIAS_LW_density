 load('LW_2020_density_V2.mat')
 
 for i = 1:length(tds_epoch)
    dtime = zeros(1,density_recs(i)+1);
    dtime(1) = tds_epoch(i);
    dtime(end) = addtodate(tds_epoch(i),1e3*tds_nsamp(i)/tds_samp_rate(i),'millisecond');
    temp = movmean(density_epoch(i,1:density_recs(i)),2);
    dtime(2:end-1) = temp(2:end);
    %disp(datestr(dtime, 'dd-mm-yyyy HH:MM:SS.FFF'))
    
    t0 = dtime(1);
    rtime = dtime-t0;
    srtime = rtime*86400;
    fs = tds_samp_rate(1);
    samps = fix(srtime*fs);
    samps(end) = tds_nsamp(i);
    freqs = zeros(2,density_recs(i));
    for j = 1:density_recs(i)
        for k = 1:2
            uu = tds_SRF(i,k,1+samps(j):samps(j+1));
            freqs(k,j) = find_LW_freq(uu,fs);
        end
    end
    ttime = density_epoch(i,1:density_recs(i))*86400 - t0*86400;
    
    
    plot(ttime*1e3,mean(freqs))
    title('Langmuir wave frequency within the snapshot')
    xlabel(sprintf('time since %s (ms)', datestr(t0)))
    ylabel('frequency (kHz)')
    legend(['LW frequency'])
    if ~isnan(mean(freqs))
        saveas(gcf,fullfile(pwd, 'plots', sprintf('LW_freq_%s.jpg', datestr(t0, 'yyyy_mm_dd_HHMMSS'))))
    end
 end