function h = QEQC_Viz_Helper(dataframe, field)

exp_labels = dataframe(:,1)
%exp_labels = dataframe(:,12)

for i=1:size(exp_labels,1)
   exp_labels(i) = strip(exp_labels(i),'left','1')
   exp_labels(i) = strip(exp_labels(i),'left','8')
   exp_labels(i) = replace(exp_labels(i),"SQC","")
end

if strcmpi(field, 'PEP')
    mergeTest = merge_sets(dataframe{:,3});
    h = sort_PEP_QC(mergeTest);

% Distribution Plots of Precursor Intensity (WORKS)
elseif strcmpi( field, 'Pre' )  
    
    for i=1:size(dataframe,1)
        Pre_array{i} = log10(dataframe{i,2}.Intensity);
        pr = prctile(Pre_array{i}, [1 99])
        Pre_array{i}(Pre_array{i} < pr(1)) = pr(1)
        Pre_array{i}(Pre_array{i} > pr(2)) = pr(2)
    end
    
    h = distributionPlot(Pre_array, 'histOpt', 0);
    %ylim([3 10])
    %title('Precursor Intensity Over Time')
    xlabel('Sample');
    ylabel('Log_{10} Intensity');
    xticklabels(string(exp_labels));
    xtickangle(45);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    set(gca,'TickLabelInterpreter','none')
    print('5by3DimensionsFigure','-dpng','-r0')

% Distribution Plots of Retention Length at Base (WORKS)
elseif strcmpi( field, 'ReL' )    
    
    for i=1:size(dataframe,1)
        Ret_Len_array{i} = dataframe{i,2}.ReL;
        Ret_Len_array{i}(Ret_Len_array{i} > 2) = 2;
        Ret_Len_array{i} = Ret_Len_array{i}*60;
        pr = prctile(Ret_Len_array{i}, [1 99])
        Ret_Len_array{i}(Ret_Len_array{i} < pr(1)) = pr(1)
        Ret_Len_array{i}(Ret_Len_array{i} > pr(2)) = pr(2)
        
    end
    
    
    h = distributionPlot(Ret_Len_array, 'histOpt', 0);
    %title('Retention Lengths at Base')
    xlabel('Sample');
    ylabel('ReL (seconds)');
    xticklabels(string(exp_labels));
    set(gca,'TickLabelInterpreter','none')
    xtickangle(45);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')

% Distribution Plots of Retention Length FWHM (WORKS)
elseif strcmpi( field, 'FWHM' )

    for i=1:size(dataframe,1)
        Ret_Len_FWHM_array{i} = dataframe{i,4}.RTw;
        Ret_Len_FWHM_array{i}(Ret_Len_FWHM_array{i} > 45) = 45;
        pr = prctile(Ret_Len_FWHM_array{i}, [1 99])
        Ret_Len_FWHM_array{i}(Ret_Len_FWHM_array{i} < pr(1)) = pr(1)
        Ret_Len_FWHM_array{i}(Ret_Len_FWHM_array{i} > pr(2)) = pr(2)
    end

    
    h = distributionPlot(Ret_Len_FWHM_array, 'histOpt', 0);
    %title('Retention Lengths (FWHM)')
    xlabel('Sample');
    ylabel('FWHM (seconds)');
    %ylim([0 50]);
    xticklabels(string(exp_labels));
    set(gca,'TickLabelInterpreter','none')
    xtickangle(45);
    fig = gcf
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Distribution Plots of PIFS (WORKS)
elseif strcmpi( field, 'PIF' )
    
    for i=1:size(dataframe,1)
        PIFS_array{i} = dataframe{i,2}.PIF; 
        pr = prctile(PIFS_array{i}, [1 99])
        PIFS_array{i}(PIFS_array{i} < pr(1)) = pr(1)
        PIFS_array{i}(PIFS_array{i} > pr(2)) = pr(2)
    end

    
    h = distributionPlot(PIFS_array, 'histOpt', 0);
    ylim([0 1]);
    %title('PIFs');
    xlabel('Sample');
    ylabel('PIF');
    xticklabels(string(exp_labels));
    set(gca,'TickLabelInterpreter','none')
    xtickangle(45);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Distribution Plots of IDs by RT (WORKS)
elseif strcmpi( field, 'IDbyRT' )
    for i=1:size(dataframe,1)
        msmsFile = dataframe{i,8};
        %msmsIDd = msmsFile(msmsFile.PEP < .05,:)
        msmsIDd = (msmsFile.PEP < .05);
        %msmsIDd_Ret = msmsIDd.RT
        msmsIDd_Ret = msmsFile.RT(msmsIDd);
        msmsIDd_array{i} = msmsIDd_Ret;
    end

    
    h = distributionPlot(msmsIDd_array, 'histOpt', 0);
    %title('Number of IDs (PEP <.05) by Retention Time ')
    xlabel('Sample');
    ylabel('Retention Time');
    xticklabels(string(exp_labels));
    set(gca,'TickLabelInterpreter','none')
    xtickangle(45);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Distribution of Scan Events per Minute 
%       (In Progress...Needs msmsCount info)
elseif strcmpi( field, 'DutyCycles' )
    Most_recent_row = size(dataframe,1);
    
    Todays_msScan = dataframe{Most_recent_row, 10};
    maxInd = max(Todays_msScan.msmsCount);

    %Counting the number of occurences of each Top-n event
    for i=1:(maxInd+1)
        indexArray(:, i) = (Todays_msScan.msmsCount == (i-1));
        RTvector = Todays_msScan.RT(indexArray(:,i));
        RTvector(numel(indexArray(:,i))) = 0;
        RTvector(RTvector == 0) = NaN;
        RTArray(:,i) = RTvector;
    end

    %flexible array of legend labels
    msScans_legend_array = {'0 MS/MS', '1 MS/MS', '2 MS/MS', '3 MS/MS','4 MS/MS', '5 MS/MS', '6 MS/MS', '7 MS/MS'};

    bins = min( Todays_msScan.RT ): 2 : max( Todays_msScan.RT ); 

    fr = zeros( numel(bins),  size(RTArray,2)  );   
    
    for i = 1:size(RTArray,2) 
    fr(:, i) = histc( RTArray(:,i) , bins );
%     if  Normalize > 0
%         fr(:,i) = fr(:,i) / sum( fr(:,i) );
%     end
    end


    %COLOR = cool( size(RTArray,2) );
    r = linspace( 0, 1, size(RTArray,2) );
    g = zeros( size(r) );
    b = 1-r;
    COLOR = [r; g; b]';
    
    for i = 1:size(RTArray,2)
    %set( hb(i), 'FaceColor', COLOR(i,: ) )
    h = plot( bins, fr(:,i), 'linewidth', 3, 'color', COLOR(i,: ) ); hold on
    end


    %title(['Top-N over Gradient Length:' string(dataframe(Most_recent_row,1)) ])
    xlabel('Retention Time');
    ylabel('Count');
    legend(msScans_legend_array{1:(maxInd+1)});
    hold off;
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Distribution Plot of Intensities per Channel (WORKS)
elseif strcmpi( field, 'RecentInt' )
    
    Most_recent_row = size(dataframe,1);
    Int_legend_array = {'126C', '127N', '127C', '128N','128C', '129N','129C', '130N', '130C','131N','131C'};

    Intensity_data_from_evi = log10(dataframe{Most_recent_row,2}.data);
    Intensity_data_from_evi(~isfinite(Intensity_data_from_evi)) = NaN;
    
    number_of_channels = size(Intensity_data_from_evi,2);
    h = distributionPlot(Intensity_data_from_evi(:,:), 'histOpt', 0);
    %title(['Log_{10} Intensity of by Channel', string(dataframe(Most_recent_row,1))])
    xlabel('Channel');
    ylabel('Log_{10} Intensity');
    %xticklabels(string(dates_formatted))
    xticklabels(Int_legend_array(1:number_of_channels));
    xtickangle(45);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Distribution Plot of Long Retained Ions (NAN Values)
elseif strcmpi( field, 'LongRetIons' )
    
    for i = 1:(size(dataframe,1))
        currentAP = dataframe{i, 4};
        matchingIndices = ((currentAP.ReL > 5*60) & ((currentAP.z == 2) | (currentAP.z == 3)));
        Intensities_of_con = log10(currentAP.Intensity(matchingIndices));
        num_of_contaminants = numel(Intensities_of_con);
        if(num_of_contaminants == 0)
            num_of_contaminants = .5;
        end
        median_of_con = nanmedian(Intensities_of_con);
        if(isnan(median_of_con))
            median_of_con = 0;
        end
        num_of_CON_array(i) = num_of_contaminants;
        med_of_CON_array(i) = median_of_con;
    end

    h = scatter(categorical(string(dataframe(:,1))), med_of_CON_array, num_of_CON_array*100, 'o');
    %set(h,'SizeData',(num_of_CON_array/100));

    xlabel('Samples');
    set(gca,'TickLabelInterpreter','none')
    xticklabels(string(exp_labels))
    xtickangle(45);
    ylabel('Median Contaminant Intensity');
    %title('Long Retained Ions Intensity by Sample')
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Charge States for Most Recent Run [WORKS]
elseif strcmpi( field, 'ChargeStatesSingle' )
    Most_recent_row = size(dataframe,1);
    
    h = histl(dataframe{Most_recent_row,4}.z, 0:8);
    %title(['Charge States from allPeptides.txt', string(dataframe(Most_recent_row,1))])
    xlabel('Charge States')
    fig = gcf
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    
% Charge States for Most Recent Run [WORKS]
elseif strcmpi( field, 'ChargeStatesAll' )
       
    for i=1:size(dataframe,1)
        Charge_State_array{i} = dataframe{i,4}.z;
    end

    h = distributionPlot(Charge_State_array, 'histOpt', 0);
    %title('Charge States')
    xlabel('Sample');
    ylabel('Charge States');
    xticklabels(string(exp_labels));
    set(gca,'TickLabelInterpreter','none')
    xtickangle(45);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')

% Ion Map for most recent run [WORKS]
elseif strcmpi( field, 'IonMap' )
    Most_recent_row = size(dataframe,1);
    %colorMap = jet(length(unique(log(QC1AP.Intensity))));
    colorMap = jet(length(unique(log(dataframe{Most_recent_row,4}.Intensity))));
    h = scatter(dataframe{Most_recent_row,4}.RT,dataframe{Most_recent_row,4}.Mz,2,log(dataframe{Most_recent_row,4}.Intensity),'filled');
    h1 = colorbar;
    %title(["Ion Map", string(dataframe(Most_recent_row,1))])
    xlabel("Retention Time");
    ylabel("M/Z");
    ylabel(h1, 'log_{10} Intensity');
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
   
% Correlation to Bulk 
elseif strcmpi( field, 'Corr2Bulk' )    
    try
    for i=1:size(dataframe,1)
        ff_array{i} = qc_corrs(dataframe{i,3});
    end

    for i=1:size(dataframe,1)
        pearson_array(i) = ff_array{i}.pearson;
        spearman_array(i) = ff_array{i}.spearman;
        name_array(i) = string(exp_labels(i)) 
    end

    numTicks = size(pearson_array,2)
    plot(pearson_array, 'ro')
    hold on
    plot(spearman_array, 'bd' )
    hold off
    xticks([1:1:numTicks])
    xticklabels(name_array);
    set(gca,'TickLabelInterpreter','none')
    xtickangle(45);
    hl(1) = ylabel( 'Correlations' );
    hl(2) = legend( 'Pearson', 'Spearman',...
    'Location', 'northoutside', 'Orientation', 'Horizontal' );
    set(hl, 'FontSize', 28 ); 
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
    catch
        warning('Issue with Corr');
    end
    
% Fraction of Missing Data
elseif strcmpi( field, 'FracMissing' ) 
   try
    Most_recent_row = size(dataframe,1);
    divisions = [0.1 10^4 (4*(10^4)) (16*(10^4)) (64*(10^4)) inf];
    divisions = 10.^(0: 0.5 : 6);
    log_div = log10(divisions);

    carrierChannel_Int = dataframe{Most_recent_row, 2}.data(:,1);
    single_cell = [3 4 5 6];
    div_size = (size(divisions,2)-1);

    % Loop which calculates missing values (single-cell channels with zeroes)
    % as a function of carrier channel intensity. The total number of peptides
    % per intensity is also calculated

    %Change from one_back to two_back once data accumulates

    if(size(dataframe,1) < 3)
        two_back = (Most_recent_row - 1);
    elseif (size(dataframe,1) == 1)
        two_back = (Most_recent_row);
    else
        two_back = (Most_recent_row - 2);
    end

    for i=two_back:Most_recent_row
        
        carrierChannel_Int = dataframe{i, 2}.data(:,1);
        
        for j=1:(div_size)
    
            conditionMatch_Indices = (divisions(j) < carrierChannel_Int & carrierChannel_Int < (divisions(j+1)));
            conditionMatch_total(j) = sum(conditionMatch_Indices, 1);
       
            for k=1:4
                conditionMatch_missing(k) = sum(dataframe{i, 2}.data(conditionMatch_Indices, single_cell(k)) == 0);
       
            end
   
            conditionMatch_missing_total = sum(conditionMatch_missing);
            fraction_MD = (conditionMatch_missing_total./conditionMatch_total);
   
        end
            fraction_MD_storage{i} = fraction_MD;
            conditionMatch_total_storage{i} = conditionMatch_total;
    end


    colors_for_plot = ['r','b'];
    size_for_plot = [5, 5];
    conditionMatch_total_storage_recent = conditionMatch_total_storage((end-1):end);
    fraction_MD_storage_recent = fraction_MD_storage((end-1):end);

    
    for i=1:2
    hold on
    numberOfPeptides_per_IntensityLevel = conditionMatch_total_storage_recent{i}/size_for_plot(i);

    h = scatter(log_div(1:end-1), fraction_MD_storage_recent{i});
    set(h,'SizeData',numberOfPeptides_per_IntensityLevel,'MarkerEdgeColor',colors_for_plot(i));
    
    end
    %title('Fraction of Missing Values by Carrier Channel Intensity')
    xlabel('log_{10} Carrier Channel Intensity');
    ylabel('Fraction of Missing Data');
    legend(string(dataframe((end-1):end,1)));
    set(gca,'legendInterpreter','none')
    ylim([0 1]);
    hold off;
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8.75 6.56];
    print('5by3DimensionsFigure','-dpng','-r0')
   catch
   end
end

end