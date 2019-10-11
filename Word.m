classdef Word
    %WORD Set of symbols from an alphabet that represents some experiment
    %result
    
    properties (Access = private)
        symbols
    end
    
    methods
        function self = Word(symbols)
            %WORD Construct an instance a aword given its symbols
            self.symbols = {};
            self.symbols{1, 1} = symbols;
            return;
        end        
        
        function self = setSymbols(self, symbols)
            %SETSYMBOLS Sets the symbols of the word
            self.symbols{1, 1} = symbols;
            return;
        end
        
        function symbols = getSymbols(self)
            %GETSYMBOLS Returns the symbols of the word
            symbols = self.symbols{1, 1};
            return;
        end
        
        function self = addSymbol(self, symbol)
            %ADDSYMBOL Adds a symbol to the word
            matrix_symbols = self.symbols{1, 1};
            matrix_symbols = [matrix_symbols symbol];
            self.symbols{1, 1} = matrix_symbols;
            return;
        end
        
        function longitudeOfWord =longitudeOfWord(self)
            %LONGITUDEOSWORD Returns the number of symbols in the word
            matrix_symbols = self.symbols{1, 1};
            longitudeOfWord = size(matrix_symbols, 2);
            return;
        end
    end
end