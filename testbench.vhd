library IEEE;
use IEEE.std_logic_1164.all;

package testbench_pkg is
    function gen_msg(texto: string; e : std_logic_vector; o :std_logic_vector) return string;
    function to_string(x:std_logic) return string;
end package testbench_pkg;

package body testbench_pkg is
    function gen_msg(texto: string; e : std_logic_vector; o :std_logic_vector) return string is
    begin
        return   texto
               & lf & "    Esperado: " & to_string(e)
               & lf & "    Obtenido: " & to_string(o);
    end function gen_msg;
    function to_string(x:std_logic) return string is
    begin
        return std_logic'image(x);
    end function to_string;
end package body testbench_pkg;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.testbench_pkg.all;
use work.ffd_pkg.all;

entity ffd_tb is
end ffd_tb;

architecture tb of ffd_tb is
    constant T : time := 10 ns;
    constant N1 : natural := 1;
    constant N2 : natural := 3;
    constant N3 : natural := 4;
    constant Nt : natural  := N1+N2+N3;

    signal rst : std_logic;
    signal D   : std_logic_vector (Nt-1 downto 0);
    signal hab : std_logic;
    signal clk : std_logic;
    signal Q   : std_logic_vector (Nt-1 downto 0);
begin
    u1: FFD generic map (N1)
            port map (
                rst => rst,
                D   => D(N1-1 downto 0),
                hab => hab,
                clk => clk,
                Q   => Q(N1-1 downto 0));
    u2: FFD generic map (N2)
            port map (
                rst => rst,
                D   => D(N2+N1-1 downto N1),
                hab => hab,
                clk => clk,
                Q   => Q(N2+N1-1 downto N1));
    u3: FFD generic map (N3)
            port map (
                rst => rst,
                D   => D(Nt-1 downto N1+N2),
                hab => hab,
                clk => clk,
                Q   => Q(Nt-1 downto N1+N2));
    process
        variable pass : boolean := true;
        variable esperado : std_logic_vector (Nt-1 downto 0);
        constant regla1: string := "Reset debe ser asincronico";
        constant regla2: string := "FFD debe ignorar reloj si deshabilitado";
        constant regla3: string := "FFD debe aceptar datos en flanco ascendente";
    begin
        rst <= '1';
        D   <= (others=>'1');
        hab <= '0';
        clk <= '0';
        wait for T;
        esperado := (others => '0');
        if (Q /= esperado) then
            report gen_msg(regla1,esperado,Q)
                severity error;
            pass := false;
        end if;
        rst <= '0';
        wait for T;
        clk <= '1';
        wait for T;
        if (Q /= esperado) then
            report gen_msg(regla2,esperado,Q)
                severity error;
            pass := false;
        end if;
        hab <= '1';
        clk <= '0';
        wait for T;
        clk <= '1';
        wait for T;
        esperado := D;
        if (Q /= esperado) then
            report gen_msg(regla3,esperado,Q)
                severity error;
            pass := false;
        end if;
        for i in 0 to (2**Nt - 1) loop
            if not pass then
                exit;
            end if;
            D <= std_logic_vector(to_unsigned(i,Nt));
            clk <= '0';
            wait for T;
            if (Q /= esperado) then
                report gen_msg(regla3,esperado,Q)
                    severity error;
                pass := false;
            end if;
            clk <= '1';
            wait for T;
            esperado := D;
            if (Q /= esperado) then
                report gen_msg(regla3,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end loop;
        clk <= '0';
        wait for T;
        rst <= '1';
        esperado := (others => '0');
        wait for T;
        if (Q /= esperado) then
            report gen_msg(regla1,esperado,Q)
                severity error;
            pass := false;
        end if;
        if pass then
            report "FFD [PASS]"
                severity note;
        else
            report "FFD [FAIL]"
                severity failure;
        end if;
        wait;
    end process;
end tb;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.testbench_pkg.all;

entity johnson_tb is
end johnson_tb;

architecture tb of johnson_tb is
    component johnson is
        generic (
            constant N:positive);
        port (
            rst   : in std_logic;
            hab   : in std_logic;
            clk   : in std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            Co    : out std_logic);
    end component;

    constant T : time := 10 ns;
    constant N : integer := 5;
    signal rst,hab,clk,Co : std_logic;
    signal Q : std_logic_vector (N-1 downto 0);
begin
    DUT : johnson generic map (N) port map (rst=>rst,hab=>hab,clk=>clk,Q=>Q,Co=>Co);

    process
        variable pass :boolean := true;
        procedure espera_igual(constant xQ: in std_logic_vector(N-1 downto 0);
                               constant xCo: in std_logic) is
        begin
            if Q /= xQ or Co /= xCo then
                report   "Se esperaba Q "&to_string(xQ)&" Co "&to_string(xCo)
                       & lf&"    obtenido Q "&to_string(Q)&" Co "&to_string(Co)
                    severity error;
                pass := false;
            end if;
        end procedure;
        procedure ciclo_reloj is
            constant xQ  : std_logic_vector (N-1 downto 0) := Q;
            constant xCo : std_logic := Co;
        begin
            clk <= '0';
            wait for T;
            espera_igual(xQ,xCo);
            clk <= '1';
            wait for T;
        end procedure;
        variable aux : std_logic_vector (N-1 downto 0);
    begin
        aux := (others=>'0');
        rst <= '1';
        clk <= '0';
        hab <= '0';
        wait for T;
        rst <= '0';
        for i in 1 to 2*N-2 loop
            if not pass then
                exit;
            end if;
            hab<='0';
            espera_igual(aux,'0');
            ciclo_reloj;
            espera_igual(aux,'0');
            hab<='1';
            ciclo_reloj;
            aux := aux(N-2 downto 0)&(not aux(N-1));
            espera_igual(aux,'0');
        end loop; 
        if pass then
            ciclo_reloj;
            aux := (N-1=>'1',others=>'0');
            espera_igual(aux,'1');
            ciclo_reloj;
            aux := (others=>'0');
            espera_igual(aux,'0');
        end if;
        if pass then
            report "Contador Johnson [PASS]";
        else
            report "Contador Johnson [FAIL]"
                severity failure;
        end if;
        wait;
    end process;

end tb;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.testbench_pkg.all;

entity contador_tb is
end contador_tb;

architecture tb of contador_tb is
    component contador is
        generic (
            constant N:positive);
        port (
            rst   : in std_logic;
            D     : in std_logic_vector (N-1 downto 0);
            carga : in std_logic;
            hab   : in std_logic;
            clk   : in std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            Co    : out std_logic);
    end component;
    constant T: time := 10 ns;
    constant N: integer := 5;
    signal rst,carga,hab,clk,Co : std_logic;
    signal D,Q : std_logic_vector (N-1 downto 0);
begin
    dut : contador generic map (N)
                   port map (
                    rst=>rst,
                    D=>D,
                    carga=>carga,
                    hab=>hab,
                    clk=>clk,
                    Q=>Q,
                    Co=>Co); 
    process
        variable pass : boolean := true;
        procedure espera_salida(constant nQ : in integer;
                                constant xCo: in std_logic) is
            constant xQ: std_logic_vector(N-1 downto 0) := std_logic_vector(to_unsigned(nQ,N));
        begin
            if xQ /= Q or xCo /= Co then
                report   "Se esperaba Q "&to_string(xQ)&" Co "&to_string(xCo)
                       & lf&"    obtenido Q "&to_string(Q)&" Co "&to_string(Co)
                    severity error;
                pass := false;
            end if;
        end procedure;
        procedure ciclo_reloj is
            constant xQ : std_logic_vector (N-1 downto 0):=Q;
            constant xCo : std_logic := Co;
        begin
            clk <= '0';
            wait for T;
            espera_salida(to_integer(unsigned(xQ)),xCo);
            clk <= '1';
            wait for T;
        end procedure;
    begin
        D <= (others=>'0');
        carga <= '0';
        hab <= '0';
        clk <= '0';
        rst <= '1';
        wait for T;
        espera_salida(0,'0');
        rst <= '0';
        ciclo_reloj;
        espera_salida(0,'0');
        ciclo_reloj;
        espera_salida(0,'0');
        hab<='1';
        wait for T;
        for i in 0 to 2**N-2 loop
            if not pass then
                exit;
            end if;
            espera_salida(i,'0');
            ciclo_reloj;
        end loop;
        if pass then
            espera_salida(2**N-1,'1');
            ciclo_reloj;
            espera_salida(0,'0');
        end if;
        if pass then
            carga <= '1';
            D <= std_logic_vector(to_unsigned(2**(N-1),N));
            ciclo_reloj;
            espera_salida(2**(N-1),'0');
            ciclo_reloj;
            espera_salida(2**(N-1),'0');
            carga <= '0';
            ciclo_reloj;
            espera_salida(2**(N-1)+1,'0');
        end if;
        if pass then
            report "Contador [PASS]";
        else
            report "Contador [FAIL]"
                severity failure;
        end if;
        wait;
    end process;
end tb;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.testbench_pkg.all;

entity det_flanco_tb is
end det_flanco_tb;

architecture tb of det_flanco_tb is
    component det_flanco is
        port (
            rst          : in std_logic;
            D            : in std_logic;
            hab          : in std_logic;
            clk          : in std_logic;
            flanco       : out std_logic;
            flanco_asinc : out std_logic);
    end component;
    
    signal rst,D,hab,clk,flanco,flanco_asinc : std_logic;

    constant T:time:=10 ns;

begin
    DUT : det_flanco port map (rst=>rst,
                               D=>D,
                               hab=>hab,
                               clk=>clk,
                               flanco=>flanco,
                               flanco_asinc=>flanco_asinc);
    --    
    process
        variable pass : boolean := true;
        procedure ciclo_reloj is
            constant xflanco : std_logic := flanco;
        begin
            clk <= '0';
            wait for T;
            if flanco /= xflanco then
                report   "Se esperaba flanco "&to_string(xflanco)
                    & lf&"    obtenido "&to_string(flanco)
                    severity error;
                pass := false;
            end if;
            clk <= '1';
            wait for T;
        end procedure;
        procedure espera_igual(constant xflanco : in std_logic;
                               constant xflanco_asinc : in std_logic) is
        begin
            if flanco /= xflanco or flanco_asinc /= xflanco_asinc then
                report   "Se esperaba flanco "&to_string(xflanco)&" flanco_asinc "&to_string(xflanco_asinc)
                    & lf&"    obtenido "&to_string(flanco)&" flanco_asinc "&to_string(flanco_asinc)
                    severity error;
                pass := false;
            end if;
        end procedure;
    begin
        rst <= '1';
        D <= '0';
        hab <= '0';
        clk <= '0';
        wait for T;
        espera_igual('0','0');
        D <= '1';
        wait for T;
        espera_igual('0','1');
        ciclo_reloj;
        espera_igual('0','1');
        rst <= '0';
        ciclo_reloj;
        espera_igual('0','1');
        D <= '0';
        wait for T;
        espera_igual('0','0');
        hab <= '1';
        ciclo_reloj;
        espera_igual('0','0');
        D <= '1';
        wait for T;
        espera_igual('0','1');
        ciclo_reloj;
        espera_igual('1','1');
        D <= '0';
        wait for T;
        espera_igual('1','1');
        ciclo_reloj;
        espera_igual('0','0');
        hab <= '0';
        D <= '1';
        ciclo_reloj;
        espera_igual('0','1');
        ciclo_reloj;
        espera_igual('0','1');
        ciclo_reloj;
        espera_igual('0','1');
        hab <= '1';
        wait for T;
        espera_igual('0','1');
        ciclo_reloj;
        espera_igual('1','1');
        ciclo_reloj;
        espera_igual('0','0');
        ciclo_reloj;
        espera_igual('0','0');

        if pass then
            report "Detector flanco [PASS]";
        else
            report "Detector flanco [FAIL]"
                severity failure;
        end if;
        wait;
    end process;
end tb;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.testbench_pkg.all;

entity det_tiempo_tb is
end entity;

architecture tb of det_tiempo_tb is
    constant T : time := 10 ns;
    component det_tiempo is
        generic (
            constant N : natural := 4);
        port(
            rst : in std_logic;
            pulso : in std_logic;
            hab : in std_logic;
            clk : in std_logic;
            med : out std_logic;
            tiempo : out std_logic_vector (N-1 downto 0));
    end component;
    constant N : natural := 7;
    type salida_t is record
        med    : std_logic;
        tiempo : std_logic_vector (N-1 downto 0);
    end record;
    signal rst,pulso,hab,clk : std_logic;
    signal salida : salida_t;

    function to_string(x : salida_t) return string is
    begin
        return  "med "&std_logic'image(x.med)
                &" tiempo "&to_string(x.tiempo);
    end function;
    function "/="(x:salida_t;y:salida_t) return boolean is
    begin
        return x.med /= y.med or x.tiempo /= y.tiempo;
    end function;
    function gen_msg(texto: string; e : salida_t; o :salida_t) return string is
    begin
        return   texto
                & lf & "    Esperado: " & to_string(e)
                & lf & "    Obtenido: " & to_string(o);
    end function gen_msg;
    
begin
    dut : det_tiempo generic map (N=>N)
                     port map (
                        rst=>rst,
                        pulso=>pulso,
                        hab=>hab,
                        clk=>clk,
                        med=>salida.med,
                        tiempo=>salida.tiempo);
    process
        variable pass     : boolean := true;
        variable esperado : salida_t;
        constant regla1 : string := "Reset es asincronico.";
        constant regla2 : string := "La salida solo cambia al reset o al iniciar/completar una medicion.";
        constant regla3 : string := "Tiempo debe ser igual al numero de flancos ascendentes con hab='1' que la entrada de pulso permanezca baja.";
        constant regla4 : string := "La entrada de pulso es sincroninca.";
        constant regla5 : string := "La salida med vuelve a cero al iniciar una nueva medicion.";
        constant regla6 : string := "Si el tiempo excede la cuenta maxima el valor de \"tiempo\" debe ser 0, indicando sobrecarga";
    begin
        rst <= '1'; -- reset
        pulso <= '1';
        hab <= '1';
        clk <= '0';
        wait for T; 
        esperado := (med=>'0',tiempo=>(others=>'0'));
        if salida /= esperado then
            report gen_msg(regla1,esperado,salida)
                severity error;
            pass := false;
        end if;
        -- fin reset

        if pass then  -- espacio longitud 1 (dos veces)
            rst   <= '0';
            hab   <= '1';
            pulso <= '1';
            wait for T;
            pulso <= '0';
            wait for T;
            clk   <= '1';
            wait for T;
            pulso <= '1';
            clk <= '0';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := (med =>'1', tiempo => (0=>'1',others=>'0'));
            if salida /= esperado then
                report gen_msg(regla3,esperado,salida)
                    severity error;
                pass := false;
            end if;
            pulso <= '0';
            clk <= '0';
            wait for T;
            clk   <= '1';
            wait for T;
            pulso <= '1';
            clk <= '0';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := (med =>'1', tiempo => (0=>'1',others=>'0'));
            if salida /= esperado then
                report gen_msg(regla3,esperado,salida)
                    severity error;
                pass := false;
            end if;
            clk <= '0';
            rst <= '1';
            wait for T;
            rst <= '0'; -- reset
            wait for T;
            esperado := (med=>'0',tiempo=>(others=>'0'));
            if salida /= esperado then
                report gen_msg(regla1,esperado,salida)
                    severity error;
                pass := false;
            end if;
        end if; -- Espacio longitud 1 (dos veces)

        if pass then -- Espacio no tomado
            clk <= '0';
            pulso <= '1';
            wait for T;
            clk <= '1';
            wait for T;
            pulso <= '0';
            clk <= '0';
            wait for T;
            pulso <= '1';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := (med=>'0',tiempo=>(others=>'0'));
            if salida /= esperado then
                report gen_msg(regla1,esperado,salida)
                    severity error;
                pass := false;
            end if;
        end if; -- espacio no tomado

        if pass then -- Espacio largo con la mitad de los ciclos deshabilitados
            pulso <= '0';
            clk <= '0';
            wait for T;
            for i in 1 to 2**(N-1) loop 
                clk <= '1';
                wait for T;
                if salida /= esperado then
                    report gen_msg(regla2,esperado,salida)
                        severity error;
                    pass := false;
                    exit;
                end if;
                clk <= '0';
                hab <= '0';
                wait for T;
                if salida /= esperado then
                    report gen_msg(regla2,esperado,salida)
                        severity error;
                    pass := false;
                    exit;
                end if;
                clk <= '1';
                wait for T;
                if salida /= esperado then
                    report gen_msg(regla2,esperado,salida)
                        severity error;
                    pass := false;
                    exit;
                end if;
                clk <= '0';
                hab <= '1';
                wait for T;
                if salida /= esperado then
                    report gen_msg(regla2,esperado,salida)
                        severity error;
                    pass := false;
                    exit;
                end if;
            end loop;
            if pass then
                pulso <= '1';
                wait for T;
                if salida /= esperado then
                    report gen_msg(regla2,esperado,salida)
                        severity error;
                    pass := false;
                end if;
                clk <= '1';
                wait for T;
                esperado := (med=>'1',tiempo=>std_logic_vector(to_unsigned(2**(N-1),N)));
                if salida /= esperado then
                    report gen_msg(regla3,esperado,salida)
                        severity error;
                    pass := false;
                end if;
                clk <= '0';
                wait for T;
            end if;
        end if; -- Espacio largo con la mitad de los ciclos deshabilitados
        if pass then -- Rebalse da lectura 0
            pulso <= '0';
            wait for T;
            if salida /= esperado then
                report gen_msg(regla4,esperado,salida)
                    severity error;
                pass := false;
            end if;
            clk <= '1';
            wait for T;
            esperado.med := '0';
            if salida /= esperado then
                report gen_msg(regla5,esperado,salida)
                    severity error;
                pass := false;
            end if;
            for i in 1 to 4+2**N loop
                clk <= '0';
                wait for T;
                clk <= '1';
                wait for T;
            end loop;
            clk <= '0';
            pulso <= '1';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := (med=>'1',tiempo=>std_logic_vector(to_unsigned(0,N)));
            if salida /= esperado then
                report gen_msg(regla6,esperado,salida)
                    severity error;
                pass := false;
            end if;
        end if; -- Rebalse da lectura 0
        if pass then
            report "det_tiempo [PASS]"
                severity note;
        else
            report "det_tiempo [FAIL]"
                severity failure;
        end if;
        wait;
    end process;
end tb;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.testbench_pkg.all;

entity sipo_tb is
end sipo_tb;

architecture tb of sipo_tb is
    constant T : time := 10 ns;
    component sipo is
        generic(
            N : natural := 4);
        port(
            rst     : in std_logic;
            entrada : in std_logic;
            hab     : in std_logic;
            clk     : in std_logic;
            Q       : out std_logic_vector (N-1 downto 0));
    end component;
    constant N : natural := 8; 
    signal rst,entrada,hab,clk : std_logic;
    signal Q : std_logic_vector (N-1 downto 0);
begin
    dut : sipo generic map (N => N)
               port map (
                rst     => rst,
                entrada => entrada,
                hab     => hab,
                clk     => clk,
                Q       => Q);
    process
        variable esperado : std_logic_vector(N-1 downto 0);
        variable pass     : boolean := true;
        constant regla1 : string := "El reset es asincrono.";
        constant regla2 : string := "El reset tiene prioridad sobre habilitacion y reloj.";
        constant regla3 : string := "El reloj solo es activo cuando hay habilitacion.";
        constant regla4 : string := "El desplazamiento debe efectuarse en el flanco ascendente de reloj.";
    begin
        rst <= '1';
        entrada <= '0';
        hab <= '0';
        clk <= '0';
        wait for T;
        esperado := (others => '0');
        if esperado /= Q then
            report gen_msg(regla1,esperado,Q)
                severity error;
            pass := false;
        end if;
        if pass then
            hab <= '1';
            entrada <= '1';
            wait for T;
            clk <= '1';
            wait for T;
                if esperado /= Q then
                    report gen_msg(regla2,esperado,Q)
                        severity error;
                    pass := false;
                end if;
        end if;
        if pass then
            clk <= '0';
            rst <= '0';
            hab <= '0';
            wait for T;
            clk <= '1';
            wait for T;
            if esperado /= Q then
                report gen_msg(regla3,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end if;
        if pass then
            hab <= '1';
            wait for T;
            clk <= '0';
            wait for T;
            if esperado /= Q then
                report gen_msg(regla4,esperado,Q)
                    severity error;
                pass := false;
            end if;
            clk <= '1';
            wait for T;
            esperado := '1'&esperado(N-1 downto 1);
            if esperado /= Q then
                report gen_msg(regla4,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end if;
        for i in 0 to N-2 loop
            if not pass then
                exit;
            end if;
            clk <= '0';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := '1'&esperado(N-1 downto 1);
            if esperado /= Q then
                report gen_msg(regla4,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end loop;
        for i in 0 to N-2 loop
            if not pass then
                exit;
            end if;
            clk <= '0';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := '1'&esperado(N-2 downto 0);
            if esperado /= Q then
                report gen_msg(regla4,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end loop;
        entrada <= '0';
        for i in 0 to N/2 loop
            if not pass then
                exit;
            end if;
            clk <= '0';
            wait for T;
            clk <= '1';
            wait for T;
            esperado := '0'&esperado(N-1 downto 1);
            if esperado /= Q then
                report gen_msg(regla4,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end loop;
        if pass then
            rst <= '1';
            wait for T;
            rst <= '0';
            wait for T;
            esperado := (others => '0');
            if esperado /= Q then
                report gen_msg(regla1,esperado,Q)
                    severity error;
                pass := false;
            end if;
        end if;
        if pass then
            report "sipo [PASS]"
                severity note;
        else
            report "sipo [FAIL]"
                severity failure;
        end if;
        wait;
    end process;
end tb;
