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
    
    STATES =            [   '00'  ;   '01'  ;   '10'  ;   '11'  ];
    STATES_ADJACENCY =  ['00','10';'00','10';'01','11';'01','11'];
    STATES_OUTPUT =     ['00','11';'11','00';'10','01';'01','10'];
    STATES_INPUT =      [ '0   1' ; '0   1' ; '0   1' ; '0   1' ];
        
    % Collections for saving the used states, acumulated path cost...; 
    % the trellis diagram. Note that the zeros and ones strings here
    % represent boobleans
    trellis_states = zeros(abs(input_size/2),4);
    trellis_states(1,:) = '1000';               % Boolean coding of states
    trellis_adjacency = zeros(abs(input_size/2),8);
    trellis_adjacency(1,:) = '11000000';
    
    %trellis_states(end+1,:) = STATES(2,:);
    
    %% Decoding
    
    % For every pair of inputs
    for i_input = 1:2:input_size
        
        first_input = decoderIn(i_input);
        second_input = decoderIn(i_input + 1);
        
        % The collections in the current trellis column are
        % -> the states that must be evaluated,
        % -> its adjacencies,
        % -> its output of the state machine when triggered, and
        % -> the inputs that triggered that transtition.
        
        %% Get the nodes that must be evaluated in this iteration
        i_enum_state = 1;
        i_enum_adjacency = 1;
        current_trellis_states = [];
        current_trellis_adjacencies = [];
        for i_state = trellis_states(i_input,:)
            if isequal(i_state, '1')
                % Add this state
                current_trellis_states = [current_trellis_states STATES(i_enum_state,:)];
                
                % Add these adjacencies
                for i_node = 1:2:size(STATES_ADJACENCY,2)
                    if isequal(trellis_adjacency(i_input,i_enum_adjacency), '1')
                        current_trellis_adjacency_first = STATES_ADJACENCY(i_enum_state,i_node);
                        current_trellis_adjacency_second = STATES_ADJACENCY(i_enum_state,i_node+1);
                        current_trellis_adjacency = [current_trellis_adjacency_first current_trellis_adjacency_second];
                        current_trellis_adjacencies = [current_trellis_adjacencies current_trellis_adjacency];
                    end
                    i_enum_adjacency = i_enum_adjacency + 1;
                end
                i_enum_state = i_enum_state + 1;
            end
        end
        
        %% Get the possible transitions from each node
        possible_transitions = [];
        % For every node of the current column in trellis...
        for i_node = 1:2:size(current_trellis_states,2)
            current_node_first = current_trellis_states(1,i_node);
            current_node_second = current_trellis_states(1,i_node + 1);
            current_node = [current_node_first current_node_second];
            
            % ...get every possible next column node and compose the
            % transition.
            for i_next_node = 1:2:size(current_trellis_adjacencies,2)
            
                current_next_node_first = current_trellis_adjacencies(i_next_node);
                current_next_node_second = current_trellis_adjacencies(i_next_node + 1);
                current_next_node = [current_next_node_first current_next_node_second];
                current_transition = [current_node current_next_node];
                possible_transitions(end+1,:) = current_transition;
                
            end
            
        end
        
        %% Get the possible transitions output
        possible_outputs = [];
        % For every possible trasition...
        for i_transition = 1:size(possible_transitions,1)
            
            % ...search the transition in states machine
            for i_state = 1:size(STATES,1)
                
                each_state_first = STATES(i_state,1);
                each_state_second = STATES(i_state,2);
                each_state = [each_state_first each_state_second];
                
                next_nodes = STATES_ADJACENCY(i_state,:);
                
                for i_next_node = 1:2:size(next_nodes,2)
                                
                    each_next_node_first = next_nodes(i_next_node);
                    each_next_node_second = next_nodes(i_next_node + 1);
                    each_next_node = [each_next_node_first each_next_node_second];
                    
                    each_transition = [each_state each_next_node];
                    
                    if isequal(each_transition, possible_transitions(i_transition,:))
                        
                        % Found
                        found_output_first = STATES_OUTPUT(i_state, i_next_node);
                        found_output_second = STATES_OUTPUT(i_state, i_next_node + 1);
                        found_output = [found_output_first found_output_second];
                        possible_outputs(end+1,:) = found_output;

                    end
                    
                end
                
            end
            
        end
        
        %% Asign next trellis iteration adjacencies
        trellis_adjacency(i_input + 1, :) = '00000000';
        % For every possible trasition...
        for i_transition = 1:size(possible_transitions,1)
            
            current_transition = possible_transitions(i_transition,:);
            
            % ...get every possible next node...
            current_next_node = current_transition(1,3:4);
            
            % ...and search its possible transitions.            
            % For every node of the current column in trellis...
            i_adjacency = 1;
            for i_state = 1:size(STATES,1)
                
                each_state_first = STATES(i_state,1);
                each_state_second = STATES(i_state,2);
                each_state = [each_state_first each_state_second];
                
                % ...get every possible next column node...
                next_nodes = STATES_ADJACENCY(i_state,:);
                
                for i_next_node = 1:2:size(next_nodes,2)

                    % ... and if is equals to the state, set is true.
                    if isequal(current_next_node, each_state)
                    
                        trellis_adjacency(i_input + 1, i_adjacency) = '1';
                    
                    end
                    i_adjacency = i_adjacency + 1;

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
        
        
        
        %% States that in the next trellis column will have input edges
        states_with_transitions = {};
        
        % Next trellis column of nodes
        trellis(i_input + 1) = {states_with_transitions, STATES_ADJACENCY, STATES_OUTPUT, STATES_INPUT};
        
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



