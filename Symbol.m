classdef Symbol
    %SYMBOL A symbol of an alphabet
    
    properties (Access = private)
        value
    end
    
    methods
        function self = Symbol(value)
            %SYMBOL Construct an instance of a symbol
            self.value = value;
            return;
        end
        
        function self = setValue(self, value)
            %SETVALUE Set the value of the symbol
            self.value = value;
            return;
        end 
        
        function value = getValue(self)
            %GETVALUE Gets the value of the symbol
            value = self.value;
            return;
        end
    end
end