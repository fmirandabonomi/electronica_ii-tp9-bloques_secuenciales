library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_pkg.all;

entity det_flanco is
    port (
        rst          : in std_logic;
        D            : in std_logic;
        hab          : in std_logic;
        clk          : in std_logic;
        flanco       : out std_logic;
        flanco_asinc : out std_logic);
end det_flanco;

architecture solucion of det_flanco is
begin
    -- Completar
end solucion;