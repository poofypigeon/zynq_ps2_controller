library ieee;
use ieee.std_logic_1164.all;

entity jk_flip_flop is
  port (
    i_clk :  in std_ulogic;
    i_j   :  in std_ulogic;
    i_k   :  in std_ulogic;
    o_q   : out std_ulogic := '0'
  );
end jk_flip_flop;

architecture jk_flip_flop_arch of jk_flip_flop is
  signal jk : std_ulogic_vector(1 downto 0);

begin

  jk <= i_j & i_k;

  process(i_clk)
  begin
    if rising_edge(i_clk) then
      case jk is
        when "00" => o_q <= o_q;
        when "01" => o_q <= '0';
        when "10" => o_q <= '1';
        when "11" => o_q <= not o_q;
        when others => null;
      end case;
    end if;
  end process;

end jk_flip_flop_arch;
