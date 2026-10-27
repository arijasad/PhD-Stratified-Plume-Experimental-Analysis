function [normalisedSignal, recordMaximum] = normalise_dye_record(dyeSignal)
%NORMALISE_DYE_RECORD Scale a dye-signal record by its maximum value.
%   NORMALISE_DYE_RECORD(DYESIGNAL) divides every value by the maximum
%   across the complete supplied record. Pass the image stack or signal
%   array used for display; no per-frame scaling or offset is applied.
%
%   [NORMALISEDSIGNAL, RECORDMAXIMUM] also returns the scale factor.

    validateattributes(dyeSignal, {'numeric'}, ...
        {'real', 'nonempty', 'finite'}, mfilename, 'dyeSignal');

    dyeSignal = double(dyeSignal);
    recordMaximum = max(dyeSignal(:));
    if recordMaximum <= 0
        error('normalise_dye_record:NonpositiveMaximum', ...
            'The complete dye-signal record must have a positive maximum.');
    end

    normalisedSignal = dyeSignal ./ recordMaximum;
end
