classdef Word
    %WORD Set of symbols from an alphabet that represents some experiment
    %result
    
    properties (Access = private)
        symbols
    end
    
    methods
        function self = Word(symbols)
            %WORD Construct an instance a aword given its symbols
            self.symbols = symbols;
            return;
        end        
        
        function self = setSymbols(self, symbols)
            %SETSYMBOLS Sets the symbols of the word
            self.symbols = symbols;
            return;
        end
        
        function symbols = getSymbols(self)
            %GETSYMBOLS Returns the symbols of the word
            symbols = self.symbols;
            return;
        end
        
        function self = addSymbol(self, symbol)
            %ADDSYMBOL Adds a symbol to the word
            self.symbols(1, end + 1) = symbol;
            return;
        end
        
        function longitudeOfWord =longitudeOfWord(self)
            %LONGITUDEOSWORD Returns the number of symbols in the word
            longitudeOfWord = size(self.symbols, 2);
            return;
        end
    end
end