function freq = find_LW_freq(uu,fs)
%FIND_LW_FREQ Returns the peak frequency


nsamp = length(uu);
uu=reshape(uu,[1,length(uu)]);
%uu = data.data(1, 1:nsamp, ind) * 1e3;
%[p, f] = pspectrum(uu, fs, 'FrequencyLimits', [0 1e5]);
[p, f] = make_spectrum(uu, single(nsamp), 1./fs);
p = reduce_spectrum_psd_to_psd(f, p, f(1:4:end));
f = f(1:4:end);
f = f(2:end);
df = (f(2)-f(1))/2.;
[pks, locs, w] = findpeaks(10.*log10(p), f, 'MinPeakProminence', 20);
if isempty(pks)
    disp('empty peaks');
    freq = nan;
    return
end
f_ind = find(locs > 1e4 & locs < 8e4);
if isempty(f_ind)
    disp('empty f_ind');
    freq = nan;
    return
end
[~, ii] = max(pks(f_ind), [], 2);
ii = f_ind(ii);
disp('found freq');
freq = locs(ii)/1e3;
%iii = find(f >= (locs(ii) - w(ii)/2.) & f <= (locs(ii) + w(ii)/2.));
%amp = max(uu, [], 2); 
end

