function model = loadModel(model)
file = importdata([model.dir '/config.txt']); %[EDITABLE] if you change the config file name
cd(model.dir)
model.dir = pwd;
ignoreChar = '%'; %[EDITABLE] if you change the ignore or comment header type
headerStartChar = '['; headerEndChar = ']:'; %[EDITABLE] if you change the config header format

% Find cells containing ignoreChar, and remove the strings after the ignoreChar, 
% basically ignore the comment marked with ignoreChar
ignoreIndex = strfind(file,ignoreChar);
for igIdx=1:numel(ignoreIndex)
    if(~isempty(ignoreIndex))
        file{igIdx} = erase(file{igIdx},file{igIdx}(ignoreIndex{igIdx}:end));
    end
end

headerIndex = {}; tempIndex = strfind(file,headerEndChar);
for hIdxFound=1:numel(tempIndex)
    if(~isempty(tempIndex{hIdxFound}))
        headerIndex = [headerIndex hIdxFound];
	end
end

for hIdx=1:numel(headerIndex)
    headerName = extractCharBetween(file{headerIndex{hIdx}},headerStartChar,headerEndChar);
    focusedHeaderFile = file(getHeaderContentIndex(file,headerStartChar,headerEndChar,headerName));
    for fIdx=1:numel(focusedHeaderFile)
        if(~isempty(focusedHeaderFile{fIdx}))
            model.(headerName){fIdx} = focusedHeaderFile{fIdx};
        end
    end
    if(numel(model.(headerName)) == 1)
        model.(headerName) = model.(headerName){1};
    end
end

end