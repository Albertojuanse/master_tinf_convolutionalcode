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
              
    STATES = [[0 0]; [0 1]; [1 0] ;[1 1]];
    STATES_ADJACENCY = [[[0 0] ;[1 0]]; [[0 0]; [1 0]]; [[0 1]; [1 1]]; [[0 1]; [1 1]]];
    STATES_OUTPUT = [[[0 0] [1 1]], [[1 1] [0 0]], [[1 0] [0 1]], [[0 1] [1 0]]];
    STATES_INPUT = [[0 1], [0 1], [0 1], [0 1]];
    
    STATES =            {'00';        '01';        '10';        '11'      };
    STATES_ADJACENCY = {{'00','10'}, {'00','10'}, {'01','11'}, {'01','11'}};
    STATES_OUTPUT =    {{'00','11'}, {'11','00'}, {'10','01'}, {'01','10'}};
    STATES_INPUT =     {{'0','1'},   {'0','1'},   {'0','1'},   {'0','1'}  };
    
    % The decoder input must be even with the word size...
    number_states = size(STATES,1);
    state_size = size(STATES{1},2);
    word_size = size(STATES_OUTPUT{1}{1},2);
    bits_excess = mod(size(decoderIn,2), word_size);
    if bits_excess ~= 0
        bits_left = word_size - bits_excess;
    else
        bits_left = 0;
    end    
    extendedDecoderIn = [decoderIn];
    for i = 1:bits_left
        extendedDecoderIn(end+1)=0;
    end
    % ...and start in rest
    first_state_array = zeros(1, word_size);
    extendedDecoderIn = [first_state_array extendedDecoderIn];
    
    % Collection for saving the acumulated path cost; an extra column for
    % the last analysis of edges
    % two dimensions for trellis,
    % third dimension for min{distance}[(distance, src_node, tar_node)]
    trellis_nodes = zeros(number_states, size(extendedDecoderIn,2)/word_size+1, 2);
    for n1 = 1:size(trellis_nodes,1)
        for n2 = 1:size(trellis_nodes, 2)
            for n3 = 1:size(trellis_nodes, 3)
                trellis_nodes(n1, n2, n3) = -1;
            end
        end        
    end
    
    %% Decoding
    
    % 1) trellis evaluation
    
    first_iteration = true;
    % for every recived word
    for i_income_word = 1:size(extendedDecoderIn,2)/word_size
        income_word = [extendedDecoderIn(1, word_size*i_income_word-1) extendedDecoderIn(1, word_size*i_income_word)];
        
        % for every state in the state machine...
        for i_each_state = 1:number_states
            
            % ... get the node's information (distance, src_node, tar_node) 
            trellis_node = trellis_nodes(i_each_state, i_income_word);
            trellis_node_distance = trellis_node(1);
            
            % if the state's node is still alive, but not in the first iteration
            if not(trellis_node == -1) || first_iteration
                
                src_node = i_each_state;
                
                % for every possible transition from node in the state machine...
                for i_possible_tar_node = 1:size(STATES_ADJACENCY{src_node},2)
                    
                    tar_node_string = STATES_ADJACENCY{src_node}{i_possible_tar_node};
                    % get the state machine output for calculations
                    with_output = STATES_OUTPUT{src_node}{i_possible_tar_node};
                    
                    % search for the real index of this node; in state
                    % machine not every transitions is possible, and the
                    % real index of it is needed for saving the path
                    real_tar_node = -1;
                    for j_each_state = 1:number_states
                        if strcmp(STATES{j_each_state},tar_node_string)
                            real_tar_node = j_each_state;
                        end
                    end
                    
                    % ...search in every target state in trellis...
                    for k_each_state = 1:number_states
                        
                        each_tar_node = STATES{k_each_state};
                        
                        % ...check if it is the possible one
                        if strcmp(tar_node_string, each_tar_node)
                            
                            % This code is reached when the transition in
                            % trellis is possible from 'src_node' to 
                            % 'real_tar_node', with weight 'with_output'
                            
                            % Thus, its distance with the incoming word
                            % must be calculated and if it is the minimum
                            % path transition must be decided
                            
                            % Do the metric; for each bit of the symbol
                            with_output_array = zeros(1, word_size);
                            for i_each_bit = 1:word_size
                                with_output_array(i_each_bit) = str2double(with_output(i_each_bit));
                            end
                            distance = softDistance(income_word, with_output_array);
                            
                            % acumulate distances if the node is alive
                            if trellis_node(1) >= 0
                                distance = distance + trellis_node_distance;
                            end
                                
                            % check if the 'tar_node' in next columns in trellis is empty/not alive...
                            
                            if trellis_nodes(real_tar_node, i_income_word+1) == -1
                                
                                % save the (distance, src_node, tar_node) as the node's weight,
                                trellis_nodes(real_tar_node, i_income_word+1, 1) = distance;
                                trellis_nodes(real_tar_node, i_income_word+1, 2) = src_node;
                                
                            else 
                                
                                % ... but if not, decide min{distance}[(distance, src_node, tar_node)]
                                trellis_tar_node_distance = trellis_nodes(real_tar_node, i_income_word+1, 1);
                                if  distance < trellis_tar_node_distance
                                    trellis_nodes(real_tar_node, i_income_word+1, 1) = distance;
                                    trellis_nodes(real_tar_node, i_income_word+1, 2) = src_node;
                                end
                                if  distance == trellis_tar_node_distance
                                    r = randn();
                                    if r > 0
                                        trellis_nodes(real_tar_node, i_income_word+1, 2) = src_node;
                                    end
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
            % start in rest; only evaluate the first state
            if first_iteration
                break;
            end
            
        end
        
        first_iteration = false;
    end
    
    % 2) path finding
    
    % find the final state with less accumulated distance
    min_distance = realmax;
    min_distance_tar_node = -1;
    for i_each_state = 1:number_states
        % last column in trellis is extendedDecoderIn,2)/2+1
        each_tar_node_distance = trellis_nodes(i_each_state,size(extendedDecoderIn,2)/2+1, 1);
        if each_tar_node_distance < min_distance
            min_distance = each_tar_node_distance;
            min_distance_tar_node = i_each_state;
        end
    end
    
    % for every column in trellis, starting from the back
    first_iteration = true;
    input_inverse_secuence = zeros(1, size(extendedDecoderIn,2)/word_size-1);
    src_node = -1;
    tar_node = -1;
    for i_path_node = size(extendedDecoderIn,2)/word_size-1:-1:1
        
        % The decoder must now decide the minimum distance path and,
        % for each transition decide what was the input
        % The transition is from 'src_node' and 'tar_node', where
        % 'src_node' is stored and 'tar node' is the previus 'src_node'
        
        if first_iteration
            
            % retrieve first iteration bits
            % the target node is the one stored; in first iteration is the
            % minimum distance one.
            tar_node = STATES(min_distance_tar_node, 1);
            tar_node_string = tar_node{1};
            % the source node is the one stored
            src_node = trellis_nodes(min_distance_tar_node,i_path_node,2);
            % save the src_node for the next iteration and get the new one
            tar_node = src_node;
            
            i_transition_input = -1;
            % for each possible target node reachable from the source node
            src_node_possibles_tar_node = STATES_ADJACENCY{src_node};
            for i_src_node_possibles_tar_node = 1:size(src_node_possibles_tar_node,2)
                
                src_node_possibles_tar_node_string = src_node_possibles_tar_node{i_src_node_possibles_tar_node};
                % compare with the target node
                if strcmp(src_node_possibles_tar_node_string, tar_node_string)
                    i_transition_input = i_src_node_possibles_tar_node;
                end
                
            end
                
            % get the input
            input_string = STATES_INPUT{src_node}{i_transition_input};
            input = str2double(input_string);
            
            % save it
            input_inverse_secuence(i_path_node) = input;
            
        else
            
            % retrieve first iteration bits
            % the target node is the one stored; in first iteration is the
            % minimum distance one.
            
            each_tar_node = STATES(tar_node, 1);
            each_tar_node_string = each_tar_node{1};
            % the source node is the one stored, except for the first column
            if i_path_node > 1
                src_node = trellis_nodes(tar_node,i_path_node,2);
            else
                src_node = 1;
            end
            % save the src_node for the next iteration and get the new one
            tar_node = src_node;
            
            i_transition_input = -1;
            % for each possible target node reachable from the source node
            src_node_possibles_tar_node = STATES_ADJACENCY{src_node};
            for i_src_node_possibles_tar_node = 1:size(src_node_possibles_tar_node,2)
            
                src_node_possibles_tar_node_string = src_node_possibles_tar_node{i_src_node_possibles_tar_node};
                % compare with the target node
                if strcmp(src_node_possibles_tar_node_string, each_tar_node_string)
                    i_transition_input = i_src_node_possibles_tar_node;
                end
                
            end
            
            % get the input
            input_string = STATES_INPUT{src_node}{i_transition_input};
            input = str2double(input_string);
            
            % save it
            input_inverse_secuence(i_path_node) = input;
            
        end
            
        first_iteration = false;
        
    end
    
    %% Post-treatment
    fprintf('[CONV] The size of extendedDecoderIn is %.2f \n', size(extendedDecoderIn, 2));
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



