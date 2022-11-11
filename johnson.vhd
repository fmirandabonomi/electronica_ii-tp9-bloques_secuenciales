library IEEE;
use IEEE.std_logic_1164.all;
use work.ffd_pkg.all;

entity johnson is
    generic (
        constant N:positive);
    port (
        rst   : in std_logic;
        hab   : in std_logic;
        clk   : in std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        Co    : out std_logic);
end johnson;

architecture solucion of johnson is
begin
end solucion;