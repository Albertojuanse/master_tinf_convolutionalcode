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
    
    STATES =           ['00';'01';'10';'11'];
    STATES_ADJACENCY = ['00','10';'00','10';'01','11';'01','11'];
    STATES_OUTPUT =    ['00','11';'11','00';'10','01';'01','10'];
    STATES_INPUT =     ['01';'01';'01';'01'];
        
    % Collections for saving the acumulated path cost; trellis diagram
    trellis_states = STATES(1,:);
    trellis_adjacency = STATES_ADJACENCY(1,:);
    trellis_output = STATES_OUTPUT(1,:);
    trellis_input = STATES_INPUT(1,:);
    
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
        current_trellis_states = trellis_states(i_input);
        current_trellis_adjacency = trellis_adjacency(i_input);
        current_trellis_output = trellis_output(i_input);
        current_trellis_input = trellis_input(i_input);
        
        % Get the possible transitions from each node
        possible_transitions = [];
        for i_node = 1:2:size(current_trellis_states,1)
            
            current_node_first = current_trellis_states(i_node);
            current_node_second = current_trellis_states(i_node + 1);
            current_node = [current_node_first current_node_second];         
            
            for i_next_node = 1:2:size(current_trellis_adjacency,1)
            
                current_next_node_first = current_trellis_adjacency(i_next_node);
                current_next_node_second = current_trellis_adjacency(i_next_node + 1);
                current_next_node = [current_next_node_first current_next_node_second];
                current_transition = [current_node current_next_node];
                possible_transitions(end+1,:) = current_transition;
                
            end
            
        end
        
        % States that in the next trellis column will have input edges
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



