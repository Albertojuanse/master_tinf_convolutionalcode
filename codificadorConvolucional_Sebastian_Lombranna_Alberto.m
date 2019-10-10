function coderOut = codificadorConvolucional_Sebastian_Lombranna_Alberto(coderIn)
    %CODIFICADORCONVOLUCIONAL_SEBASTIAN_LOMBRANNA_ALBERTO Convolutional coder
    
    %% Specifications
    
    % The specifications of the coder desing are
    % — that 3 registers or more must be used;
    % — that 2 or more parity bits streams must be used;
    % — that the coder must be in initial rest;
    % — that tail bits must be use; and
    % — that functions must conform the specified interface.
    
    %% Design decisions
    
    % It is decided to use the characteristic polynomial provided by the
    % given documentation, which specifies that the coding schemes
    % — [ (3,(7,5)) , (111, 101) ] and
    % — [ (4,(14,13)) , (1110, 1101) ]
    % perform the best; both are 5-free-distance scheme coding
    % The design process starts when the communication rate is fixed and
    % thus the parity streams r is fixed and a coding scheme is selecting;
    % in this case it is used the provided schemes mentioned below.
    % Those are recursive non sistematic convolutional schemes.
    %
    % About informatic coding, it is decide to iterate over the input and
    % perform both matrix multiplication and registers shifting. Also, it
    % is decided to develop de code as scheme-independant as possible, in
    % order to try different schemes without changing the code.
    %
    % It is used the same number of tail bits than the number of registers.
    %
    % Binary arithmetic must be used; hardcoded if statements to fix it.
    
    %% Run configuration
    WORD_SPACE = [0 1];              % Source word space
    DISTRIBUTION = [0.5 0.5];        % A priori symbol distribution
    k = 3;                           % Number of registers
    G = [1 1; 1 0; 1 1];             % Characteristic polynomial (1 1 1, 1 0 1)
    
    %% Variable declaration and initialization
    K = zeros(1, k);                 % Registers in rest
    number_parity_bits = size(G,2);  % Number of parity bits generated
    TB = zeros(1, k);                % Tail bits
    
    %% Pretreatment
    expandedCoderIn = [coderIn,TB];
    coderOut = zeros(1, 2*size(expandedCoderIn, 2));

    %% State machine set up
    % TO DO: Specification and automatic initialization of this
    % STATES =            {'000';         '001';         '010';         '011';         '100';         '101';         '110';         '111'       };
    % STATES_ADJACENCY = {{'000','100'}, {'000','100'}, {'001','101'}, {'001','101'}, {'010','110'}, {'010','110'}, {'011','111'}, {'011','111'}};
    % STATES_OUTPUT =    {{'00','11'},   {'00','11'},   {'11','00'},   {'11','00'},   {'10','01'},   {'10','01'},   {'01','10'},   {'01','10'}  };
    % STATES_INPUT =     {{'0','1'},     {'0','1'},     {'0','1'},     {'0','1'},     {'0','1'},     {'0','1'},     {'0','1'},     {'0','1'}    };
    state_machine = StateMachine(8);
    state_machine = state_machine.addState(State([0 0 0]));
    state_machine = state_machine.addState(State([0 0 1]));
    state_machine = state_machine.addState(State([0 1 0]));
    state_machine = state_machine.addState(State([0 1 1]));
    state_machine = state_machine.addState(State([1 0 0]));
    state_machine = state_machine.addState(State([1 0 1]));
    state_machine = state_machine.addState(State([1 1 0]));
    state_machine = state_machine.addState(State([1 1 1]));
    
    adjacency_matrix = [1 0 0 0 1 0 0 0;
                        1 0 0 0 1 0 0 0;
                        0 1 0 0 0 1 0 0;
                        0 1 0 0 0 1 0 0;
                        0 0 1 0 0 0 1 0;
                        0 0 1 0 0 0 1 0;
                        0 0 0 1 0 0 0 1;
                        0 0 0 1 0 0 0 1];
    state_machine = state_machine.setAdjacencyMatrix(adjacency_matrix);
    
    i_m_11 =  Word([ 0]);
    i_m_12 =  Word([-1]);
    i_m_13 =  Word([-1]);
    i_m_14 =  Word([-1]);
    i_m_15 =  Word([ 1]);
    i_m_16 =  Word([-1]);
    i_m_17 =  Word([-1]);
    i_m_18 =  Word([-1]);
    
    i_m_21 =  Word([ 0]);
    i_m_22 =  Word([-1]);
    i_m_23 =  Word([-1]);
    i_m_24 =  Word([-1]);
    i_m_25 =  Word([ 1]);
    i_m_26 =  Word([-1]);
    i_m_27 =  Word([-1]);
    i_m_28 =  Word([-1]);
    
    i_m_31 =  Word([-1]);
    i_m_32 =  Word([ 0]);
    i_m_33 =  Word([-1]);
    i_m_34 =  Word([-1]);
    i_m_35 =  Word([-1]);
    i_m_36 =  Word([ 1]);
    i_m_37 =  Word([-1]);
    i_m_38 =  Word([-1]);
    
    i_m_41 =  Word([-1]);
    i_m_42 =  Word([ 0]);
    i_m_43 =  Word([-1]);
    i_m_44 =  Word([-1]);
    i_m_45 =  Word([-1]);
    i_m_46 =  Word([ 1]);
    i_m_47 =  Word([-1]);
    i_m_48 =  Word([-1]);
    
    i_m_51 =  Word([-1]);
    i_m_52 =  Word([-1]);
    i_m_53 =  Word([ 0]);
    i_m_54 =  Word([-1]);
    i_m_55 =  Word([-1]);
    i_m_56 =  Word([-1]);
    i_m_57 =  Word([ 1]);
    i_m_58 =  Word([-1]);
    
    i_m_51 =  Word([-1]);
    i_m_62 =  Word([-1]);
    i_m_63 =  Word([ 0]);
    i_m_64 =  Word([-1]);
    i_m_65 =  Word([-1]);
    i_m_66 =  Word([-1]);
    i_m_67 =  Word([ 1]);
    i_m_68 =  Word([-1]);
    
    i_m_71 =  Word([-1]);
    i_m_72 =  Word([-1]);
    i_m_73 =  Word([-1]);
    i_m_74 =  Word([ 0]);
    i_m_75 =  Word([-1]);
    i_m_76 =  Word([-1]);
    i_m_77 =  Word([-1]);
    i_m_78 =  Word([ 1]);
    
    i_m_81 =  Word([-1]);
    i_m_82 =  Word([-1]);
    i_m_83 =  Word([-1]);
    i_m_84 =  Word([ 0]);
    i_m_85 =  Word([-1]);
    i_m_86 =  Word([-1]);
    i_m_87 =  Word([-1]);
    i_m_88 =  Word([ 1]);
    input_matrix = [i_m_11 i_m_12 i_m_13 i_m_14 i_m_15 i_m_16 i_m_17 i_m_18;
                    i_m_21 i_m_22 i_m_23 i_m_24 i_m_25 i_m_26 i_m_27 i_m_28;
                    i_m_31 i_m_32 i_m_33 i_m_34 i_m_35 i_m_36 i_m_37 i_m_38;
                    i_m_41 i_m_42 i_m_43 i_m_44 i_m_45 i_m_46 i_m_47 i_m_48;
                    i_m_51 i_m_52 i_m_53 i_m_54 i_m_55 i_m_56 i_m_57 i_m_58;
                    i_m_61 i_m_62 i_m_63 i_m_64 i_m_65 i_m_66 i_m_67 i_m_68;
                    i_m_71 i_m_72 i_m_73 i_m_74 i_m_75 i_m_76 i_m_77 i_m_78;
                    i_m_81 i_m_82 i_m_83 i_m_84 i_m_85 i_m_86 i_m_87 i_m_88;
                    ];
    state_machine = state_machine.addInputMatrix(input_matrix);
    
    o_m_11 =  Word([0 0]);
    o_m_12 =  Word([ -1]);
    o_m_13 =  Word([ -1]);
    o_m_14 =  Word([ -1]);
    o_m_15 =  Word([1 1]);
    o_m_16 =  Word([ -1]);
    o_m_17 =  Word([ -1]);
    o_m_18 =  Word([ -1]);
    
    o_m_21 =  Word([0 0]);
    o_m_22 =  Word([ -1]);
    o_m_23 =  Word([ -1]);
    o_m_24 =  Word([ -1]);
    o_m_25 =  Word([1 1]);
    o_m_26 =  Word([ -1]);
    o_m_27 =  Word([ -1]);
    o_m_28 =  Word([ -1]);
    
    o_m_31 =  Word([ -1]);
    o_m_32 =  Word([1 1]);
    o_m_33 =  Word([ -1]);
    o_m_34 =  Word([ -1]);
    o_m_35 =  Word([ -1]);
    o_m_36 =  Word([0 0]);
    o_m_37 =  Word([ -1]);
    o_m_38 =  Word([ -1]);
    
    o_m_41 =  Word([ -1]);
    o_m_42 =  Word([1 1]);
    o_m_43 =  Word([ -1]);
    o_m_44 =  Word([ -1]);
    o_m_45 =  Word([ -1]);
    o_m_46 =  Word([0 0]);
    o_m_47 =  Word([ -1]);
    o_m_48 =  Word([ -1]);
    
    o_m_51 =  Word([ -1]);
    o_m_52 =  Word([ -1]);
    o_m_53 =  Word([1 0]);
    o_m_54 =  Word([ -1]);
    o_m_55 =  Word([ -1]);
    o_m_56 =  Word([ -1]);
    o_m_57 =  Word([0 1]);
    o_m_58 =  Word([ -1]);
    
    o_m_51 =  Word([ -1]);
    o_m_62 =  Word([ -1]);
    o_m_63 =  Word([1 0]);
    o_m_64 =  Word([ -1]);
    o_m_65 =  Word([ -1]);
    o_m_66 =  Word([ -1]);
    o_m_67 =  Word([0 1]);
    o_m_68 =  Word([ -1]);
    
    o_m_71 =  Word([ -1]);
    o_m_72 =  Word([ -1]);
    o_m_73 =  Word([ -1]);
    o_m_74 =  Word([0 1]);
    o_m_75 =  Word([ -1]);
    o_m_76 =  Word([ -1]);
    o_m_77 =  Word([ -1]);
    o_m_78 =  Word([1 0]);
    
    o_m_81 =  Word([ -1]);
    o_m_82 =  Word([ -1]);
    o_m_83 =  Word([ -1]);
    o_m_84 =  Word([0 1]);
    o_m_85 =  Word([ -1]);
    o_m_86 =  Word([ -1]);
    o_m_87 =  Word([ -1]);
    o_m_88 =  Word([1 0]);
    output_matrix = [o_m_11 o_m_12 o_m_13 o_m_14 o_m_15 o_m_16 o_m_17 o_m_18;
                     o_m_21 o_m_22 o_m_23 o_m_24 o_m_25 o_m_26 o_m_27 o_m_28;
                     o_m_31 o_m_32 o_m_33 o_m_34 o_m_35 o_m_36 o_m_37 o_m_38;
                     o_m_41 o_m_42 o_m_43 o_m_44 o_m_45 o_m_46 o_m_47 o_m_48;
                     o_m_51 o_m_52 o_m_53 o_m_54 o_m_55 o_m_56 o_m_57 o_m_58;
                     o_m_61 o_m_62 o_m_63 o_m_64 o_m_65 o_m_66 o_m_67 o_m_68;
                     o_m_71 o_m_72 o_m_73 o_m_74 o_m_75 o_m_76 o_m_77 o_m_78;
                     o_m_81 o_m_82 o_m_83 o_m_84 o_m_85 o_m_86 o_m_87 o_m_88;
                     ];
    state_machine = state_machine.addOutputMatrix(output_matrix);
    
    state_machine = state_machine.resetMachine();
    
    %% Coding
    
    % for every input, run the state machine
    for input = expandedCoderIn
        
        output = state_machine.runMachineWithInput(x);
            
        coderOut(1, end+1) = output(1, 1);
        coderOut(1, end+2) = output(1, 1);
        
    end
end
