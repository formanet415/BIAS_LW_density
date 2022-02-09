file = 'solo-tds-tswf-LW-list_V2.txt';
fileid = fopen(file, 'r');

tab = readtable(file);

tds_epoch = [];
tds_channel_ref = zeros(1000, 3);
tds_samp_rate = [];
tds_data = zeros(1000, 3, 32768);
tds_nsamp = [];
tds_SRF = zeros(1000, 2, 32768);
%tds_LW_peak = [];

density_epoch = zeros(1000, 200);
density_data = zeros(1000, 200);
density_recs = [];



for r=1:length(tab.Var1)
    date = datenum(tab.Var1(r));
    data = tdscdf_load_l2_surv_tswf(date, 1);
    if isempty(data)
        continue;
    end
    idx = strsplit(convertCharsToStrings(tab.Var2{r}), ',');
    for i=1:length(idx)
        inds = str2num(strrep(idx(i),'-',':'));
        for ind = inds
            ep = data.epoch(ind);
            nsamp = data.samples_per_ch(ind);
            uu = data.data(1, 1:nsamp, ind) * 1e3;
            fs = data.samp_rate(ind);
        
            [d_ep, d_dens, d_extras] = caadb_get_solo_rpw_bia_density(ep, nsamp/fs);
            if all(isnan(d_dens(:))) || length(d_dens) == 1
                disp('failed to gather data')
                continue
            end
            disp('found something')
        
            tds_epoch(end+1) = ep;
            tds_channel_ref(length(tds_epoch), :) = data.channel_ref(:,ind);
            tds_samp_rate(end+1) = fs;
            tds_data(length(tds_epoch), :, 1:nsamp) = data.data(:,1:nsamp,ind);
            tds_nsamp(end+1) = nsamp;
            tds_SRF(length(tds_epoch), :, 1:nsamp) = convert_to_SRF(data, ind);
            %tds_LW_peak(end+1) = locs(ii)/1e3;

            density_epoch(length(tds_epoch), 1:length(d_ep)) = d_ep;
            density_data(length(tds_epoch), 1:length(d_ep)) = d_dens;
            density_recs(end+1) = length(d_dens);
        end
    end
end
    