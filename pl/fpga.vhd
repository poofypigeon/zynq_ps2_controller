library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpga is
  port (
    -- DDR
    ddr_addr          : inout std_ulogic_vector(14 downto 0);
    ddr_ba            : inout std_ulogic_vector(2 downto 0);
    ddr_cas_n         : inout std_ulogic;
    ddr_ck_n          : inout std_ulogic;
    ddr_ck_p          : inout std_ulogic;
    ddr_cke           : inout std_ulogic;
    ddr_cs_n          : inout std_ulogic;
    ddr_dm            : inout std_ulogic_vector(3 downto 0);
    ddr_dq            : inout std_ulogic_vector(31 downto 0);
    ddr_dqs_n         : inout std_ulogic_vector(3 downto 0);
    ddr_dqs_p         : inout std_ulogic_vector(3 downto 0);
    ddr_odt           : inout std_ulogic;
    ddr_ras_n         : inout std_ulogic;
    ddr_reset_n       : inout std_ulogic;
    ddr_we_n          : inout std_ulogic;
    -- Fixed IO
    fixed_io_ddr_vrn  : inout std_ulogic;
    fixed_io_ddr_vrp  : inout std_ulogic;
    fixed_io_mio      : inout std_ulogic_vector(53 downto 0);
    fixed_io_ps_clk   : inout std_ulogic;
    fixed_io_ps_porb  : inout std_ulogic;
    fixed_io_ps_srstb : inout std_ulogic;
    -- PS/2
    sclk              : inout std_ulogic;
    sdata             : inout std_ulogic
  );
end fpga;

architecture fpga_arch of fpga is
    -- Global
  signal clk           : std_ulogic;
  signal aresetn       : std_ulogic;
  -- Write Address
  signal axi_awvalid   : std_ulogic;
  signal axi_awready   : std_ulogic;
  signal axi_awprot    : std_ulogic_vector(2 downto 0);
  -- Write Data
  signal axi_wvalid    : std_ulogic;
  signal axi_wready    : std_ulogic;
  signal axi_wdata     : std_ulogic_vector(31 downto 0);
  signal axi_wstrb     : std_ulogic_vector(3 downto 0);
  -- Write Response
  signal axi_bvalid    : std_ulogic;
  signal axi_bready    : std_ulogic;
  signal axi_bresp     : std_ulogic_vector(1 downto 0);
  -- Read Address
  signal axi_arvalid   : std_ulogic;
  signal axi_arready   : std_ulogic;
  signal axi_arprot    : std_ulogic_vector(2 downto 0);
  -- Read Data
  signal axi_rvalid    : std_ulogic;
  signal axi_rready    : std_ulogic;
  signal axi_rdata     : std_ulogic_vector(31 downto 0);
  signal axi_rresp     : std_ulogic_vector(1 downto 0);
  -- ID Reflection
  signal axi_awid      : std_ulogic_vector(11 downto 0);
  signal axi_arid      : std_ulogic_vector(11 downto 0);
  signal axi_bid       : std_ulogic_vector(11 downto 0);
  signal axi_rid       : std_ulogic_vector(11 downto 0);
  -- PS/2 Signals
  signal ps2_wdata     : std_ulogic_vector(7 downto 0);
  signal ps2_rdata     : std_ulogic_vector(7 downto 0);
  signal ps2_wvalid    : std_ulogic;
  signal ps2_irq       : std_ulogic;
  signal ps2_busy      : std_ulogic;
  signal ps2_tx_failed : std_ulogic;
  signal ps2_timeout   : std_ulogic;
begin

  id_reflect : process(clk)
  begin
    if rising_edge(clk) then
      if axi_awready = '1' and axi_awvalid = '1' then
        axi_bid <= axi_awid;
      end if;
      if axi_arready = '1' and axi_arvalid = '1' then
        axi_rid <= axi_arid;
      end if;
    end if;
   end process;

  u_zynq_ps : entity work.ps2_controller_wrapper
    port map (
      -- Top Level Signals
      DDR_addr          => ddr_addr,
      DDR_ba            => ddr_ba,
      DDR_cas_n         => ddr_cas_n,
      DDR_ck_n          => ddr_ck_n,
      DDR_ck_p          => ddr_ck_p,
      DDR_cke           => ddr_cke,
      DDR_cs_n          => ddr_cs_n,
      DDR_dm            => ddr_dm,
      DDR_dq            => ddr_dq,
      DDR_dqs_n         => ddr_dqs_n,
      DDR_dqs_p         => ddr_dqs_p,
      DDR_odt           => ddr_odt,
      DDR_ras_n         => ddr_ras_n,
      DDR_reset_n       => ddr_reset_n,
      DDR_we_n          => ddr_we_n,
      FIXED_IO_ddr_vrn  => fixed_io_ddr_vrn,
      FIXED_IO_ddr_vrp  => fixed_io_ddr_vrp,
      FIXED_IO_mio      => fixed_io_mio,
      FIXED_IO_ps_clk   => fixed_io_ps_clk,
      FIXED_IO_ps_porb  => fixed_io_ps_porb,
      FIXED_IO_ps_srstb => fixed_io_ps_srstb,
      -- Interface Signals
      FCLK_CLK0         => clk,
      INQ_F2P           => ps2_irq,
      aresetn(0)        => aresetn,
      M00_AXI_0_awvalid => axi_awvalid,
      M00_AXI_0_awready => axi_awready,
      M00_AXI_0_awprot  => axi_awprot,
      M00_AXI_0_wvalid  => axi_wvalid,
      M00_AXI_0_wready  => axi_wready,
      M00_AXI_0_wdata   => axi_wdata,
      M00_AXI_0_wstrb   => axi_wstrb,
      M00_AXI_0_bvalid  => axi_bvalid,
      M00_AXI_0_bready  => axi_bready,
      M00_AXI_0_bresp   => axi_bresp,
      M00_AXI_0_arvalid => axi_arvalid,
      M00_AXI_0_arready => axi_arready,
      M00_AXI_0_arprot  => axi_arprot,
      M00_AXI_0_rvalid  => axi_rvalid,
      M00_AXI_0_rready  => axi_rready,
      M00_AXI_0_rdata   => axi_rdata,
      M00_AXI_0_rresp   => axi_rresp,
      -- AXI4 => AXI4-Lite Bridge
      M00_AXI_0_awid    => axi_awid,
      M00_AXI_0_arid    => axi_arid,
      M00_AXI_0_bid     => axi_bid,
      M00_AXI_0_rid     => axi_rid,
      M00_AXI_0_rlast   => '1'
    );

  u_axi_s : entity work.axi_ps2_s
    port map (
      i_aclk          => clk,
      i_aresetn       => aresetn,
      i_awvalid       => axi_awvalid,
      o_awready       => axi_awready,
      i_awprot        => axi_awprot,
      i_wvalid        => axi_wvalid,
      o_wready        => axi_wready,
      i_wdata         => axi_wdata,
      i_wstrb         => axi_wstrb,
      o_bvalid        => axi_bvalid,
      i_bready        => axi_bready,
      o_bresp         => axi_bresp,
      i_arvalid       => axi_arvalid,
      o_arready       => axi_arready,
      i_arprot        => axi_arprot,
      o_rvalid        => axi_rvalid,
      i_rready        => axi_rready,
      o_rdata         => axi_rdata,
      o_rresp         => axi_rresp,
      o_ps2_wdata     => ps2_wdata,
      o_ps2_wvalid    => ps2_wvalid,
      i_ps2_rdata     => ps2_rdata,
      i_ps2_busy      => ps2_busy,
      i_ps2_tx_failed => ps2_tx_failed,
      i_ps2_timeout   => ps2_timeout
    );

  u_ps2 : entity work.ps2_interface
    port map (
      i_clk                 => clk,
      i_write_data          => ps2_wdata,
      o_read_data           => ps2_rdata,
      i_write_register_full => ps2_wvalid,
      o_read_ready_irq      => ps2_irq,
      o_busy                => ps2_busy,
      o_tx_failed           => ps2_tx_failed,
      o_timeout             => ps2_timeout,
      io_sclk               => sclk,
      io_sdata              => sdata
    );

end fpga_arch;
