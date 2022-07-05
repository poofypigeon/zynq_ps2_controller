library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_interface is
  generic (CLOCK_FREQUENCY_HZ : natural := 100000000);
  port (
    i_clk                 : in  std_ulogic;
    i_write_data          : in  std_ulogic_vector(7 downto 0);
    o_read_data           : out std_ulogic_vector(7 downto 0);
    -- control signals
    i_write_register_full : in  std_ulogic;
    o_read_ready_irq      : out std_ulogic;
    o_busy                : out std_ulogic;
    o_tx_failed           : out std_ulogic;
    o_timeout             : out std_ulogic;
    -- ps2 protocol signals
    io_sclk               : inout std_ulogic;
    io_sdata              : inout std_ulogic
  );
end ps2_interface;

architecture ps2_interface_arch of ps2_interface is
  constant RESEND_CODE : std_ulogic_vector(7 downto 0) := x"FE";
  constant ONE_US : natural := CLOCK_FREQUENCY_HZ / (10**6);
  constant ONE_MS : natural := CLOCK_FREQUENCY_HZ / (10**3);

  type state_t is (
    IDLE, RX_DATA, RX_PARITY, RX_STOP,
    TX_REQ_TO_SEND, TX_DATA, TX_PARITY, TX_ACK
  );

  signal state : state_t := IDLE;

  signal delay_counter     : unsigned(31 downto 0);
  signal rx_counter        : unsigned(3 downto 0);
  signal tx_counter        : unsigned(3 downto 0);
  signal clear_delay       : std_ulogic;
  signal clear_delay_d     : std_ulogic;

  signal req_resend        : std_ulogic := '0';

  signal sclk_d            : std_ulogic_vector(1 downto 0) := (others => '0');
  signal sclk_negedge      : std_ulogic := '0';

  signal sclk_inhibit      : std_ulogic := '0';
  signal sdata_tx_enable   : std_ulogic := '0';
  signal sdata_tx          : std_ulogic;

  signal read_buffer       : std_ulogic_vector(7 downto 0);
begin

  -- detect falling sclk edge
  sclk_latching : process(i_clk)
  begin
    if rising_edge(i_clk) then
      sclk_d(1) <= sclk_d(0);
    end if;
  end process;

  u_sclk_xfer : entity work.bit_xfer
    port map (
      i_clk => i_clk,
      i_bit => io_sclk,
      o_bit => sclk_d(0)
    );

  sclk_negedge <= sclk_d(1) and not sclk_d(0) and not sclk_inhibit;

  -- imply tri-state bidirectional ports
  io_sclk  <= '0' when sclk_inhibit = '1' else 'Z';
  io_sdata <= sdata_tx when sdata_tx_enable = '1' else 'Z';

  -- ps/2 port outputs
  sclk_inhibit  <= '1' when state = TX_REQ_TO_SEND and delay_counter < 101*ONE_US else '0';
  sdata_tx      <= i_write_data(to_integer(tx_counter)) when state = TX_DATA and req_resend = '0' else
                   RESEND_CODE(to_integer(tx_counter))  when state = TX_DATA and req_resend = '1' else
                   xnor i_write_data                    when state = TX_PARITY                    else
                   '0';

  timeout : process(i_clk)
  begin
    if rising_edge(i_clk) then
      clear_delay_d <= clear_delay;
      if state = IDLE or (clear_delay = '1' and clear_delay_d = '0') then
        delay_counter <= (others => '0');
      else
        delay_counter <= delay_counter + 1;
      end if;
    end if;
  end process;

  fsm : process(i_clk)
  begin
    if rising_edge(i_clk) then
      if delay_counter = 30*ONE_MS then
        o_timeout <= '1';
        state <= IDLE;
      end if;

      case state is
        when IDLE =>
          clear_delay <= '0';
          rx_counter <= (others => '0');
          tx_counter <= (others => '0');
          o_read_ready_irq <= '0';
          o_busy <= '0';
          if i_write_register_full = '1' then
            o_tx_failed <= '0';
            o_timeout <= '0';
            o_busy <= '1';
            state <= TX_REQ_TO_SEND;
          elsif io_sdata = '0' and sclk_negedge = '1' then
            -- start signal recieved
            state <= RX_DATA;
          end if;

        when RX_DATA =>
          if i_write_register_full = '1' then
            o_tx_failed <= '0';
            o_timeout <= '0';
            o_busy <= '1';
            state <= TX_REQ_TO_SEND;
          elsif sclk_negedge = '1' then
            for i in 0 to 6 loop
              read_buffer(i) <= read_buffer(i+1);
            end loop;
            read_buffer(7) <= io_sdata;
            if rx_counter = 7 then
              state <= RX_PARITY;
            end if;
            rx_counter <= rx_counter + 1;
          end if;

        when RX_PARITY =>
          if i_write_register_full = '1' then
            o_tx_failed <= '0';
            o_timeout <= '0';
            o_busy <= '1';
            state <= TX_REQ_TO_SEND;
          elsif sclk_negedge = '1' then
            req_resend <= (xor read_buffer) xnor io_sdata; -- odd parity bit
            state <= RX_STOP;
          end if;

        when RX_STOP =>
          if sclk_negedge = '1' then
            if req_resend = '1' then
              o_busy <= '1';
              state <= TX_REQ_TO_SEND;
            else
              o_timeout <= '0';
              o_read_data <= read_buffer;
              o_read_ready_irq <= '1';
              state <= IDLE;
            end if;
          end if;

        when TX_REQ_TO_SEND =>
          if delay_counter = 100*ONE_US then
            sdata_tx_enable <= '1';
          end if;
          if delay_counter = 15*ONE_MS then
            o_timeout <= '1';
            state <= IDLE;
          elsif sclk_negedge = '1' then
            clear_delay <= '1';
            state <= TX_DATA;
          end if;

        when TX_DATA =>
          if sclk_negedge = '1' then
            if tx_counter = 7 then
              state <= TX_PARITY;
            end if;
            tx_counter <= tx_counter + 1;
          end if;
          if delay_counter = 2*ONE_MS then
            o_timeout <= '1';
            state <= IDLE;
          end if;

        when TX_PARITY =>
          if sclk_negedge = '1' then
            sdata_tx_enable <= '0';
            req_resend <= '0';
            state <= TX_ACK;
          end if;
          if delay_counter = 2*ONE_MS then
            o_timeout <= '1';
            state <= IDLE;
          end if;

        when TX_ACK =>
          if sclk_negedge = '1' then
            o_tx_failed <= io_sdata;
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;
end ps2_interface_arch;
