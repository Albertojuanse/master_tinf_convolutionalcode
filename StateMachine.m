classdef StateMachine
    %STATEMACHINE Defines an state machine, its states and transitions
    
    properties (Access = private)
        states
        states_adjacency_matrix
        states_input_matrix
        states_output_matrix
    end
    
    methods
        function self = StateMachine()
            %STATEMACHINE Construct a state machine object
            self.states = [];
            self.states_adjacency_matrix = [;];
            self.states_input_matrix = [;];
            self.states_output_matrix = [;];
        end
        
        % Getters and setters
        function self = setStates(self, states)
            %SETSTATES Adds a set of states as the states of the machine
            self.states = states;
        end
        
        function self = addState(self, state)
            %ADDSTATE Adds a state to the machine
            self.states(1, end + 1) = state;
        end
        
        function self = addStates(self, states)
            %ADDSTATES Adds a set of states to the machine
            self.states = [self.states states];
        end
        
        function self = setAdjacencyMatrix(self, adjacency_matrix)
            %SETADJACENCY Set the adjacency matrix of the state machine
            self.states_adjacency_matrix = adjacency_matrix;
        end
        
        function self = setInputMatrix(self, input_matrix)
            %SETINPUTMATRIX Set the input matrix of the state machine
            self.states_input_matrix = input_matrix;
        end
        
        function self = setOutputMatrix(self, output_matrix)
            %SETOUTPUTMATRIX Set the output matrix of the state machine
            self.states_output_matrix = output_matrix;
        end
        
    end
    
end