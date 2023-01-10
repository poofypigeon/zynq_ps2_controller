library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
  generic ( BIT_WIDTH : positive := 8 );
  port (
    i_clk    : in  std_logic;
    i_sdata  : in  std_logic;
    i_enable : in  std_logic;
    i_latch  : in  std_logic;
    o_pdata  : out std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0')
  );
end shift_register;

architecture shift_register_arch of shift_register is
  signal shift_buffer : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');

begin

  process(i_clk)
  begin
    if rising_edge(i_clk) then
      if i_latch = '1' then
        o_pdata <= shift_buffer;
      end if;

      if i_enable = '1' then
        shift_buffer <= shift_buffer(6 downto 0) & i_sdata;
      end if;

    end if;
  end process;

end shift_register_arch;
