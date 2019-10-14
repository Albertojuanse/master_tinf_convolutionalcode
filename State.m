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
        
        function flag = isEqualsToState(self, other_state)
            %ISEQUALSTOSTATE Return weather the object is equals to another
            flag = false;
            if (size(class(other_state), 2)) == size(class(self), 2)
                if class(other_state) == class(self)
                    if self.state_value == other_state.state_value
                        flag = true;
                    end
                end
            end
        end
    end
    
end