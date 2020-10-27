function outputChar = extractCharBetween(inputChar,startChar,endChar)
    if(strcmp(startChar,'start'))
        startIdx = 1;
        startCharLength = 0;
    else
        startIdx = strfind(inputChar,startChar);
        startCharLength = length(startChar);
    end
    if(strcmp(endChar,'end'))
        outputChar = inputChar(startIdx+startCharLength:end);
    else
        endIdx = strfind(inputChar,endChar);
        outputChar = inputChar(startIdx+startCharLength:endIdx-1);
    end
end