function decoderOut = decodificadorConvolucionalDuro_Sebastian_Lombranna_Alberto(decoderIn)
    %DECODIFICADORCONVOLUCIONALDURO_SEBASTIAN_LOMBRANNA_ALBERTO Hard decoder
    
    %% Specifications
    
    % The specification of the hard decoder design is only to implement
    % efficiently the Viterbi algorithm.
    
    %% Design decisions
    
    % This algorithm is a quite closed optimal solution and so a less
    % number of design decisitions must be don
    
    %% Variable declaration and initialization
    k = 3;                      % Number of registers in convolutional coder
    TB = zeros(1, k);           % Tail bits
    
    %% Decoder preparation
    input_size = size(decoderIn,2);
    extendedDecoderOut = zeros(abs(input_size/2), 1); % Ignored an possible odd input
    WORD_SIZE = 2;
    STATES =            [        '00'       ;        '01'       ;        '10'       ;        '11'       ];
    STATES_ADJACENCY =  ['00','00';'00','10';'01','00';'01','10';'10','01';'10','11';'11','01';'11','11'];
    STATES_OUTPUT =     [   '00'  ;   '11'  ;   '11'  ;   '00'  ;   '10'  ;   '01'  ;   '01'  ;   '10'  ];
    STATES_INPUT =      [   '0'   ;   '1'   ;   '0'   ;   '1'   ;   '0'   ;   '1'   ;   '0'   ;   '1'   ];
    
    % Collections for saving the used states, acumulated path cost...; 
    % the trellis diagram. Note that the zeros and ones strings here
    % represent boobleans
    trellis_width = abs(input_size/2) + 1;
    trellis_states = zeros(trellis_width,size(STATES, 1));
    trellis_states(1,:) = '1000';               % Boolean coding of states
    trellis_adjacency = zeros(trellis_width, size(STATES_ADJACENCY,1));
    trellis_adjacency(1,:) = '11000000';
    trellis_nodes_weights = ones(trellis_width, size(STATES_ADJACENCY,1));
    trellis_nodes_weights = trellis_nodes_weights * (-1);
    trellis_nodes_paths = ones(trellis_width, size(STATES, 1));
    trellis_nodes_paths = trellis_nodes_paths * 99999;
    for i_state = 1:size(trellis_states,2)
        if isequal(trellis_states(1,i_state),'1')
            trellis_nodes_paths(1,i_state) = 0;
        end
    end
    trellis_nodes_lower_transitions = ones(trellis_width,size(STATES,1));
    trellis_nodes_lower_transitions = trellis_nodes_lower_transitions * (-1);
    
    % Threshold decision
    for i_input = 1:input_size
        if decoderIn(i_input) > 0.5
            decoderIn(i_input) = 1;
        else
            decoderIn(i_input) = 0;
        end
    end
    
    %% Decoding
    
    % For every pair of inputs
    i_trellis_column = 1;
    for i_input = 1:WORD_SIZE:input_size
        
        first_input = decoderIn(i_input);
        second_input = decoderIn(i_input + 1);
        
        % The collections in the current trellis column are
        % -> the states that must be evaluated,
        % -> its adjacencies,
        % -> the distances between what's revived and what's can be, and
        % -> 
        
        %% Get the possible transitions from each active node
        possible_transitions = [];
        bool_current_trellis_states = trellis_states(i_trellis_column,:);
        trellis_adjacency(i_trellis_column + 1, :) = '00000000'; % For asign next trellis iteration 
        trellis_states(i_trellis_column + 1, :) = '0000';
        % For every state that must be eveluated in this column...
        for i_state = 1:size(bool_current_trellis_states,2)
            bool_current_trellis_state = bool_current_trellis_states(1,i_state);
            if isequal(bool_current_trellis_state, '1')
                
                current_trellis_state = STATES(i_state,:);
                
                % For every possible transitions to node of the following 
                % column in trellis...
                bool_current_transitions = trellis_adjacency(i_trellis_column,:);
                for i_transition = 1:size(bool_current_transitions,2)
                    bool_current_transition = bool_current_transitions(1,i_transition);
                    if isequal(bool_current_transition, '1')
                        
                        current_transition = STATES_ADJACENCY(i_transition,:);
                        
                        current_state = current_transition(1,1:WORD_SIZE);
                        current_next_state = current_transition(1,WORD_SIZE+1:2*WORD_SIZE);
                        
                        %% Get the possible transitions outputç
                        % Get the current transition output in the state
                        % machine.
                        current_output = STATES_OUTPUT(i_transition,:);
                        
                        %% Asign next trellis iteration adjacencies and states
                        % Identify each transition and states and set them
                        % as true to check them in the next trellis column.
                        for i_each_transition = 1:size(STATES_ADJACENCY,1)
                            each_transition = STATES_ADJACENCY(i_each_transition,:);
                            each_next_state = each_transition(1,1:WORD_SIZE);
                            if isequal(each_next_state,current_next_state)
                                trellis_adjacency(i_trellis_column + 1, i_each_transition) = '1';
                                for i_each_state = 1:size(STATES,2)
                                    each_state = STATES(i_each_state,:);
                                    if isequal(each_next_state,each_state)
                                        trellis_states(i_trellis_column + 1, i_state) = '1';
                                    end
                                end
                            end
                        end
                        
                        %% Calculate weights of every transition
                        % For every transition, compare input with possible outpus.
                        output_first = char(current_output(1));
                        output_second = char(current_output(2));
                        distance_first = abs(first_input-str2double(regexp(output_first,'\d*','match')));
                        distance_second = abs(second_input-str2double(regexp(output_second,'\d*','match')));
                        current_weight = distance_first + distance_second;
                        
                        %% Asign the weights to the next column node
                        trellis_nodes_weights(i_trellis_column + 1, i_transition) = current_weight;
                                                
                    end
                end
                
            end
        end
        
        %% Decide and asign the accumulated paths to the nodes
        % For every weight calculated...
        current_weights = trellis_nodes_weights(i_trellis_column + 1, :);
        for i_transition = 1:size(current_weights,2)
            
            %% Evaluate current transition states
            current_transition = STATES_ADJACENCY(i_transition,:);
            current_state = current_transition(1,1:WORD_SIZE);
            current_next_state = current_transition(1,WORD_SIZE+1:2*WORD_SIZE);
            current_weight = current_weights(1,i_transition);
            
            % ...get the state from which the transition starts and
            %    get the state to which the transition aims...
            for i_state = 1:size(STATES,1)
                if isequal(current_state, STATES(i_state,:))
                    i_current_state = i_state;
                end
                if isequal(current_next_state, STATES(i_state,:))
                    i_current_next_state = i_state;
                end
            end
            % ...and if it is so, decide if this is the lowest.
            
            %% Get path value from the state from the transition starts
            current_state_path = trellis_nodes_paths(i_trellis_column,i_current_state);
            
            %% Calculate path value to the state to the transition aims
            current_next_state_path = current_state_path + current_weight;
            
            %% Decide if this one is lower than the accumulated path in node
            each_next_state_path = trellis_nodes_paths(i_trellis_column + 1, i_current_next_state);
            if current_next_state_path < each_next_state_path
                trellis_nodes_paths(i_trellis_column + 1, i_current_next_state) = current_next_state_path;
                trellis_nodes_lower_transitions(i_trellis_column + 1, i_current_next_state) = i_transition;
            end
            if current_next_state_path == each_next_state_path
                bool_weights_equals = true;
            end

            %% TO DO: DELETE IMPOSSIBLE PATHS
            
        end
        
        %% Iterations
        i_trellis_column = i_trellis_column + 1;
        
    end
    
    %% Get lower paths transitions way back
    input_secuence = zeros(1,trellis_width-1);
    
    % Locate the lower path accumulated in the last iteration
    last_iteration_lower_path = 99999;
    last_iteration_lower_path_i_state = -1;
    for i_state = 1:size(STATES,1)
        if trellis_nodes_paths(trellis_width,i_state) < last_iteration_lower_path
            last_iteration_lower_path = trellis_nodes_paths(trellis_width,i_state);
            last_iteration_lower_path_i_state = i_state;
        end
    end
    % Do the way back
    i_current_next_state = last_iteration_lower_path_i_state;
    for i_reverse_input = fliplr(2:1:trellis_width)
        
        % Get transition, its states and its input
        i_transition = trellis_nodes_lower_transitions(i_reverse_input,i_current_next_state);
        current_transition = STATES_ADJACENCY(i_transition,:);
        current_input = STATES_INPUT(i_transition,:);
        current_state = current_transition(1,1:WORD_SIZE);
        
        % Save the input that triggered that transition
        input_secuence(1,i_reverse_input) = str2double(regexp(current_input,'\d*','match'));
        
        % Get the next state index for the next transition
        for i_state = 1:size(STATES,1)
            each_state = STATES(i_state,:);
            if isequal(current_state,each_state)
                i_current_next_state = i_state;
            end
        end
        
    end
    
    %% Post-treatment
    extendedDecoderOut = input_secuence;
    decoderOut = extendedDecoderOut(2:(size(extendedDecoderOut,2) - (size(TB,2))) );

end

%% Auxiliar functions
function addition = binaryAddition(s1, s2)
    addition = s1+s2;
    addition = mod(addition,2);
end

function distance = hammingDistance(s1, s2)
    
    % Distance of Hamming cannot be evaluated in different dimension
    % spaces
    distance = [];
    if size(s1, 2) == size(s2, 2)
        add = binaryAddition(s1, s2);
        distance = 0;
        for b = 1:size(add, 2)
            distance = distance + add(1, b);
        end
    else
        return;
    end
end

