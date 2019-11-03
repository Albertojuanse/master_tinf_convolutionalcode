classdef StateMachine
    %STATEMACHINE Defines an state machine, its states and transitions
    
    properties (Access = public)
        states
        states_adjacency_matrix
        states_input_matrix
        states_output_matrix
        states_transitions
        transitions
    end
    
    methods
        function self = StateMachine(numberOfStates)
            %STATEMACHINE Construct a state machine object
            init_to_state = State(-1);
            init_from_state = State(-1);
            init_input = Word([-1]);
            init_output = Word([-1]);
            self.states_adjacency_matrix = zeros(numberOfStates, numberOfStates);
            for i_state = 1:numberOfStates
                
                for j_state = 1:numberOfStates
                    self.states_input_matrix{i_state, j_state} = Word([-1]);
                    self.states_output_matrix{i_state, j_state} = Word([-1]);
                    self.states_transitions{i_state, j_state} = Transition(init_from_state, init_to_state, init_input, init_output);
                end
            end
            self.transitions{1, end+1} = self.states_transitions{1,1};
        end
        
        % Getters and setters
        function self = setStates(self, states)
            %SETSTATES Adds a set of states as the states of the machine
            self.states = states;
        end
        
        function self = addState(self, state)
            %ADDSTATE Adds a state to the machine
            self.states{1, end + 1} = state;
        end
        
        function self = addStates(self, states)
            %ADDSTATES Adds a set of states to the machine
            for s = 1:size(self.states, 2)
                self.states{1, end + 1} = states{s};
            end
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
        
        % Instance methods        
        function self = resetMachine(self)
            %RESETMACHINE Set the instance atributes as an initial state
            
            % Control error
            if size(self.states, 2) < 2
                fprintf('[ERROR] State machine reset error: insuficent number of states %.2f \n', size(self.states, 2));
            end
            
            equalsStatesFound = false;
            for i_state = 1:size(self.states, 2)
                for j_state = 1:size(self.states, 2)
                    if i_state ~= j_state
                        if self.states{i_state}.getValue() == self.states{j_state}.getValue()
                            equalsStatesFound = true;
                        end
                    end
                end
            end
            if equalsStatesFound
                fprintf('[ERROR] State machine reset error: found two equals states \n');
            end
            
            if size(self.states_adjacency_matrix, 2) ~= size(self.states, 2)
                if size(self.states_adjacency_matrix, 1)  ~= size(self.states, 1)
                    fprintf('[ERROR] State machine reset error: adjacency matrix must be %.2fx%.2f \n', size(self.states, 1), size(self.states, 2));
                end
            end
            
            if size(self.states_input_matrix, 2) ~= size(self.states, 2)
                if size(self.states_input_matrix, 1)  ~= size(self.states, 1)
                    fprintf('[ERROR] State machine reset error: input matrix must be %.2fx%.2f \n', size(self.states, 1), size(self.states, 2));
                end
            end
            
            if size(self.states_output_matrix, 2) ~= size(self.states, 2)
                if size(self.states_output_matrix, 1)  ~= size(self.states, 1)
                    fprintf('[ERROR] State machine reset error: output matrix must be %.2fx%.2f \n', size(self.states, 1), size(self.states, 2));
                end
            end
            
            % Construct the machine
            % Search in the adjacency matrix            
            self.states_transitions  = {};
            for i_row = 1:size(self.states, 1)
                for i_column = 1:size(self.states, 1)
                    
                    if self.states_adjacency_matrix(i_row, i_column) == 1
                        
                        % Create a transition with all the information
                        from_state = self.states(1, i_row);
                        to_state = self.states(1, i_column);
                        input = self.states_input_matrix(i_row, i_column);
                        output = self.states_output_matrix(i_row, i_column);
                        transition = Transition(from_state, to_state, input, output);
                        self.states_transitions{i_row, i_column} = transition;
                        
                    end
                    
                end
            end
            
            % Start in rest
            self.transitions{1, end+1} = self.states_transitions{1,1};
            
        end
        
        function output = runMachineWithInput(self, input)
            %RUNMACHINEWITHINPUT Set the machine in the next state given an
            %input
            
            output = -1;
            
            last_transition =  self.transitions{1, end};
            last_to_state = last_transition.getToState();
            last_from_state = last_transition.getFromState();
            
            % for every transition search for which the last final to_state
            % is the one from_state
            for i_transition = 1:size(self.states_transitions, 1)
                
                each_transition = self.states_transitions{i_transition, 1};
                each_to_state = each_transition.getFromState();
                if each_to_state{1}.isEqualsToState(last_to_state)
                    
                    % and when found, check if the given input is the 
                    % transition one
                    each_input = each_transition.getInput();
                    if each_input == input
                        
                        % transition found; save
                        output = each_transition.getOutput();
                        self.transitions{1, end+1} = each_transition;
                        
                    end                    
                    
                end
                
            end
            
        end
        
    end
    
end