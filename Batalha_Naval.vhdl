library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade principal
ENTITY BN IS
    PORT(
        --Reinicia o jogo
        reset : IN STD_LOGIC;

        --Posicao escolhida pelo jogador para atacar
        escolha_jogador : IN STD_LOGIC_VECTOR(3 downto 0);

        -- Codificacao do barco sendo inserido
        codificacao_barco_inserido : IN STD_LOGIC_VECTOR(3 downto 0); 

        -- Orientacao do barco 3, 0 = HORIZONTAL, 1 = VERTICAL
        orientacao: IN STD_LOGIC;

        -- Número do barco a ser inserido, sendo [1,0,0] = barco1, [0,1,0] = barco2, [0,0,1] = barco3
        barco: IN STD_LOGIC_VECTOR(2 downto 0);

        -- Modo atual. 0 = Inserir barcos, 1 = Modo de jogo
        modo: IN STD_LOGIC;

        clock: IN STD_LOGIC;

        -- Ativa quando um input é inválido
        input_invalido: OUT STD_LOGIC;

        -- Acende caso tenha acertado o alvo
        acertou: OUT STD_LOGIC;

        -- Acende caso tenha errado o alvo
        errou: OUT STD_LOGIC;

        -- Exibe a quantidade de jogadas restantes
        jogadas_restantes: OUT STD_LOGIC_VECTOR(2 downto 0);

        --Exibe a quantidade de acertos necessários
        acertos_restantes: OUT STD_LOGIC_VECTOR(2 downto 0);

        --Saidas de debug (apagar dps)
        posicao1: OUT STD_LOGIC_VECTOR(3 downto 0);
        posicao2: OUT STD_LOGIC_VECTOR(3 downto 0); 
        posicao3: OUT STD_LOGIC_VECTOR(3 downto 0); 
        posicao4: OUT STD_LOGIC_VECTOR(3 downto 0);
        linhaOut: OUT STD_LOGIC_VECTOR(1 downto 0);
        colunaOut: OUT STD_LOGIC_VECTOR(1 downto 0)
    );
END BN;


-- Cria tabuleiro
ARCHITECTURE Behavior_Tabuleiro OF BN IS 

                                    -- indices da matriz (3 em inteiro)            -- Conteudo do indice (vetor de 4 bits)
    TYPE matriz_tabuleiro IS ARRAY (natural range 0 to 3, natural range 0 to 3) of std_logic_vector(3 downto 0);
    SIGNAL matriz : matriz_tabuleiro;   -- Cria matriz

BEGIN

    --Criação da matriz do tabuleiro
    matriz(0, 0) <= "0110";
    matriz(0, 1) <= "1101";
    matriz(0, 2) <= "1000";
    matriz(0, 3) <= "0011";
    matriz(1, 0) <= "0000";
    matriz(1, 1) <= "1001";
    matriz(1, 2) <= "0001";
    matriz(1, 3) <= "1011";
    matriz(2, 0) <= "0111";
    matriz(2, 1) <= "0100";
    matriz(2, 2) <= "1110";
    matriz(2, 3) <= "0010";
    matriz(3, 0) <= "0101";
    matriz(3, 1) <= "1111";
    matriz(3, 2) <= "1010";
    matriz(3, 3) <= "1100";

    PROCESS (clock, reset)

    --Para salvar a codificacao das posicoes escolhidas
	variable pos1 : STD_LOGIC_VECTOR(3 downto 0);
	variable pos2: STD_LOGIC_VECTOR(3 downto 0);
	variable pos3 : STD_LOGIC_VECTOR(3 downto 0);
	variable pos4: STD_LOGIC_VECTOR(3 downto 0);

    --Para salvar quais posicoes ja foram acertadas
    variable acertos: STD_LOGIC_VECTOR(3 downto 0) := "0000";

    --Serve para separar o dado de entrada
    variable linhaVet: std_logic_vector(1 downto 0);
    variable colunaVet: std_logic_vector(1 downto 0);

    --Armazena a linha e coluna disparada
    variable linha : integer;
    variable coluna : integer;

    --Armazena a quantidade de jogadas restantes
    variable jogadas : integer := 6;

    --Armazena a quantidade de acertos necessários
    variable acertos_necessarios : integer := 4;

    BEGIN

    -- Reinicia o jogo, caso o reset seja pressionado ou as jogadas acabem ou acerte todos os pontos
    IF (reset = '1') or (jogadas = 0) or (acertos_necessarios = 0) then
        input_invalido <= '0';
        acertou <= '0';
        errou <= '0';     
        jogadas_restantes <= "000";
        acertos_restantes <= "000";
        acertos := "0000";
        pos1 := "0000";
        pos2 := "0000";
        pos3 := "0000";
        pos4 := "0000";
        jogadas := 6;
        acertos_necessarios := 4;

    -- Executa com o clock
    ELSIF (Clock'EVENT AND Clock = '1') then

        -- Reset das saídas
        input_invalido <= '0';
        acertou <= '0';
        errou <= '0';

        -- Codificacao para o modo 0, inserir barcos
        IF modo = '0' then

            -- Impede que sejam inseridos barcos em posições ja ocupadas
            IF (pos1 = codificacao_barco_inserido) or (pos2 = codificacao_barco_inserido) or (pos3 = codificacao_barco_inserido) or (pos4 = codificacao_barco_inserido) then
                input_invalido <= '1';
            -- Codificacao para o barco 1
            ELSIF barco = "100" then

                --Atribui diretamente à variavel
                pos1 := codificacao_barco_inserido;

            -- Codificacao para o barco 2
            ELSIF barco = "010" then

                --Atribui diretamente à variavel
                pos2 := codificacao_barco_inserido;

            -- Codificacao para o barco 3
            ELSIF barco = "001" then
                --Codificacao para barco horizontal
                IF orientacao = '0' then

                    -- Verifica se a posicao e valida
                    IF (codificacao_barco_inserido = "0011") or (codificacao_barco_inserido = "1011") or (codificacao_barco_inserido = "0010") or (codificacao_barco_inserido = "1100") then
                        input_invalido <= '1';
                    else
                        --Atribui diretamente a variavel
                        pos3 := codificacao_barco_inserido;

                        --Encontra a pos4
                        IF codificacao_barco_inserido = matriz(0,0) then
                            pos4 := matriz(0,1);
                        ELSIF codificacao_barco_inserido = matriz(0,1) then
                            pos4 := matriz(0,2);
                        ELSIF codificacao_barco_inserido = matriz(0,2) then
                            pos4 := matriz(0,3);
                        ELSIF codificacao_barco_inserido = matriz(1,0) then
                            pos4 := matriz(1,1);
                        ELSIF codificacao_barco_inserido = matriz(1,1) then
                            pos4 := matriz(1,2);
                        ELSIF codificacao_barco_inserido = matriz(1,2) then
                            pos4 := matriz(1,3);
                        ELSIF codificacao_barco_inserido = matriz(2,0) then
                            pos4 := matriz(2,1);
                        ELSIF codificacao_barco_inserido = matriz(2,1) then
                            pos4 := matriz(2,2);
                        ELSIF codificacao_barco_inserido = matriz(2,2) then
                            pos4 := matriz(2,3);
                        ELSIF codificacao_barco_inserido = matriz(3,0) then
                            pos4 := matriz(3,1);
                        ELSIF codificacao_barco_inserido = matriz(3,1) then
                            pos4 := matriz(3,2);
                        ELSIF codificacao_barco_inserido = matriz(3,2) then
                            pos4 := matriz(3,3);
                        END IF;

                    END IF;
                --Codificacao para barco vertical
                else
                    -- Verifica se a posicao e valida
                    IF (codificacao_barco_inserido = "0101") or (codificacao_barco_inserido = "1111") or (codificacao_barco_inserido = "1010") or (codificacao_barco_inserido = "1100") then
                        input_invalido <= '1';
                    else
                        --Atribui diretamente a variavel
                        pos3 := codificacao_barco_inserido;

                        --Encontra a pos4
                        IF codificacao_barco_inserido = matriz(0,0) then
                            pos4 := matriz(1,0);
                        ELSIF codificacao_barco_inserido = matriz(1,0) then
                            pos4 := matriz(2,0);
                        ELSIF codificacao_barco_inserido = matriz(2,0) then
                            pos4 := matriz(3,0);
                        ELSIF codificacao_barco_inserido = matriz(0,1) then
                            pos4 := matriz(1,1);
                        ELSIF codificacao_barco_inserido = matriz(1,1) then
                            pos4 := matriz(2,1);
                        ELSIF codificacao_barco_inserido = matriz(2,1) then
                            pos4 := matriz(3,1);
                        ELSIF codificacao_barco_inserido = matriz(0,2) then
                            pos4 := matriz(1,2);
                        ELSIF codificacao_barco_inserido = matriz(1,2) then
                            pos4 := matriz(2,2);
                        ELSIF codificacao_barco_inserido = matriz(2,2) then
                            pos4 := matriz(3,2);
                        ELSIF codificacao_barco_inserido = matriz(0,3) then
                            pos4 := matriz(1,3);
                        ELSIF codificacao_barco_inserido = matriz(1,3) then
                            pos4 := matriz(2,3);
                        ELSIF codificacao_barco_inserido = matriz(2,3) then
                            pos4 := matriz(3,3);
                        END IF;
                    END IF;
                END IF;


            END IF; --BARCOS


        -- Codificacao para o modo 1, modo de jogo
        else
            -- Converte a escolha para dois inteiros (porque esta invertido? porque Deus quis assim)
            colunaVet(0) := escolha_jogador(0);
            colunaVet(1) := escolha_jogador(1);
            linhaVet(0) := escolha_jogador(2);
            linhaVet(1) := escolha_jogador(3);
            linha := to_integer((unsigned(linhaVet)));
            coluna := to_integer((unsigned(colunaVet)));
            
            --Verifica se acertou ou errou e faz as alterações devidas
            IF (matriz(linha, coluna) = pos1 and acertos(0) = '0') then
                acertou <= '1';
                acertos(0) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSIF (matriz(linha, coluna) = pos2 and acertos(1) = '0') then
                acertou <= '1';
                acertos(1) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSIF (matriz(linha, coluna) = pos3 and acertos(2) = '0') then
                acertou <= '1';
                acertos(2) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSIF (matriz(linha, coluna) = pos4 and acertos(3) = '0') then
                acertou <= '1';
                acertos(3) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSE 
                errou <= '1';
                jogadas := jogadas - 1;
            END IF;

        END IF; --MODO
        
        --Saídas de debug
        posicao1 <= pos1;
        posicao2 <= pos2;
        posicao3 <= pos3;
        posicao4 <= pos4;
        linhaOut <= linhaVet;
        colunaOut <= colunaVet;

        -- Convertendo as variaveis para o tipo STD_LOGIC_VECTOR e atribuindo as saidas
        jogadas_restantes <= std_logic_vector(to_unsigned(jogadas, jogadas_restantes'length));
        acertos_restantes <= std_logic_vector(to_unsigned(acertos_necessarios, acertos_restantes'length));

    END IF; --CLOCK
    END PROCESS;
END Behavior_Tabuleiro;
