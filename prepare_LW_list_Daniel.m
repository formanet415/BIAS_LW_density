file = 'solo-tds-tswf-LW-list_V2.txt';
ofile = 'solo-tds-tswf-LW-list-irfu.txt';
fileid = fopen(file, 'r');
ofileid = fopen(ofile, 'w');

tab = readtable(file);
fprintf(ofileid, 'Timestamp                Peak field [mV/m]  Freq [kHz]\n');
fprintf(ofileid, '----------------------------------------------\n');
for r=1:length(tab.Var1)
    date = datenum(tab.Var1(r));
    data = tdscdf_load_l2_surv_tswf(date, 1);
    if isempty(data)
        continue;
    end
    idx = strsplit(convertCharsToStrings(tab.Var2{r}), ',');
    for i=1:length(idx)
        ind = str2num(idx(i));
        ep = data.epoch(ind);
        nsamp = data.samples_per_ch(ind);
        uu = data.data(1, 1:nsamp, ind) * 1e3;
        fs = data.samp_rate(ind);
        %[p, f] = pspectrum(uu, fs, 'FrequencyLimits', [0 1e5]);
        [p, f] = make_spectrum(uu, single(nsamp), 1./fs);
        p = reduce_spectrum_psd_to_psd(f, p, f(1:4:end));
        f = f(1:4:end);
        f = f(2:end);
        df = (f(2)-f(1))/2.;
        [pks, locs, w] = findpeaks(10.*log10(p), f, 'MinPeakProminence', 20);
        if isempty(pks)
            continue;
        end
        f_ind = find(locs > 1e4 & locs < 8e4);
        if isempty(f_ind)
            continue
        end
        [~, ii] = max(pks(f_ind), [], 2);
        ii = f_ind(ii);
        iii = find(f >= (locs(ii) - w(ii)/2.) & f <= (locs(ii) + w(ii)/2.));
        amp = max(uu, [], 2); 
        fprintf(ofileid, '%s %16.3f %10.2f\n', datestr(ep, 'yyyy-mm-dd HH:MM:SS.FFF'), amp, locs(ii)/1e3);
    end
end
    