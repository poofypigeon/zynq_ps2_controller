library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_ps2_s is
  generic (DATA_WIDTH : natural := 32);
  port (
    -- Global
    i_aclk          : in  std_ulogic;
    i_aresetn       : in  std_ulogic;
    -- Write Address
    i_awvalid       : in  std_ulogic;
    o_awready       : out std_ulogic := '1';
    i_awprot        : in  std_ulogic_vector(2 downto 0);
    -- Write Data
    i_wvalid        : in  std_ulogic;
    o_wready        : out std_ulogic := '0';
    i_wdata         : in  std_ulogic_vector(DATA_WIDTH-1 downto 0);
    i_wstrb         : in  std_ulogic_vector((DATA_WIDTH/8)-1 downto 0);
    -- Write Response
    o_bvalid        : out std_ulogic := '0';
    i_bready        : in  std_ulogic;
    o_bresp         : out std_ulogic_vector(1 downto 0);
    -- Read Address
    i_arvalid       : in  std_ulogic;
    o_arready       : out std_ulogic := '1';
    i_arprot        : in  std_ulogic_vector(2 downto 0);
    -- Read Data
    o_rvalid        : out std_ulogic := '0';
    i_rready        : in  std_ulogic;
    o_rdata         : out std_ulogic_vector(DATA_WIDTH-1 downto 0);
    o_rresp         : out std_ulogic_vector(1 downto 0);
    -- PS/2 Signals
    o_ps2_wdata     : out std_ulogic_vector(7 downto 0) := (others => '0');
    o_ps2_wvalid    : out std_ulogic := '0';
    i_ps2_rdata     : in  std_ulogic_vector(7 downto 0);
    i_ps2_busy      : in  std_ulogic;
    i_ps2_tx_failed : in std_ulogic;
    i_ps2_timeout   : in std_ulogic
  );
end axi_ps2_s;

architecture axi_ps2_s_arch of axi_ps2_s is
  constant C_OKAY   : std_ulogic_vector(1 downto 0) := b"00";
  constant C_EXOKAY : std_ulogic_vector(1 downto 0) := b"01"; -- not supported by axi-lite
  constant C_SLVERR : std_ulogic_vector(1 downto 0) := b"10";
  constant C_DECERR : std_ulogic_vector(1 downto 0) := b"11";
  
  signal write_data : std_ulogic_vector(7 downto 0);

  attribute mark_debug : string;
  attribute mark_debug of all : signal is "true";
begin

  awready_state : process(i_aclk)
  begin
    if rising_edge(i_aclk) then
      if o_awready = '1' and i_awvalid = '1' then
        o_awready <= '0';
      elsif o_wready = '1' and i_wvalid = '1' then
        o_awready <= '1';
      end if;
    end if;
  end process;

  wready_state : process(i_aclk)
  begin
    if rising_edge(i_aclk) then
      if o_awready = '1' and i_awvalid = '1' then
        o_wready <= '1';
      elsif o_wready = '1' and i_wvalid = '1' then
        o_wready <= '0';
      end if;
    end if;
  end process;

  bvalid_state : process(i_aclk)
  begin
    if rising_edge(i_aclk) then
      if i_aresetn = '0' then
        o_bvalid <= '0';
      elsif o_wready = '1' and i_wvalid = '1' then
        o_bresp  <= C_OKAY;
        o_bvalid <= '1';
      elsif o_bvalid = '1' and i_bready = '1' then
        o_bvalid <= '0';
      end if;
    end if;
  end process;

  write_reg : process(i_aclk)
  begin
    if rising_edge(i_aclk) then
      if i_aresetn = '0' then
        o_ps2_wdata <= (others => '0');
      elsif o_wready = '1' and i_wvalid = '1' then
        o_ps2_wdata <= i_wdata(7 downto 0);
        o_ps2_wvalid <= '1';
      elsif i_ps2_busy <= '1' then
        o_ps2_wvalid <= '0';
      end if;
    end if;
  end process;

  read_state : process(i_aclk)
  begin
    if rising_edge(i_aclk) then
      if o_arready = '1' and i_arvalid = '1' then
        o_arready <= '0';
        o_rvalid  <= '1';
        o_rresp   <= C_OKAY;
        o_rdata   <= (
          18          => i_ps2_timeout,
          17          => i_ps2_tx_failed,
          16          => i_ps2_busy,
          15 downto 8 => i_ps2_rdata,
          7 downto 0  => o_ps2_wdata,
          others      => '0'
        );
      elsif i_rready = '1' and o_rvalid = '1' then
        o_arready <= '1';
        o_rvalid  <= '0';
      end if;
    end if;
  end process;

end axi_ps2_s_arch;
