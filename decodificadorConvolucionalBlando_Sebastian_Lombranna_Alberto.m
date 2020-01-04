function decoderOut = decodificadorConvolucionalBlando_Sebastian_Lombranna_Alberto(decoderIn)
    %DECODIFICADORCONVOLUCIONALBLANDO_SEBASTIAN_LOMBRANNA_ALBERTO
    % Soft decoder
    
    %% Specifications
    
    % The specification of the soft decoder design is only to implement
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
    
    %trellis_states(end+1,:) = STATES(2,:);
    
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
                        
                        %% Get the possible transitions output
                        current_output = STATES_OUTPUT(i_transition,:);
                        
                        %% Asign next trellis iteration adjacencies and states
                        for i_each_transition = 1:size(STATES_ADJACENCY,1)
                            each_transition = STATES_ADJACENCY(i_each_transition,:);
                            each_next_state = each_transition(1,1:WORD_SIZE);
                            if equals(each_next_state,current_next_state)
                                trellis_adjacency(i_trellis_column + 1, i_each_transition) = '1';
                                for i_each_state = 1:size(STATES,2)
                                    each_state = STATES(i_each_state,:);
                                    if equals(each_next_state,each_state)
                                        trellis_states(i_trellis_column + 1, i_state) = '1';
                                    end
                                end
                            end
                        end
                        
                    end                    
                end
                
            end
        end

        
        %% Calculate weights of every transition
        possible_weights = [];
        % For every transition, compare input with possible outpus.
        for i_transition = 1:size(possible_transitions,1)
            
            possible_output = possible_outputs(i_transition,:);
            possible_output_first = char(possible_output(1));
            possible_output_second = char(possible_output(2));
            
            distance_first = first_input-str2double(regexp(possible_output_first,'\d*','match'));
            distance_second = second_input-str2double(regexp(possible_output_second,'\d*','match'));
            
            possible_weights(end + 1,:) = distance_first^2 + distance_second^2;
            
        end
        
        %% Asign the weights to the next column node
        % Evaluate each transition and asign the weight
        % For every possible trasition...
        i_weight = 1;
        for i_transition = 1:size(possible_transitions,1)
            
            current_transition = possible_transitions(i_transition,:);
            
            % ...search its possible transitions.
            % For every node of the current column in trellis...
            i_adjacency = 1;
            for i_state = 1:size(STATES,1)
                
                each_state_first = STATES(i_state,1);
                each_state_second = STATES(i_state,2);
                each_state = [each_state_first each_state_second];
                
                % ...get every possible next column node...
                next_nodes = STATES_ADJACENCY(i_state,:);
                
                for i_next_node = 1:WORD_SIZE:size(next_nodes,2)
                                
                    each_next_node_first = next_nodes(i_next_node);
                    each_next_node_second = next_nodes(i_next_node + 1);
                    each_next_node = [each_next_node_first each_next_node_second];
                    
                    each_transition = [each_state each_next_node];
                    
                    if isequal(each_transition, current_transition)
                        trellis_nodes_weights(i_trellis_column + 1, i_adjacency) = possible_weights(i_weight,1);
                        i_weight = i_weight + 1;
                    end
                    i_adjacency = i_adjacency + 1;
                end
                
            end
            
        end        
        
        %% Iterations
        i_trellis_column = i_trellis_column + 1;
        
    end
    
    % 2)  Evaluate those edges weight and save path.
    % 3)  Evaluate next-step nodes; discard less-weighted.
    % 3b) Follow less-weighted edges.
    % 3c) If linked node is empty discard iteratively
    
    %% Post-treatment
    fprintf('[CONV] The size of decoderIn is %.2f \n', size(decoderIn, 2));
    extendedDecoderOut = fliplr(input_inverse_secuence);
    fprintf('[CONV] The size of extendedDecoderOut is %.2f \n', size(extendedDecoderOut, 2));
    if bits_left > 0
        decoderOut = extendedDecoderOut(1:(size(extendedDecoderOut,2)-1));
        % Tail bits and 'rest first word'
        decoderOut = decoderOut(1:(size(decoderOut,2) - (size(TB,2))-1) );
    else
        % Tail bits and 'rest first word'
        decoderOut = extendedDecoderOut(1:(size(extendedDecoderOut,2) - (size(TB,2))) );        
    end
    fprintf('[CONV] The size of decoderOut is %.2f \n', size(decoderOut, 2));
    
end

%% Auxiliar functions
function addition = binaryAddition(s1, s2)
    addition = s1+s2;
    addition = mod(addition,2);
end

function distance = softDistance(s1, s2)
    
    % Mean squared error of the inputs
    if size(s1, 2) == size(s2, 2)
        
        squared_sum = 0;
        for i_dis = 1:size(s1, 2)
           
            squared_sum = squared_sum + (s1(i_dis)-s2(i_dis))^2;
            
        end        
        distance = squared_sum/size(s1, 2);
        
    else
        return;
    end
end



