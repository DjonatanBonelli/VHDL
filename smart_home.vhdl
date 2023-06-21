library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Casa is
  port (
    -- Sensores das janelas e da porta
    janela1: in std_logic;
    janela2: in std_logic;
    janela3: in std_logic;
    porta: in std_logic;
    portaTrancada: in std_logic;
    
    -- Botão do modo seguro
    modoSeguro: in  std_logic;
    
    -- Sensores adicionais
    crepuscular: in  std_logic;
    chuva: in  std_logic;
    temp1: in std_logic_vector(6 downto 0);
    temp2: in std_logic_vector(6 downto 0);
    nivelAguaA: in std_logic_vector(3 downto 0); 
    AguaB: in std_logic;
    
    -- Saídas para os LEDs de alerta
    alertaPortaJanela: out std_logic;
    alertaJanela: out std_logic;
    alertaChuva: out std_logic;
    alertaNoiteJanela: out std_logic;
    mediaTemperatura: out std_logic_vector(3 downto 0);
    alertaBomba: out std_logic;
    alertaEletrovalvula: out std_logic;
    alertaCaixaB: out std_logic;
    alertaPorta: out std_logic
  );
end Casa;

architecture Behavioral of Casa is
  signal alertaBombaInterno : std_logic := '1';

begin
  alertaBomba <= alertaBombaInterno;		

  process (janela1, janela2, janela3, porta, portaTrancada, modoSeguro,
           crepuscular, chuva, temp1, temp2, nivelAguaA, AguaB, alertaBombaInterno)
  
  variable vl1 : integer range  -10 to 50;
  variable vl2 : integer range  -10 to 50;
  variable vl_avg : integer range  -20 to 100;
 
 begin
	
        vl1 := to_integer(signed(temp1));
        vl2 := to_integer(signed(temp2));

        vl_avg := (vl1+vl2);

        if vl_avg < 0 then
            mediaTemperatura <= "0001";
        elsif vl_avg < 15 then 
            mediaTemperatura <= "0010";
        elsif vl_avg < 20 then
            mediaTemperatura <= "0100";
	ELSE 
	        mediaTemperatura <= "1000";
        end if;

    -- Verifica se alguma janela está aberta e o modo seguro está ativado
    if (modoSeguro = '1' and ((janela1 = '1' or janela2 = '1' or janela3 = '1') or (porta = '1' and portaTrancada = '0'))) then
      alertaPortaJanela <= '1';
    else
      alertaPortaJanela <= '0';
    end if;

    -- Verifica porta trancada mas aberta
    if (porta = '1' and portaTrancada = '0') then
      alertaPorta <= '1';
    else
      alertaPorta <= '0';
    end if;

    -- Verifica se alguma janela está aberta
    if (janela1 = '1' or janela2 = '1' or janela3 = '1') then
      alertaJanela <= '1';
    else
      alertaJanela <= '0';
    end if;

    -- Verifica se está chovendo e alguma janela ou porta está aberta
    if (chuva = '1' and (janela1 = '1' or janela2 = '1' or janela3 = '1' or porta = '1')) then
      alertaChuva <= '1';
    else
      alertaChuva <= '0';
    end if;

    -- Verifica se é noite e alguma janela está aberta
    if (crepuscular = '1' and (janela1 = '1' or janela2 = '1' or janela3 = '1')) then
      alertaNoiteJanela <= '1';
    else
      alertaNoiteJanela <= '0';
    end if;

    -- Liga a eletroválvula
    if (nivelAguaA = "0001" or nivelAguaA = "0000") then
      alertaEletrovalvula <= '1';
    else
      alertaEletrovalvula <= '0';
    end if;

    -- Liga a bomba
    if(nivelAguaA = "0000") then
       alertaBombaInterno <= '0';
    else
      alertaBombaInterno <= '1';
    end if;

    -- Verifica se a caixa de água B está cheia
    if (AguaB = '1') then 		
        alertaCaixaB <= '1';    -- Alerta que está cheia
        alertaBombaInterno <= '0';	-- Desliga a bomba
    else
	alertaCaixaB <= '0';

    end if;
  end process;
end architecture;
