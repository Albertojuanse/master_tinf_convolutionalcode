classdef State
    %STATE Define a state in a state machine
    
    properties (Access = private)
        state_value
    end
    
    methods
        function self = State(value)
            %STATE Construct a state given its value
            self.state_value = value;
        end
        
        function value = getValue(self)
            %GETVALUE Getter of state value
            value = self.state_value;
        end
    end
    
end