function vd=build_data(path)
    files = dir(path);
    place = 1
    file_annots = cell(1,2);
    for file = files'
        try
            file_annots{place, 1} = file.name;
            file_path = strcat(file.folder, '\', file.name);
            info_wub = data_extraction(file_path);
            file_annots{place, 2} = [file_annots{place,2}, info_wub];
            % Do some stuff
            place = place + 1
        catch
            place = place + 1
        end
    end
    
    files = dir('F:\Matlab\Image processing\Project\MIT Car dataset\ScaledGS\*.jpg');
    place = 1
    for file = files'
        try
            file_path = strcat(file.folder, '\', file.name);
            file_annots{place, 1} = file_path; 
            place = place + 1;
        catch
            place = place + 1;
        end
    end
    headings = {'imageFilename', 'vehicle'};
    vd = cell2table(file_annots, 'VariableNames', headings);
end