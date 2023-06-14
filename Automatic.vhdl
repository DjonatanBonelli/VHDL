














Considere que em todas as
3 janelas da sua casa, bem como na porta, existe um sensor que diz que a porta
ou janela está fechada (valor 0) ou aberta (valor 1). A porta é mais complexa e
além do sensor que indica se está aberta existe um sensor que indica se a
mesma está trancada (0 trancada, 1 aberta). Além dos sensores existe um botão
que indica se o sistema está em modo seguro (1 caso o botão esteja ativo, e 0
caso contrário). Se o botão de modo seguro estiver ativo e uma janela for
aberta, ou a porta for aberta e estiver trancada um sinal de alerta deve ser
enviado para o painel do usuário (led aceso). Em qualquer momento se a porta
estiver trancada e o sensor sinaliza que a mesma está aberta o mesmo sinal de
alerta deve ser ativado. Além disso, é importante que um sinal de aviso seja
ativado caso alguma das janelas esteja aberta.
Quando você trancar a porta da sua casa e ativar o modo seguro, deve também
ser notificado se alguma das janelas permanecer aberta.
Além destes sensores sua casa está equipada com um sensor crepuscular (0 se
for dia, 1 se for noite), um sensor de chuva (0 caso não esteja chovendo e 1
caso chova) e dois sensores de temperatura que variam de -20°C a 50°C. É de
vital importância que caso comece a chover e alguma janela ou porta da casa
esteja aberta um sinal de aviso seja ativado. Caso anoiteça e as janelas estejam
abertas também é importante que um sinal de aviso seja disparado. Outro aviso
deve ser dado caso alguma das janelas esteja aberta e a temperatura estiver
abaixo de 15° (média dos dois sensores).
Considere que em sua residência você possui duas caixas de água A e B. As
duas caixas estão ligadas de forma que B receba água bombeada a partir da
caixa A. Dentro da caixa A existe um sensor de nível de água que retorna um
percentual de nível da água (0 – vazio e 100 – cheio). Caso o nível de água da
caixa A esteja abaixo de 20% a bomba que leva a água para a caixa B não pode
ser ativada. Na caixa B apenas existe um sensor que indica nível máximo, caso
este seja atingido a bomba deve ser desligada (a bomba deve ser representada
por led, aceso enquanto a mesma estiver ligada, e apagado quando a bomba
estiver desligada). A caixa de água A é alimentada por uma eletroválvula, caso
seu nível de água seja inferior a 15% a eletroválvula é ativada (assim como a
bomba, a eletroválvula deve ser representada por um led).



entity Casa is
  Port (
    -- Sensores das janelas e da porta
    janela1 : in  std_logic;
    janela2 : in  std_logic;
    janela3 : in  std_logic;
    porta   : in  std_logic;
    portaTrancada : in  std_logic;
    
    -- Botão do modo seguro
    modoSeguro : in  std_logic;
    
    -- Sensores adicionais
    crepuscular : in  std_logic;
    chuva       : in  std_logic;
    temperatura1       : in  integer range -20 to 50;
    temperatura2       : in  integer range -20 to 50;
    
    -- Saídas para os LEDs de alerta
    alertaPortaJanela : out std_logic;
    alertaJanela     : out std_logic;
    alertaChuva      : out std_logic;
    alertaNoiteJanela: out std_logic;
    alertaTemperatura: out std_logic;
    alertaBomba      : out std_logic;
    alertaEletrovalvula : out std_logic
  );
end Casa;

architecture Behavioral of Casa is

begin

  process (janela1, janela2, janela3, porta, portaTrancada, modoSeguro,
           crepuscular, chuva, temp1, temp2)
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
    
   -- Sinal de alerta para temperatura abaixo de 15° e janelas abertas
        if (temperatura1 < 15 or temperatura2 < 15) and (janela1 = '1' or janela2 = '1' or janela3 = '1') then
            alertaTemperatura <= '1';
        else
            alertaTemperatura <= '0';
        end if;
        
    -- Verifica se alguma janela está aberta e a temperatura está abaixo de 15°C
    if ((janela1 = '1' or janela2 = '1' or janela3 = '1') and (temp1 < 15 or temp2 < 15)) then
      alertaJanela <= '1';
    else
      alertaJanela <= '0';
    end if;

    -- Verifica o nível de água na caixa A
    if (nivelAguaA < 20) then
      alertaBomba <= '0'; -- Desliga
    end if;
 end process;
end behavorial;
