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
    % The code can be punctured; <-
    %
    % Binary arithmetic must be used; hardcoded if statements to fix it.
    
    %% Variable declaration and initialization
    ALPHABET = [0 1];          % Source alphabet
    DISTRIBUTION = [0.5 0.5];  % A priori symbol distribution
    k = 3;                     % Number of registers
    K = zeros(1, k);           % Registers in rest
    G = [1 1; 1 0; 1 1];       % Characteristic polynomial (1 1 1, 1 0 1)
    TB = zeros(1, k);          % Tail bits
    
    %% Pretreatment
    expandedCoderIn = [coderIn,TB];
    coderOut = zeros(1, 2*size(expandedCoderIn, 2));

    %% Coding
    outIndex = 1;
    for x = expandedCoderIn
        
        % 1) Run registers
        for regIndex = k:-1:1             
            % If it is the first register, load the fresh bit...
            if regIndex == 1
                K(1, regIndex) = x;
            % ...but if not, shift them.
            else
                K(1, regIndex) = K(1, regIndex - 1);
            end
        end
        
        % 2) and generate the codeword and save it.     
        Y = K*G;
        for codeWordIndex = 1:size(Y,2)
            
            % 2.1) Decimal to binary arithmetic
            Y(1, codeWordIndex) = mod(Y(1, codeWordIndex),2);
            
            coderOut(1, outIndex) = Y(1, codeWordIndex);
            outIndex = outIndex + 1;
        end
        
    end
end

