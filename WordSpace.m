classdef WordSpace
    %WORDSPACE A set of valid words
    
    properties
        words
    end
    
    methods
        function self = WordSpace(words)
            %WORDSPACE Construct a word space given its words
            self.words = words;
        end      
        
        function self = setWords(self, words)
            %SETWORDS Sets the words of the space
            self.words = words;
            return;
        end
        
        function words = getWords(self)
            %GETWORDS Returns the words of the space
            words = self.words;
            return;
        end
        
        function self = addSymbols(self, word)
            %ADDWORD Adds a word to the space
            self.words(1, end + 1) = word;
            return;
        end
        
        function numberOfWords = numberOfWords(self)
            %LONGITUDEOSWORD Returns the number of words in the space
            numberOfWords = size(self.words, 2);
            return;
        end
    end
end

