library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2 is
  port (
    i_clk          : in    std_ulogic;
    i_fsm_reset    : in    std_ulogic;
    -- ps/2 signals
    i_sclk         : inout std_ulogic;
    o_sclk         : inout std_ulogic;
    t_sclk         : inout std_ulogic;
    i_sdata        : inout std_ulogic;
    o_sdata        : inout std_ulogic;
    t_sdata        : inout std_ulogic;
    -- tx buffer signals
    i_tx_buffer    : in    std_ulogic_vector(7 downto 0);
    i_tx_request   : in    std_ulogic;
    -- rx buffer signals
    o_rx_buffer    : out   std_ulogic_vector(7 downto 0);
    o_rx_interrupt : out   std_ulogic
  );
end ps2;

architecture ps2_arch of ps2 is
  constant C_RESEND_CODE        : std_ulogic_vector(7 downto 0) := X"FE";
  constant C_TIMEOUT_COUNT      : positive := 240000; -- for a 16MHz clock
  constant C_SCLK_ASSERT_COUNT  : positive := 1616;   -- for a 16MHz clock
  constant C_SDATA_ASSERT_COUNT : positive := 1600;   -- for a 16MHz clock

  signal sclk_d                 : std_ulogic_vector(1 downto 0);
  signal sclk_negedge           : std_ulogic;
  signal trx_count              : std_ulogic_vector(3 downto 0);
  signal tx_sdata_i             : std_ulogic;
  signal tx_pdata               : std_ulogic_vector(7 downto 0);
  signal tx_sdata               : std_ulogic;
  signal rx_parity              : std_ulogic;
  signal timeout                : std_ulogic;
  signal trx_counter_enable     : std_ulogic;
  signal trx_counter_reset      : std_ulogic;
  signal rx_serial_enable       : std_ulogic;
  signal rx_parity_enable       : std_ulogic;
  signal rx_parity_toggle       : std_ulogic;
  signal rx_parity_reset        : std_ulogic;
  signal rx_buffer              : std_ulogic_vector(7 downto 0);
  signal rx_latch               : std_ulogic;
  signal tx_parity_enable       : std_ulogic;
  signal tx_parity_reset        : std_ulogic;
  signal tx_send_parity         : std_ulogic;
  signal timer_count            : std_ulogic_vector(17 downto 0);
  signal timer_enable           : std_ulogic;
  signal timer_reset            : std_ulogic;
  signal tx_sdata_assert        : std_ulogic;
  signal tx_sclk_assert         : std_ulogic;
  signal pulldown_sdata         : std_ulogic;
  signal drive_sdata            : std_ulogic;
  signal assert_sclk            : std_ulogic;
  signal request_resend         : std_ulogic;
  signal request_resend_i       : std_ulogic;
  signal request_resend_enable  : std_ulogic;
  signal request_resend_reset   : std_ulogic;
begin

o_sclk  <= '0';
t_sclk  <= assert_sclk;
o_sdata <= '0' when pulldown_sdata else tx_sdata;
t_sdata <= drive_sdata;

p_sclk_d : process(i_clk)
begin
  -- XXX add metastable protection
  if rising_edge(i_clk) then
    sclk_d <= sclk_d(0) & i_sclk;
  end if;
end process p_sclk_d;

sclk_negedge <= sclk_d(1) and not sclk_d(0);

u_fsm : entity work.ps2_fsm(gates)
  port map (
    i_clk                   => i_clk,
    i_reset                 => i_fsm_reset,

    i_sclk_negedge          => sclk_negedge,
    i_sdata                 => i_sdata,

    i_trx_count             => trx_count,
    i_rx_parity             => rx_parity,
    i_tx_request            => i_tx_request,
    i_timeout               => timeout,
    i_sdata_assert          => tx_sdata_assert,
    i_sclk_assert           => tx_sclk_assert,

    o_trx_counter_enable    => trx_counter_enable,
    o_trx_counter_reset     => trx_counter_reset,
    o_rx_serial_enable      => rx_serial_enable,
    o_rx_parity_enable      => rx_parity_enable,
    o_rx_parity_reset       => rx_parity_reset,
    o_rx_latch              => rx_latch,
    o_tx_parity_enable      => tx_parity_enable,
    o_tx_parity_reset       => tx_parity_reset,
    o_tx_send_parity        => tx_send_parity,
    o_timer_enable          => timer_enable,
    o_timer_reset           => timer_reset,
    o_pulldown_sdata        => pulldown_sdata,
    o_drive_sdata           => drive_sdata,
    o_assert_sclk           => assert_sclk,
    o_request_resend        => request_resend_i,
    o_request_resend_enable => request_resend_enable,
    o_request_resend_reset  => request_resend_reset
  );

u_trx_counter : entity work.binary_up_counter
  generic map ( COUNT_WIDTH => 4 )
  port map (
    i_clk    => i_clk,
    i_enable => trx_counter_enable,
    i_reset  => trx_counter_reset,
    o_count  => trx_count
  );

u_rx_serial : entity work.shift_register
  port map (
    i_clk    => i_clk,
    i_enable => rx_serial_enable,
    i_sdata  => i_sdata,
    i_latch  => rx_latch,
    o_pdata  => rx_buffer
  );

  o_rx_interrupt <= rx_latch;

  process(all)
  begin
    for i in 0 to 7 loop
      o_rx_buffer(i) <= rx_buffer(7-i);
    end loop;
  end process;

rx_parity_toggle <= rx_parity_enable and i_sdata;

u_rx_parity_generator : entity work.jk_flip_flop
  port map (
    i_clk => i_clk,
    i_j   => rx_parity_toggle,
    i_k   => rx_parity_toggle or rx_parity_reset,
    o_q   => rx_parity
  );

u_rx_request_resend : entity work.jk_flip_flop
  port map (
    i_clk => i_clk,
    i_j   => request_resend_enable and request_resend_i,
    i_k   => request_resend_reset,
    o_q   => request_resend
  );

u_tx_data_mux : entity work.mux_nx2
  generic map ( INPUT_WIDTH => 8 )
  port map (
    i_data_0 => i_tx_buffer,
    i_data_1 => C_RESEND_CODE,
    i_select => request_resend,
    o_data   => tx_pdata
  );

u_tx_serializer : entity work.mux_line_selector
  generic map ( SELECT_WIDTH => 3 )
  port map (
    i_data   => tx_pdata,
    i_select => trx_count(2 downto 0),
    o_data   => tx_sdata_i
  );

u_tx_parity_mux : entity work.mux_line_selector
  generic map ( SELECT_WIDTH => 1 )
  port map (
    i_data      => (xor tx_pdata) & tx_sdata_i,
    i_select(0) => tx_send_parity,
    o_data      => tx_sdata
  );

u_tx_timer : entity work.binary_up_counter
  generic map ( COUNT_WIDTH => 18 )
  port map (
    i_clk    => i_clk,
    i_enable => timer_enable,
    i_reset  => timer_reset,
    o_count  => timer_count
  );

timeout         <= '1' when to_integer(unsigned(timer_count)) = C_TIMEOUT_COUNT      else '0';
tx_sclk_assert  <= '1' when to_integer(unsigned(timer_count)) > C_SCLK_ASSERT_COUNT  else '0';
tx_sdata_assert <= '1' when to_integer(unsigned(timer_count)) > C_SDATA_ASSERT_COUNT else '0';

end ps2_arch;
