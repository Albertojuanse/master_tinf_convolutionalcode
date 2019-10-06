classdef Alphabet
    %ALPHABET Set of symbols for generate words
    
    properties
        symbols
    end
    
    methods
        function self = Alphabet(symbols)
            %ALPHABET Construct an instance an alphabet object given its
            %symbols
            self.symbols = symbols;
            return;
        end        
        
        function self = setSymbols(self, symbols)
            %SETELEMENTS Sets the symbols of the alphabet
            self.symbols = symbols;
            return;
        end
        
        function symbols = getSymbols(self)
            %GETSYMBOLS Returns the symbols of the alphabet
            symbols = self.symbols;
            return;
        end
        
        function self = addSymbols(self, symbol)
            %ADDSYMBOL Adds a symbols to the alphabet
            self.symbols(1, end + 1) = symbol;
            return;
        end
        
        function numberOfSymbols = numberOfSymbols(self)
            %DIMENSION Returns the number of symbols in the alphabet
            numberOfSymbols = size(self.symbols, 2);
            return;
        end
    end
end