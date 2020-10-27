function model = loadPRCCconfig(model,configDir)
file = importdata(configDir); %[EDITABLE] if you change the config file name
ignoreChar = '%'; %[EDITABLE] if you change the ignore or comment header type
headerStartChar = '['; headerEndChar = ']:'; %[EDITABLE] if you change the header format
paramStartChar = '=['; paramEndChar = ']'; %[EDITABLE] if you change the config header format

% Find cells containing ignoreChar, and remove the strings after the ignoreChar, 
% basically ignore the comment marked with ignoreChar
ignoreIndex = strfind(file,ignoreChar);
for igIdx=1:numel(ignoreIndex)
    if(~isempty(ignoreIndex))
        file{igIdx} = erase(file{igIdx},file{igIdx}(ignoreIndex{igIdx}:end));
    end
end

paramFile = file(getHeaderContentIndex(file,headerStartChar,headerEndChar,'param'));
paramFoundIndex = strfind(paramFile,paramStartChar);
for pIdx=1:numel(paramFile)
    if(~isempty(paramFile{pIdx}) && ~isempty(paramFoundIndex{pIdx}))
        paramName = extractCharBetween(paramFile{pIdx},'start','=');
        paramVector = eval(extractCharBetween(paramFile{pIdx},'=','end'));
        model.param.(paramName).min = paramVector(1);
        model.param.(paramName).baseline = paramVector(2);
        model.param.(paramName).max = paramVector(3);
    end
end

stateFile = file(getHeaderContentIndex(file,headerStartChar,headerEndChar,'state'));
for sIdx=1:numel(stateFile)
    stateName = extractCharBetween(stateFile{sIdx},'start','=');
    model.state.(stateName).initial = eval(extractCharBetween(stateFile{sIdx},'=','end'));
end

end