library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Entidade principal
ENTITY BatalhaNaval IS
    PORT(

---------------------------------------------------------

        -- BOTÕES
        -- Reset: 0
        -- Clock: 3

        key : IN STD_LOGIC_VECTOR(3 downto 0);

--------------------------------------------------------

        -- ALAVANCAS
        -- Barco: (9 - 7)   [Número do barco a ser inserido, sendo [1,0,0] = barco1, [0,1,0] = barco2, [0,0,1] = barco3]
        -- Codificação do Barco Inserido: (6 - 3) [Modo de Jogo: 0]     
        -- Escolha do Jogador: (6 - 3) [Modo de Jogo: 1]
        -- Orientação: 2    [Orientacao do barco 3, 0 = HORIZONTAL, 1 = VERTICAL]
        -- Modo de Jogo: 0  [Modo atual. 0 = Inserir barcos, 1 = Modo de jogo]

        sw : IN STD_LOGIC_VECTOR(9 downto 0);

-------------------------------------------------------

        -- LEDS VERDES
        -- Acertou: 7
        -- Errou: 6
        ledg : OUT STD_LOGIC_VECTOR(7 downto 0);

-------------------------------------------------------

        -- LEDS VERMELHOS
        -- Input Inválido: 9
        ledr : OUT STD_LOGIC_VECTOR(9 downto 0);

-------------------------------------------------------

        -- Zero: "0111111"
        -- Um: "1111001"
        -- Dois: "0100100"
        -- Três: "0110000"
        -- Quatro: "0011001"
        -- Cinco: "0010010"
        -- Seis: "0000010"

        -- hex0 ESQUERDA
        hex3: OUT STD_LOGIC_VECTOR(6 downto 0);    -- "C" 

		  hex2: OUT STD_LOGIC_VECTOR(6 downto 0);    -- Exibe a quantidade de jogadas restantes
		  hex1: OUT STD_LOGIC_VECTOR(6 downto 0);    -- "A"
		  
        -- hex0 DIREITA
        hex0: OUT STD_LOGIC_VECTOR(6 downto 0)    --Exibe a quantidade de acertos necessários

-------------------------------------------------------

    );
END BatalhaNaval;


-- Cria tabuleiro
ARCHITECTURE Behavior_Tabuleiro OF BatalhaNaval IS 

--                                  indices da matriz (3 em inteiro)               Conteudo do indice (vetor de 4 bits)
   TYPE matriz_tabuleiro IS ARRAY (natural range 0 to 3, natural range 0 to 3) of std_logic_vector(3 downto 0);
   SIGNAL matriz : matriz_tabuleiro;
	SIGNAL input_usuario: STD_LOGIC_VECTOR(3 downto 0);

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
 
	--Liga as entradas ao sinal 
	input_usuario(0) <= sw(3);
	input_usuario(1) <= sw(4);
	input_usuario(2) <= sw(5);
	input_usuario(3) <= sw(6);

   PROCESS (key(3), key(0))    -- Clock e Reset

   --Para salvar a codificacao das posicoes escolhidas
	variable pos1 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
	variable pos2: STD_LOGIC_VECTOR(3 downto 0) := "0000";
	variable pos3 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
	variable pos4: STD_LOGIC_VECTOR(3 downto 0) := "0000";

   --Para salvar quais posicoes ja foram acertadas
   variable acertos: STD_LOGIC_VECTOR(3 downto 0) := "0000";

   --Serve para separar o dado de entrada
   variable linhaVet: std_logic_vector(1 downto 0);
   variable colunaVet: std_logic_vector(1 downto 0);

   --Armazena a linha e coluna disparada
   variable linha : integer;
   variable coluna : integer;

   --Armazena a quantidade de jogadas restantes
   variable jogadas : integer range -1 to 6;
	
   --Armazena a quantidade de acertos necessários
   variable acertos_necessarios : integer range 0 to 4;
	
	--Verifica se é possivel jogar com as posições atuais
	variable verifica_posicoes : STD_LOGIC := '1';

    BEGIN

    -- Reinicia o jogo, caso o reset seja pressionado ou as jogadas acabem ou acerte todos os pontos
    IF (key(0) = '0') or (jogadas = -1)then
        ledr <= "0000000000";
        ledg <= "00000000";     -- Acertou  
	    hex3 <= "1100000";
        hex2 <= "0000010";     -- hex3
		hex1 <= "0001000";
        hex0 <= "0011001";     -- hex2
        acertos := "0000";
        pos1 := "0000";
        pos2 := "0000";
        pos3 := "0000";
        pos4 := "0000";
        jogadas := 6;
        acertos_necessarios := 4;
		verifica_posicoes := '1';

    -- Executa com o clock
    ELSIF (key(3)'EVENT AND key(3) = '0') then

        -- Reset das saídas
        ledr(0) <= '0';
        ledg(7) <= '0';
        ledr(9) <= '0';
		
        -- Codificacao para o modo 0, inserir barcos
        IF (sw(0) = '0') then

            -- Impede que sejam inseridos barcos em posições ja ocupadas
            IF (pos1 = input_usuario) or (pos2 = input_usuario) or (pos3 = input_usuario) or (pos4 = input_usuario) then
                ledr(9) <= '1';   -- Input Inválido

            -- Codificacao para o barco 1
            ELSIF (sw(9) = '1') and (sw(8) = '0') and (sw(7) = '0') then
                --Atribui diretamente à variavel
                pos1 := input_usuario;

            -- Codificacao para o barco 2
            ELSIF (sw(9) = '0') and (sw(8) = '1') and (sw(7) = '0') then

                --Atribui diretamente à variavel
                pos2 := input_usuario;

            -- Codificacao para o barco 3
            ELSIF (sw(9) = '0') and (sw(8) = '0') and (sw(7) = '1') then
                --Codificacao para barco horizontal
                IF sw(2) = '0' then

                    -- Verifica se a posicao e valida
                    IF (sw(6) = '0' and sw(5) = '0' and sw(4) = '1' and sw(3) = '1')or (sw(6) = '1' and sw(5) = '0' and sw(4) = '1' and sw(3) = '1') or (sw(6) = '0' and sw(5) = '0' and sw(4) = '1' and sw(3) = '0') or (sw(6) = '1' and sw(5) = '1' and sw(4) = '0' and sw(3) = '0') then
                        ledr(9) <= '1';
                    else
                        --Atribui diretamente a variavel
                        pos3 := input_usuario;

                        --Encontra a pos4
                        IF input_usuario = matriz(0,0) then
                            pos4 := matriz(0,1);
                        ELSIF input_usuario = matriz(0,1) then
                            pos4 := matriz(0,2);
                        ELSIF input_usuario = matriz(0,2) then
                            pos4 := matriz(0,3);
                        ELSIF input_usuario = matriz(1,0) then
                            pos4 := matriz(1,1);
                        ELSIF input_usuario = matriz(1,1) then
                            pos4 := matriz(1,2);
                        ELSIF input_usuario = matriz(1,2) then
                            pos4 := matriz(1,3);
                        ELSIF input_usuario = matriz(2,0) then
                            pos4 := matriz(2,1);
                        ELSIF input_usuario = matriz(2,1) then
                            pos4 := matriz(2,2);
                        ELSIF input_usuario = matriz(2,2) then
                            pos4 := matriz(2,3);
                        ELSIF input_usuario = matriz(3,0) then
                            pos4 := matriz(3,1);
                        ELSIF input_usuario = matriz(3,1) then
                            pos4 := matriz(3,2);
                        ELSIF input_usuario = matriz(3,2) then
                            pos4 := matriz(3,3);
                        END IF;

                    END IF;
                --Codificacao para barco vertical
                else
                    -- Verifica se a posicao e valida
                    IF (sw(6) = '0' and sw(5) = '1' and sw(4) = '0' and sw(3) = '1') or (sw(6) = '1' and sw(5) = '1' and sw(4) = '1' and sw(3) = '1') or (sw(6) = '1' and sw(5) = '0' and sw(4) = '1' and sw(3) = '0') or (sw(6) = '1' and sw(5) = '1' and sw(4) = '0' and sw(3) = '0') then
                        ledr(9) <= '1';
                    else
                        --Atribui diretamente a variavel
                        pos3 := input_usuario;

                        --Encontra a pos4
                        IF input_usuario = matriz(0,0) then
                            pos4 := matriz(1,0);
                        ELSIF input_usuario = matriz(1,0) then
                            pos4 := matriz(2,0);
                        ELSIF input_usuario = matriz(2,0) then
                            pos4 := matriz(3,0);
                        ELSIF input_usuario = matriz(0,1) then
                            pos4 := matriz(1,1);
                        ELSIF input_usuario = matriz(1,1) then
                            pos4 := matriz(2,1);
                        ELSIF input_usuario = matriz(2,1) then
                            pos4 := matriz(3,1);
                        ELSIF input_usuario = matriz(0,2) then
                            pos4 := matriz(1,2);
                        ELSIF input_usuario = matriz(1,2) then
                            pos4 := matriz(2,2);
                        ELSIF input_usuario = matriz(2,2) then
                            pos4 := matriz(3,2);
                        ELSIF input_usuario = matriz(0,3) then
                            pos4 := matriz(1,3);
                        ELSIF input_usuario = matriz(1,3) then
                            pos4 := matriz(2,3);
                        ELSIF input_usuario = matriz(2,3) then
                            pos4 := matriz(3,3);
                        END IF;
                    END IF;
                END IF;


            END IF; --BARCOS


        -- Codificacao para o modo 1, modo de jogo
        ELSIF (sw(0) = '1' and verifica_posicoes = '0') then
            -- Converte a escolha para dois inteiros (porque esta invertido? porque Deus quis assim)
            colunaVet(0) := sw(3);
            colunaVet(1) := sw(4);
            linhaVet(0) := sw(5);
            linhaVet(1) := sw(6);
            linha := to_integer((unsigned(linhaVet)));
            coluna := to_integer((unsigned(colunaVet)));
            
            --Verifica se acertou ou errou e faz as alterações devidas
            IF (matriz(linha, coluna) = pos1 and acertos(0) = '0') then
                ledg(7) <= '1';
                acertos(0) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSIF (matriz(linha, coluna) = pos2 and acertos(1) = '0') then
                ledg(7)  <= '1';
                acertos(1) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSIF (matriz(linha, coluna) = pos3 and acertos(2) = '0') then
                ledg(7)  <= '1';
                acertos(2) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSIF (matriz(linha, coluna) = pos4 and acertos(3) = '0') then
                ledg(7)  <= '1';
                acertos(3) := '1';
                acertos_necessarios := acertos_necessarios - 1;
                IF jogadas > 1 then
                    jogadas := jogadas - 1;
                END IF;
            ELSE 
                ledr(0)  <= '1';    -- Errou
                jogadas := jogadas - 1;
            END IF;

        END IF; --MODO

        -- Atribui saídas ao hex0 de 7 segmentos
        if jogadas = 6 then
            hex2 <= "0000010";
        elsif jogadas = 5 then
            hex2 <= "0010010";
        elsif jogadas = 4 then
            hex2 <= "0011001";
        elsif jogadas = 3 then
            hex2 <= "0110000";
        elsif jogadas = 2 then
            hex2 <= "0100100";
        elsif jogadas = 1 then
            hex2 <= "1111001";
        elsif jogadas = 0 then
            hex2 <= "0111111";
            ledr <= "1111111111";   -- Efeito de derrota  
			ledg <= "00000000";				
        end if;

        if acertos_necessarios = 4 then
            hex0 <= "0011001";
        elsif acertos_necessarios = 3 then
            hex0 <= "0110000";
        elsif acertos_necessarios = 2 then
            hex0 <= "0100100";
        elsif acertos_necessarios = 1 then
            hex0 <= "1111001";
        elsif acertos_necessarios = 0 then
            hex0 <= "0111111";
            ledg <= "11111111";
				ledr <= "0000000000";				-- Efeito de vitória
				verifica_posicoes := '1';
        end if;

        --Verifica se as posições inseridas são válidas. Como o valor pos padrao é "0000" e é impossível inserir posições duplicadas, se utiliza disso para verificar.
		if (pos1 = "0000") then
            if (pos2 /= "0000") and (pos3 /= "0000") and (pos4 /= "0000") then
                verifica_posicoes := '0';
            end if;
		elsif (pos2 = "0000") then
            if (pos1 /= "0000") and (pos3 /= "0000") and (pos4 /= "0000") then
                verifica_posicoes := '0';
            end if;
		elsif (pos3 = "0000") then
            if (pos2 /= "0000") and (pos1 /= "0000") and (pos4 /= "0000") then
                verifica_posicoes := '0';
            end if;
		elsif (pos4 = "0000") then
            if (pos2 /= "0000") and (pos3 /= "0000") and (pos1 /= "0000") then
                verifica_posicoes := '0';
            end if;
        else
            verifica_posicoes := '0';
        end if;

    END IF; --CLOCK
	 
	 --Exibe se é possível jogar ou não
	 ledr(8) <= verifica_posicoes;
	 
    END PROCESS;
END Behavior_Tabuleiro;
