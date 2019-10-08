classdef Transition
    %TRANSITION Defines a transition between a state and another
    %   Detailed explanation goes here
    
    properties (Access = private)
        from_state
        to_state
        input
        output
        accumulated_path
    end
    
    methods
        function self = Transition(from_state, to_state, input, output)
            %TRANSITION Construct a transition between a state and another
            self.from_state = from_state;
            self.to_state = to_state;
            self.input = input;
            self.output = output;
            self.accumulated_path = 0;
        end
        
        function from_state = getFromState(self)
            %GETFROMSTATE Returns the state from the transition was set
            from_state = self.from_state;
        end
        
        function to_state = getToState(self)
            %GETTOSTATE Returns the state to the transition was set
            to_state = self.to_state;
        end
        
        function input = getInput(self)
            %GETINPUT Returns input that triggers the transition
            input = self.input;
        end
        
        function output = getOutput(self)
            %GETOUTPUT Returns output that triggers the transition
            output = self.output;
        end
        
        function accumulated_path = getAccumulatedPath(self)
            %GETACCUMULATEDPATH Returns the accumulated path weights
            accumulated_path = self.accumulated_path;
        end
        
        function self = addAccumulatedPath(self, path)
            %ADDACCUMULATEDPATH Adds a value to accumulated path weights
            self.accumulated_path = self.accumulated_path + path;
        end
        
    end
end

