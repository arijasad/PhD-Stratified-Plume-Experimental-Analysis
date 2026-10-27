function outputFiles = test_forward_ray_A(cfg)
% Reconstruct each selected image and save its forward projection.
% Start with cfg = plif_settings(), then supply the image and calibration data.
% MAT files retain the full-precision field and its validity masks.
% The standalone PNG is a masked preview; its mask is also saved separately.
if nargin < 1
    error('PLIF:Settings', 'Supply a configuration created with plif_settings().');
end
[cali,imageFiles,outputNames] = plif_prepare(cfg,'_PLIF_forward');
fieldFolder = fullfile(cfg.outputFolder,'reconstructed_fields');
for k = 1:numel(imageFiles)
    fieldPath = fullfile(fieldFolder,[outputNames{k} '.png']);
    maskPath = fullfile(fieldFolder,[outputNames{k} '_valid_mask.png']);
    if ~cfg.overwrite && (isfile(fieldPath) || isfile(maskPath))
        error('PLIF:ExistingOutput', 'A field preview or validity mask already exists for %s.',outputNames{k});
    end
end
if ~isfolder(fieldFolder)
    mkdir(fieldFolder);
end
outputFiles = cell(numel(imageFiles),4);
for k = 1:numel(imageFiles)
    fprintf('Reconstruction %d/%d: %s\n',k,numel(imageFiles),imageFiles{k});
    image_in = plif_read_image(fullfile(cfg.inputFolder,imageFiles{k}),cfg.cropRect);
    result = plif_reconstruct(image_in,cali,cfg);
    sourceFile = imageFiles{k};
    dataPath = fullfile(cfg.outputFolder,[outputNames{k} '.mat']);
    maskedReconstructedField = result.maskedReconstructedField;
    validMask = result.validMask;
    coverageMask = result.coverageMask;
    save(dataPath,'result','maskedReconstructedField','validMask', ...
        'coverageMask','cfg','sourceFile');
    fieldPath = fullfile(fieldFolder,[outputNames{k} '.png']);
    maskPath = fullfile(fieldFolder,[outputNames{k} '_valid_mask.png']);
    imwrite(uint8(validMask)*255,maskPath,'png');

    fig = figure('Color','w','Visible','off','Position',[100 100 1400 440]);
    cleanup = onCleanup(@() close(fig));
    layout = tiledlayout(fig,1,4,'Padding','compact','TileSpacing','compact');
    panels = {result.measuredFluorescence,result.maskedReconstructedField, ...
        result.syntheticFluorescence, ...
        abs(result.syntheticFluorescence-result.measuredFluorescence)};
    labels = {'Measured fluorescence','Reconstructed field', ...
        'Synthetic fluorescence','Absolute residual'};
    commonValues = [panels{1}(:);panels{3}(:)];
    commonValues = commonValues(isfinite(commonValues));
    if isempty(commonValues)
        error('PLIF:ForwardImage', 'No finite fluorescence values were produced for %s.',sourceFile);
    end
    commonLimits = [min(commonValues) max(commonValues)];
    if commonLimits(1) == commonLimits(2)
        commonLimits(2) = commonLimits(1)+1;
    end
    for p = 1:4
        ax = nexttile(layout);
        imagesc(ax,panels{p});
        set(ax,'Color','white');
        axis(ax,'image');
        axis(ax,'off');
        title(ax,labels{p});
        colorbar(ax);
        if p == 1 || p == 3
            caxis(ax,commonLimits);
        elseif p == 2
            caxis(ax,[0 1]);
        end
    end
    colormap(fig,gray(256));
    sgtitle(layout,sourceFile,'Interpreter','none');
    figurePath = fullfile(cfg.outputFolder,[outputNames{k} '.png']);
    exportgraphics(fig,figurePath,'Resolution',cfg.figureResolution,'BackgroundColor','white');

    fieldFig = figure('Color','w','Visible','off');
    fieldAxes = axes(fieldFig);
    imagesc(fieldAxes,result.maskedReconstructedField,[0 1]);
    set(fieldAxes,'Color','white');
    axis(fieldAxes,'image');
    axis(fieldAxes,'off');
    colormap(fieldFig,gray(256));
    exportgraphics(fieldFig,fieldPath,'Resolution',cfg.figureResolution,'BackgroundColor','white');
    close(fieldFig);
    outputFiles(k,:) = {dataPath,figurePath,fieldPath,maskPath};
    clear cleanup
end
end
