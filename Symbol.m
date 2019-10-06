classdef Symbol
    %SYMBOL A symbol of an alphabet
    
    properties
        coordinates
    end
    
    methods
        function self = Symbol(coordinates)
            %SYMBOL Construct an instance of a symbol given its basis and
            %coordinates
            self.coordinates = coordinates;
            return;
        end
        
        function self = setCoordinates(self, coordinates)
            %SETCOORDINATES Sets the coordinates of the symbol known its basis
            self.coordinates = coordinates;
            return;
        end 
        
        function coordinates = getCoordinates(self)
            %GETCOORDINATES Gets the coordinates of the symbol known its basis
            coordinates = self.coordinates;
            return;
        end
        
        function longitude = longitude(self)
            %DIMENSION Returns the number of alphabet 
            dimension = size(self.coordinates, 2);
            return;
        end
    end
end