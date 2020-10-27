function contentIndex = getHeaderContentIndex(importedFile,startChar,endChar,chosenHeader)
    headerIndex = {}; headerName = {};
    tempIndex = strfind(importedFile,endChar);
    for hIdxFound=1:numel(importedFile)
        if(~isempty(tempIndex{hIdxFound}))
            headerIndex = [headerIndex hIdxFound];
            headerName = [headerName extractCharBetween(importedFile{hIdxFound},startChar,endChar)];
        end
    end
    for chIdx=1:numel(headerIndex)
        if(strcmp(headerName{chIdx},chosenHeader))
            indexChosen = chIdx;
        end
    end
    if(indexChosen == numel(headerIndex))
        contentIndex = (headerIndex{indexChosen}+1):numel(importedFile);
    else
        contentIndex = (headerIndex{indexChosen}+1):(headerIndex{indexChosen+1}-1);
    end
end