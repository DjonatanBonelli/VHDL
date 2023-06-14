library ieee;
use ieee.std_logic_1164.all;

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
    temp1: in  integer range -20 to 50;
    temp2: in  integer range -20 to 50;
    nivelAguaA: std_logic_vector(3 downto 0); 
    AguaB: in std_logic;
    
    -- Saídas para os LEDs de alerta
    alertaPortaJanela: out std_logic;
    alertaJanela: out std_logic;
    alertaChuva: out std_logic;
    alertaNoiteJanela: out std_logic;
    alertaTemperatura: out std_logic;
    alertaBomba: out std_logic;
    alertaEletrovalvula: out std_logic;
    alertaCaixaB: out std_logic
  );
end Casa;

architecture Behavioral of Casa is

begin

  process (janela1, janela2, janela3, porta, portaTrancada, modoSeguro,
           crepuscular, chuva, temp1, temp2, nivelAguaA, AguaB)
  begin
    -- Verifica se alguma janela está aberta e o modo seguro está ativado
    if (modoSeguro = '1' and (janela1 = '1' or janela2 = '1' or janela3 = '1')) then
      alertaPortaJanela <= '1';
    else
      alertaPortaJanela <= '0';
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

    -- Verifica se alguma janela está aberta e a temperatura está abaixo de 15°C
    if ((janela1 = '1' or janela2 = '1' or janela3 = '1') and (temp1 < 15 or temp2 < 15)) then
      alertaJanela <= '1';
    else
      alertaJanela <= '0';
    end if;

    -- Verifica o nível de água na caixa A
    if (NivelAguaA(0) = '0') then 	
        alertaBomba <= '0'; -- Não liga a bomba
        alertaEletrovalvula <= '1'; -- Liga a eletrovalvula
      end if;

    -- Verifica se a caixa de água B está cheia
    if (AguaB = '1') then 		
        alertaCaixaB <= '0';    -- Alerta que está cheia
        alertaBomba <= '0';	-- Desliga a bomba

      end if;
 end process;
end architecture;
