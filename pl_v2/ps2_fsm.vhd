library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_fsm is
  port (
    i_clk                   :  in std_ulogic;
    i_reset                 :  in std_ulogic;

    i_sclk_negedge          :  in std_ulogic;
    i_sdata                 :  in std_ulogic;

    i_trx_count             :  in std_ulogic_vector(3 downto 0);
    i_rx_parity             :  in std_ulogic;
    i_tx_request            :  in std_ulogic;
    i_timeout               :  in std_ulogic;
    i_sclk_assert           :  in std_ulogic;
    i_sdata_assert          :  in std_ulogic;

    o_trx_counter_enable    : out std_ulogic;
    o_trx_counter_reset     : out std_ulogic;
    o_rx_serial_enable      : out std_ulogic;
    o_rx_parity_enable      : out std_ulogic;
    o_rx_parity_reset       : out std_ulogic;
    o_rx_latch              : out std_ulogic;
    o_tx_parity_enable      : out std_ulogic;
    o_tx_parity_reset       : out std_ulogic;
    o_tx_send_parity        : out std_ulogic;
    o_timer_enable          : out std_ulogic;
    o_timer_reset           : out std_ulogic;
    o_drive_sdata           : out std_ulogic;
    o_assert_sclk           : out std_ulogic;
    o_pulldown_sdata        : out std_ulogic;
    o_request_resend        : out std_ulogic;
    o_request_resend_enable : out std_ulogic;
    o_request_resend_reset  : out std_ulogic
  );
end ps2_fsm;

architecture ps2_fsm_arch of ps2_fsm is
  type state_t is ( IDLE, RX_DATA, RX_PARITY, RX_STOP, TX_REQ_TO_SEND, TX_DATA, TX_PARITY, TX_ACK );
  signal state      : state_t := IDLE;
  signal next_state : state_t;

begin

  p_sync : process(i_clk)
  begin
    if rising_edge(i_clk) then
      if i_reset = '1' then
        state <= IDLE;
      else
        state <= next_state;
      end if;
    end if;
  end process;

  p_transition : process(all)
  begin
    case state is
      when IDLE =>
        if i_tx_request = '1' then
          next_state <= TX_REQ_TO_SEND;
        elsif i_sdata = '0' and i_sclk_negedge = '1' then
          next_state <= RX_DATA;
        else
          next_state <= state;
        end if;

      when RX_DATA =>
        if i_tx_request = '1' then
          next_state <= TX_REQ_TO_SEND;
        elsif to_integer(unsigned(i_trx_count)) = 8 then
          next_state <= RX_PARITY;
        else
          next_state <= state;
        end if;

      when RX_PARITY =>
        if i_tx_request = '1' then
          next_state <= TX_REQ_TO_SEND;
        elsif to_integer(unsigned(i_trx_count)) = 0 then
          next_state <= RX_STOP;
        else
          next_state <= state;
        end if;

      when RX_STOP =>
        if i_sclk_negedge = '1' then
          if i_rx_parity = '1' then
            next_state <= IDLE;
          else
            next_state <= TX_REQ_TO_SEND;
          end if;
        else
          next_state <= state;
        end if;

      when TX_REQ_TO_SEND =>
        if i_timeout = '1' then
          next_state <= IDLE;
        elsif i_sclk_negedge = '1' then
          next_state <= TX_DATA;
        else
          next_state <= state;
        end if;

      when TX_DATA =>
        if i_timeout = '1' then
          next_state <= IDLE;
        elsif to_integer(unsigned(i_trx_count)) = 8 then
          next_state <= TX_PARITY;
        else
          next_state <= state;
        end if;

      when TX_PARITY =>
        if i_timeout = '1' then
          next_state <= IDLE;
        elsif to_integer(unsigned(i_trx_count)) = 0 then
          next_state <= TX_ACK;
        else
          next_state <= state;
        end if;

      when TX_ACK =>
        if i_sclk_negedge = '1' then
          next_state <= IDLE;
        else
          next_state <= state;
        end if;

    end case;
  end process;

  p_decoder : process(all)
  begin
    case state is
      when IDLE =>
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '1';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '1';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '1';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '1';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '1';

      when RX_DATA =>
        o_trx_counter_enable    <= i_sclk_negedge;
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= i_sclk_negedge;
        o_rx_parity_enable      <= i_sclk_negedge;
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when RX_PARITY =>
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= i_sclk_negedge;
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= i_sclk_negedge;
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= not i_rx_parity;
        o_request_resend_enable <= i_sclk_negedge;
        o_request_resend_reset  <= '0';

      when RX_STOP =>
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= i_sclk_negedge;
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when TX_REQ_TO_SEND =>
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '1';
        o_drive_sdata           <= i_sdata_assert;
        o_assert_sclk           <= not i_sclk_assert;
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when TX_DATA =>
        o_trx_counter_enable    <= i_sclk_negedge;
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '1';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '0';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '1';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when TX_PARITY =>
        o_trx_counter_enable    <= i_sclk_negedge;
        o_trx_counter_reset     <= i_sclk_negedge;
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '1';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '1';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when TX_ACK =>
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

    end case;
  end process;

end ps2_fsm_arch;

architecture gates of ps2_fsm is
  signal state      : std_ulogic_vector(7 downto 0) := "00000001";
  signal next_state : std_ulogic_vector(7 downto 0);

  signal trx_counter_8 : std_logic;

begin

  trx_counter_8 <= i_trx_count(3);

  p_sync : process(i_clk)
  begin
    if rising_edge(i_clk) then
      state <= next_state;
    end if;
  end process;

  -- IDLE
  next_state(0) <= (i_reset) or (state(0) and not(i_tx_request) and (i_sdata or not(i_sclk_negedge))) or (i_sclk_negedge and ((state(3) and i_rx_parity) or state(7)))
                or (i_timeout and (state(4) or state(5) or state(6) or state(7)));

  -- RX_DATA
  next_state(1) <= (not(i_reset)) and ((state(1) and not(i_tx_request) and not(trx_counter_8)) or (state(0) and not(i_sdata) and i_sclk_negedge));

  -- RX_PARITY
  next_state(2) <= (not(i_reset) and trx_counter_8) and ((state(2) and not(i_tx_request)) or state(1));

  -- RX_STOP
  next_state(3) <= (not(i_reset)) and ((state(3) and not(i_sclk_negedge)) or (state(2) and not(trx_counter_8)));

  -- TX_REQ_TO_SEND
  next_state(4) <= (not(i_reset)) and ((state(4) and not(i_timeout) and not(i_sclk_negedge)) or (i_tx_request and (state(0) or state(1) or state(2))) or (state(3) and i_sclk_negedge and not(i_rx_parity)));

  -- TX_DATA
  next_state(5) <= (not(i_reset)) and ((state(5) and not(i_timeout) and not(trx_counter_8)) or (state(4) and i_sclk_negedge));

  -- TX_PARITY
  next_state(6) <= (not(i_reset) and trx_counter_8) and ((state(6) and not(i_timeout)) or state(5));

  -- TX_ACK
  next_state(7) <= (not(i_reset)) and ((state(7) and not(i_sclk_negedge)) or (state(6) and not(trx_counter_8)));

  p_decoder : process(all)
  begin
    case state is
      when "00000001" => -- IDLE
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '1';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '1';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '1';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '1';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '1';

      when "00000010" => -- RX_DATA
        o_trx_counter_enable    <= i_sclk_negedge;
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= i_sclk_negedge;
        o_rx_parity_enable      <= i_sclk_negedge;
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when "00000100" => -- RX_PARITY
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= i_sclk_negedge;
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= i_sclk_negedge;
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= not i_rx_parity;
        o_request_resend_enable <= i_sclk_negedge;
        o_request_resend_reset  <= '0';

      when "00001000" => -- RX_STOP
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= i_sclk_negedge;
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '0';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when "00010000" => -- TX_REQ_TO_SEND
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '1';
        o_drive_sdata           <= i_sdata_assert;
        o_assert_sclk           <= not i_sclk_assert;
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when "00100000" => -- TX_DATA
        o_trx_counter_enable    <= i_sclk_negedge;
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '1';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '0';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '1';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when "01000000" => -- TX_PARITY
        o_trx_counter_enable    <= i_sclk_negedge;
        o_trx_counter_reset     <= i_sclk_negedge;
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '1';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '1';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when "10000000" => -- TX_ACK
        o_trx_counter_enable    <= '0';
        o_trx_counter_reset     <= '0';
        o_rx_serial_enable      <= '0';
        o_rx_parity_enable      <= '0';
        o_rx_parity_reset       <= '0';
        o_rx_latch              <= '0';
        o_tx_parity_enable      <= '0';
        o_tx_parity_reset       <= '0';
        o_tx_send_parity        <= '-';
        o_timer_enable          <= '1';
        o_timer_reset           <= '0';
        o_pulldown_sdata        <= '0';
        o_drive_sdata           <= '0';
        o_assert_sclk           <= '0';
        o_request_resend        <= '-';
        o_request_resend_enable <= '0';
        o_request_resend_reset  <= '0';

      when others => null;

    end case;
  end process p_decoder;

end gates;


