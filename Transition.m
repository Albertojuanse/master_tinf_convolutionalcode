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
            from_state = self.from_state{1};
        end
        
        function to_state = getToState(self)
            %GETTOSTATE Returns the state to the transition was set
            to_state = self.to_state{1};
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
        
        function flag = isEqualsToTransition(self, other_transition)
            %ISEQUALSTOTRANSITION Return weather the object is equals to another
            flag = false;
            if (size(class(other_transition), 2)) == size(class(self), 2)
                if class(other_transition) == class(self)

                    other_from_state = other_transition.from_state;
                    if self.from_state.isEqualsToState(other_from_state)

                        other_to_state = other_transition.to_state;
                        if self.to_state.isEqualsToState(other_to_state)

                            other_input = other_transition.input;
                            if self.input == other_input

                                other_output = other_transition.output;
                                if self.output == other_output
                                    flag = true;
                                end

                            end

                        end

                    end

                end
            end
        end
        
    end
end

