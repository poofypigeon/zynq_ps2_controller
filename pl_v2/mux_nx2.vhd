library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_nx2 is
  generic ( INPUT_WIDTH : positive := 8 );
  port (
    i_data_0 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    i_data_1 : in  std_logic_vector(INPUT_WIDTH-1 downto 0);
    i_select : in  std_logic;
    o_data   : out std_logic_vector(INPUT_WIDTH-1 downto 0)
  );
end mux_nx2;

architecture mux_nx2_arch of mux_nx2 is
begin

  with i_select select o_data
    <= i_data_0 when '0',
       i_data_1 when '1',
       (others => '0') when others;

end mux_nx2_arch;
