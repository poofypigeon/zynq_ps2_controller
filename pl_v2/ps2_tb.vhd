library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_tb is
end ps2_tb;

architecture ps2_tb_arch of ps2_tb is
  constant CLK_PERIOD   : time := 62.5 ns;
  constant PS2_PERIOD   : time := 59.8 us;

  constant TEST_BYTE    : std_logic_vector(7 downto 0) := X"9A";

  signal tx_test_buffer : std_ulogic_vector(7 downto 0) := (others => '0');

  signal clk            : std_ulogic := '0';
  signal fsm_reset      : std_ulogic := '0';
  -- ps/2 signals
  signal i_sclk         : std_ulogic := '1';
  signal o_sclk         : std_ulogic;
  signal t_sclk         : std_ulogic;
  signal i_sdata        : std_ulogic := '1';
  signal o_sdata        : std_ulogic;
  signal t_sdata        : std_ulogic;
  -- tx buffer signals  
  signal tx_buffer      : std_ulogic_vector(7 downto 0) := (others => '0');
  signal tx_request     : std_ulogic := '0';
  -- rx buffer signals  
  signal rx_buffer      : std_ulogic_vector(7 downto 0) := (others => '0');
  signal rx_interrupt   : std_ulogic;

begin

  uut : entity work.ps2
    port map (
      i_clk          => clk,
      i_fsm_reset    => fsm_reset,
      i_sclk         => i_sclk,
      o_sclk         => o_sclk,
      t_sclk         => t_sclk,
      i_sdata        => i_sdata,
      o_sdata        => o_sdata,
      t_sdata        => t_sdata,
      i_tx_buffer    => tx_buffer,
      i_tx_request   => tx_request,
      o_rx_buffer    => rx_buffer,
      o_rx_interrupt => rx_interrupt
    );

  process
  begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
  end process;

  process
  begin

    ------------------------------------------------------------------
    -- TEST 1 -- SUCCESSFUL RX
    ------------------------------------------------------------------
    report "TEST 1 -- SUCCESSFUL RX";
    -- WAIT
    wait for PS2_PERIOD*4;
    -- SEND START
    wait for PS2_PERIOD/4;
    i_sdata <= '0';
    wait for PS2_PERIOD/4;
    i_sclk  <= '0';
    wait for PS2_PERIOD/2;
    i_sclk  <= '1';
    -- SEND BYTE
    for i in 0 to 7 loop
      wait for PS2_PERIOD/4;
      i_sdata <= TEST_BYTE(i);
      wait for PS2_PERIOD/4;
      i_sclk <= '0';
      wait for PS2_PERIOD/2;
      i_sclk <= '1';
    end loop;
    -- SEND PARITY
    wait for PS2_PERIOD/4;
    i_sdata <= xnor TEST_BYTE;
    wait for PS2_PERIOD/4;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    i_sclk <= '1';
    -- SEND STOP
    wait for PS2_PERIOD/4;
    i_sdata <= '1';
    wait for PS2_PERIOD/4;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    i_sclk <= '1';

    assert rx_buffer = TEST_BYTE report "incorrect byte recieved" severity failure;
    report "TEST 1 -- PASSED";

    ------------------------------------------------------------------
    -- TEST 2 : SUCCESSFUL TX
    ------------------------------------------------------------------
    report "TEST 2 -- SUCCESSFUL TX";
    -- WAIT
    wait for PS2_PERIOD*4;
    -- TRIGGER TX
    tx_buffer  <= TEST_BYTE;
    tx_request <= '1';
    wait for CLK_PERIOD;
    tx_request <= '0';
    -- WAIT FOR TX REQUEST TO SEND
    wait on t_sclk;
    -- READ TX DATA
    wait for PS2_PERIOD/2;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    for i in 0 to 7 loop
      i_sclk <= '1';
      wait for PS2_PERIOD/2;
      tx_test_buffer <= o_sdata & tx_test_buffer(7 downto 1);
      report "read " & std_logic'image(o_sdata);
      i_sclk <= '0';
      wait for PS2_PERIOD/2;
    end loop;
    assert tx_test_buffer = TEST_BYTE report "incorrect tx byte" severity failure;
    -- TEST PARITY 
    assert o_sdata = xor tx_test_buffer report "incorrect tx parity byte" severity failure;
    i_sclk <= '1';
    wait for PS2_PERIOD/2;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    -- STOP
    assert t_sdata = '0' report "sdata not released for STOP" severity failure;
    i_sdata <= '0';
    i_sclk <= '1';
    wait for PS2_PERIOD/2;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    i_sclk <= '1';
    i_sdata <= '1';
    report "TEST 2 -- PASSED";

    ------------------------------------------------------------------
    -- TEST 3 -- RX WITH INCORRECT PARITY
    ------------------------------------------------------------------
    report "TEST 3 -- RX WITH INCORRECT PARITY";
    -- WAIT
    wait for PS2_PERIOD*4;
    -- SEND START
    wait for PS2_PERIOD/4;
    i_sdata <= '0';
    wait for PS2_PERIOD/4;
    i_sclk  <= '0';
    wait for PS2_PERIOD/2;
    i_sclk  <= '1';
    -- SEND BYTE
    for i in 0 to 7 loop
      wait for PS2_PERIOD/4;
      i_sdata <= TEST_BYTE(i);
      wait for PS2_PERIOD/4;
      i_sclk <= '0';
      wait for PS2_PERIOD/2;
      i_sclk <= '1';
    end loop;
    -- SEND PARITY
    wait for PS2_PERIOD/4;
    i_sdata <= xor TEST_BYTE;
    wait for PS2_PERIOD/4;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    i_sclk <= '1';
    -- SEND STOP
    wait for PS2_PERIOD/4;
    i_sdata <= '1';
    wait for PS2_PERIOD/4;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    i_sclk <= '1';
    -- WAIT FOR TX REQUEST TO SEND
    wait until falling_edge(t_sclk);
    -- READ TX DATA
    wait for PS2_PERIOD/2;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    for i in 0 to 7 loop
      i_sclk <= '1';
      wait for PS2_PERIOD/2;
      tx_test_buffer <= o_sdata & tx_test_buffer(7 downto 1);
      report "read " & std_logic'image(o_sdata);
      i_sclk <= '0';
      wait for PS2_PERIOD/2;
    end loop;
    assert tx_test_buffer = X"FE" report "incorrect tx byte" severity failure;
    -- TEST PARITY 
    assert o_sdata = xor tx_test_buffer report "incorrect tx parity byte" severity failure;
    i_sclk <= '1';
    wait for PS2_PERIOD/2;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    -- STOP
    assert t_sdata = '0' report "sdata not released for STOP" severity failure;
    i_sdata <= '0';
    i_sclk <= '1';
    wait for PS2_PERIOD/2;
    i_sclk <= '0';
    wait for PS2_PERIOD/2;
    i_sclk <= '1';
    i_sdata <= '1';
    report "TEST 3 -- PASSED";

    ------------------------------------------------------------------
    -- TEST 4 : TIMEOUT
    ------------------------------------------------------------------
    report "TEST 4 -- TIMEOUT";
    -- WAIT
    wait for PS2_PERIOD*4;
    -- TRIGGER TX
    tx_buffer  <= TEST_BYTE;
    tx_request <= '1';
    wait for CLK_PERIOD;
    tx_request <= '0';

    wait;

  end process;
end ps2_tb_arch;
