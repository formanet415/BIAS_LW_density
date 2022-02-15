load('LW_2020_density_V2.mat')
ndata = length(tds_epoch);
for i=1:5:ndata
    clf;
    for j=0:4
        ptr = i + j;
        if i+j > ndata
            break
        end
        if tds_channel_ref(ptr,1)==10
            tds_mode = 'TDS_SE1';
        else    
            tds_mode = 'TDS_XLD1';
        end
        % Pachenko's antenna angle
        pacang = 125.;
        V1=[0, 1];
        % Pachenko dipople antennas
        V2=[sind(pacang), cosd(pacang)]; 
        V3=[-sind(pacang), cosd(pacang)]; 
        if contains(tds_mode, 'SE1')
            % SE1 TDS mode
            M(1,:) = V1; %CH1
            M(2,:) = V2; %CH2
            tds_mode = 'se1';
        else 
            % construct transformation matrix ANT->SRF 
            pacang = 158.1; % ANT12 158.1 deg, ANT13 158.2 deg
            ant21= [sind(pacang), cosd(pacang)]; %E-field in the same sense.
            pacang = -158.2
            ant13= -1. * [sind(pacang), cosd(pacang)]; %ant31 then -1. to ant13
            M(1,:) = ant13; % 
            M(2,:) = ant21; % 
            % DIFF1 TDS mode is same
            if contains(tds_mode, 'DIFF1')
                tds_mode = 'diff1';
            else
                tds_mode = 'xld1';
            end
        end
        M = inv(M);
        wf = squeeze(tds_data(ptr,1:2,1:tds_nsamp(ptr)));
        E = M*wf(1:2,:) * 1e3; % transformation into SRF (Y-Z)
        if max(E(1,:)) > max(E(2,:))
            E_ = E(1,:);
            elbl = 'E_Y';
        else
            E_ = E(2,:);
            elbl = 'E_Z';
        end
        subplot(5, 1, j+1);
        t = (0:tds_nsamp(ptr)-1)/tds_samp_rate(ptr)*1e3;
        yyaxis left
        plot(t,E_)
        title('TDS TSWF');
        xlabel(sprintf('Time in ms after %s',datestr(tds_epoch(ptr), 31)));
        ylabel(sprintf('%s mV/m', elbl));
        hold on
        yyaxis right
        tt = density_epoch(ptr, 1:density_recs(ptr)) - tds_epoch(ptr);
        plot(tt * 86400e3, density_data(ptr,1:density_recs(ptr)))
        ylabel('n_e [cm^{-3}]')
        hold off
        %datetick
    end
    saveas(gcf,sprintf('./plots_wf/tds_densi_%03d.png', fix(i/5)),'png');
end