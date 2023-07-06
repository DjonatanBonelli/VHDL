library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--3 clocks para iniciar
--cada bit é um andar (0001 = primeiro andar; 1000 = quarto andar)...

ENTITY teste IS
    PORT (KEY : IN STD_LOGIC_VECTOR(3 downto 0);	--Clock, reset
    SW : IN STD_LOGIC_VECTOR(9 downto 0); --Escolha_andar
    LEDR: OUT STD_LOGIC_VECTOR(9 downto 0); --Subir, Descer, Parar
    LEDG: OUT STD_LOGIC_VECTOR(7 downto 0)); --Sensor_andar
END teste;

ARCHITECTURE Behavior OF teste IS
    TYPE estado_elevador IS (subindo, descendo, parado);
    SIGNAL estado_atual: estado_elevador;
	 SIGNAL s_sensor_andar: std_logic_vector(3 downto 0);
	 
BEGIN

	PROCESS (sw(9), KEY(3))
	variable int_sensor : integer;
	variable int_escolha: integer; 
	
begin
        if sw(9) = '1' then   --reset
            s_sensor_andar <= "0000";      --terreo
				estado_atual <= parado;
				LEDG(0) <= s_sensor_andar(0);
				LEDG(1) <= s_sensor_andar(1);
				LEDG(2) <= s_sensor_andar(2);
				LEDG(3) <= s_sensor_andar(3);
				
        elsif key(3)'event and KEY(3) = '1' then --clock
			 int_sensor := to_integer((unsigned(s_sensor_andar)));
			 int_escolha := to_integer((unsigned(SW)));

			 case Estado_atual is
			
				  when Parado =>
						if int_sensor = int_escolha then --se estiver no andar certo: parado
							 estado_atual <= parado;
						else
							 if int_sensor > 8 then      --passou o limite
								  estado_atual <= parado;
							 elsif int_sensor < int_escolha then    --se estiver no andar inferior a escolha: subindo
								  estado_atual <= subindo;
							 elsif int_sensor > int_escolha then       --se estiver no andar superior a escolha: descendo
								  estado_atual <= descendo;
							 END IF;
						END IF;

				  when Subindo =>
						if int_sensor = int_escolha then --se estiver no andar certo: parado
							 estado_atual <= parado;
						else
							if s_sensor_andar = "0000" then
								 s_sensor_andar <= "0001";
							elsif int_sensor >= 8 then
								 estado_atual <= parado;
							else
								s_sensor_andar <= std_logic_vector(shift_left(unsigned(s_sensor_andar), 1));-- desloca bits a esquerda
							END IF;
						end if;

				  when Descendo =>
						if int_sensor = int_escolha then --se estiver no andar certo: parado
							 estado_atual <= parado;
						else		  
							 if int_sensor > 8 then
								s_sensor_andar <= "1000";
							 elsif s_sensor_andar = "0000" then
								estado_atual <= parado;
							 else
								s_sensor_andar <= std_logic_vector(shift_right(unsigned(s_sensor_andar), 1));-- desloca bits a direita
							 END IF;
						end if;
						
				  END CASE;
				  -- atribui saidas
				  
						LEDG(0) <= s_sensor_andar(0);
						LEDG(1) <= s_sensor_andar(1);
						LEDG(2) <= s_sensor_andar(2);
						LEDG(3) <= s_sensor_andar(3);
						
						if estado_atual = subindo then
							LEDR(2) <= '1';
						else
							LEDR(2) <= '0';
						end if;
						
						if	estado_atual = descendo then
							LEDR(0) <= '1';
						else
							LEDR(0) <= '0';
						end if;
						
						if estado_atual = parado then
							LEDR(1) <= '1';
						else
							LEDR(1) <= '0';
						end if;

        END IF;
		  
	END PROCESS;
        
END Behavior;
