library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--reset precisa estar ativo o tempo todo para funcionar adequadamente
--cada bit é um andar (0001 = primeiro andar; 1000 = quarto andar)

ENTITY elevador IS
    PORT (Clock, Reset : IN STD_LOGIC;
    Escolha_andar : IN STD_LOGIC_VECTOR(3 downto 0);
    Subir, Descer : OUT STD_LOGIC; 
    Sensor_andar: OUT STD_LOGIC_VECTOR(3 downto 0));
END elevador;

ARCHITECTURE Behavior OF elevador IS
    TYPE estado_elevador IS (subindo, descendo, parado);
    SIGNAL estado_atual, proximo_estado : estado_elevador;
BEGIN
    PROCESS (Reset, Clock)
	variable s_sensor_andar: std_logic_vector(3 downto 0);
begin
        if Reset = '1' then
            s_sensor_andar := "0000";      --terreo
            Estado_atual <= parado;     --parado
        END IF;

        if clock'event and clock = '1' then
	        estado_atual <= proximo_estado;    

        END IF;
    END PROCESS;

    PROCESS (Estado_atual, Proximo_estado, escolha_andar)
        variable int_sensor : integer;
        variable int_escolha: integer;   
        variable s_sensor_andar : std_logic_vector(3 downto 0);
begin
    int_sensor := to_integer((unsigned(s_sensor_andar)));
    int_escolha := to_integer((unsigned(escolha_andar)));

    case Estado_atual is

        when Parado =>   
            if int_sensor = int_escolha then --se estiver no andar certo: parado
                Proximo_estado <= parado;
            else
                if int_sensor > 8 then      --estouro de buffer 
                    Proximo_estado <= parado;
                elsif int_sensor < int_escolha then    --se estiver no andar inferior a escolha: subindo
                    Proximo_estado <= subindo;
                else       --se estiver no andar superior a escolha: descendo
                    Proximo_estado <= descendo;   
                END IF;
            END IF;

        when Subindo =>

        --tratamentos gerais
            if s_sensor_andar = "0000" then
                s_sensor_andar := "0001";
            elsif int_escolha > 8 then
                s_sensor_andar := "1000";
            else
                s_sensor_andar := std_logic_vector(shift_left(unsigned(s_sensor_andar), 1));     -- desloca bits a esquerda
            END IF;

        when Descendo =>
	
	    if to_integer(unsigned(s_sensor_andar)) > 8 then
		s_sensor_andar := "1000";
		END IF;
            s_sensor_andar := std_logic_vector(shift_right(unsigned(s_sensor_andar), 1));        -- desloca bits a direita	           

        END CASE;
        -- atribui saidas
	        sensor_andar <= s_sensor_andar; 
            Subir <= '1' when estado_atual = subindo else '0';
            Descer <=  '1' when estado_atual = descendo else '0';
	END PROCESS;
        
END Behavior;