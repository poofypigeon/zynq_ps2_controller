library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_line_selector is
  generic ( SELECT_WIDTH : positive := 3 );
  port (
    i_data   : in  std_logic_vector(2**SELECT_WIDTH-1 downto 0);
    i_select : in  std_logic_vector(SELECT_WIDTH-1 downto 0);
    o_data   : out std_logic
  );
end mux_line_selector;

architecture mux_line_selector_arch of mux_line_selector is
begin

  o_data <= i_data(to_integer(unsigned(i_select)));

end mux_line_selector_arch;
