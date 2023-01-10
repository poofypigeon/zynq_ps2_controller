library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_up_counter is
  generic ( COUNT_WIDTH : positive := 3 );
  port (
    i_clk    : in  std_ulogic;
    i_enable : in  std_ulogic;
    i_reset  : in  std_ulogic;
    o_count  : out std_logic_vector(COUNT_WIDTH-1 downto 0) := (others => '0')
  );
end binary_up_counter;

architecture binary_up_counter_arch of binary_up_counter is
begin

  process(i_clk)
  begin
    if rising_edge(i_clk) then
      if i_reset = '1' then
        o_count <= (others => '0');
      elsif i_enable = '1' then
        if to_integer(unsigned(o_count)) = 2**COUNT_WIDTH-1 then
          o_count <= (others => '0');
        else
          o_count <= std_logic_vector(unsigned(o_count) + 1);
        end if;
      end if;
    end if;
  end process;

end binary_up_counter_arch;
