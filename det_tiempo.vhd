library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ffd_pkg.all;

entity det_tiempo is
    generic (
        constant N : natural := 4);
    port(
        rst : in std_logic;
        pulso : in std_logic;
        hab : in std_logic;
        clk : in std_logic;
        med : out std_logic;
        tiempo : out std_logic_vector (N-1 downto 0));
end det_tiempo;

architecture solucion of det_tiempo is
begin
    -- Completar
end solucion;