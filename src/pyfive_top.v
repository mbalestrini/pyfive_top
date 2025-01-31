`default_nettype none

`define MPRJ_IO_PADS 38

`define WITH_USB
`define WITH_MIDI
`define WITH_AUDIO
`define WITH_VIDEO
`define WITH_RAM

module pyfive_top (
	// Power
`ifdef USE_POWER_PINS
	input wire VPWR,
	input wire VGND,
`endif

	// Wishbone Slave ports (WB MI A)
	input  wire        wb_clk_i,
	input  wire        wb_rst_i,
	input  wire        wbs_stb_i,
	input  wire        wbs_cyc_i,
	input  wire        wbs_we_i,
	input  wire  [3:0] wbs_sel_i,
	input  wire [31:0] wbs_dat_i,
	input  wire [31:0] wbs_adr_i,
	output wire        wbs_ack_o,
	output wire [31:0] wbs_dat_o,

	// IOs
	input  wire [15:0] io_in,
	output wire [15:0] io_out,
	output wire [15:0] io_oeb,

	// Constants
	output wire zero,
	output wire one
);

	localparam integer N = 5;

	genvar i;


	// Signals
	// -------

	// Local "wishbone"
	wire  [15:0] wb_addr;
	wire  [31:0] wb_rdata [0:N-1];
	wire  [31:0] wb_wdata;
	wire  [ 3:0] wb_wmsk;
	wire         wb_we;
	wire [N-1:0] wb_cyc;
	wire [N-1:0] wb_ack;

	wire [32*N-1:0] wb_rdata_flat;

	// USB
	wire usb_dp_i;
	wire usb_dp_o;
	wire usb_dp_oe;
	wire usb_dn_i;
	wire usb_dn_o;
	wire usb_dn_oe;
	wire usb_pu_o;
	wire usb_pu_oe;

	wire usb_irq;
	wire usb_sof;

	// MIDI uart
	wire midi_tx;
	wire midi_rx;

	// PCM Audio
	wire [1:0] pcm_audio_out;

	// Video
	wire [ 3:0] vid_data;
	wire        vid_vsync;
	wire        vid_hsync;
	wire        vid_de;

	// Clock / Reset
	wire clk;
	wire rst;


	// Constants
	// ---------

	assign zero = 1'b0;
	assign one  = 1'b1;


	// Buffers / Diodes
	// ----------------

	// Wishbone
	wire        wb_clk_ibuf;
	wire        wb_rst_ibuf;
	wire        wbs_stb_ibuf;
	wire        wbs_cyc_ibuf;
	wire        wbs_we_ibuf;
	wire  [3:0] wbs_sel_ibuf;
	wire [31:0] wbs_dat_ibuf;
	wire [23:0] wbs_adr_ibuf;

	wire        wbs_ack_obuf;
	wire [31:0] wbs_dat_obuf;

	// IOs
	wire [15:0] iobuf_in;
	wire [15:0] iobuf_out;
	wire [15:0] iobuf_oeb;

	// Wishbone inputs
`ifdef DIODE
	(* keep *)
	sky130_fd_sc_hd__diode_2 diode_wb_in[63:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.DIODE({
			wb_rst_i,
			wbs_stb_i,
			wbs_cyc_i,
			wbs_we_i,
			wbs_sel_i,
			wbs_dat_i,
			wbs_adr_i[23:0]
		})
	);
`endif

	sky130_fd_sc_hd__buf_8 buf_wb_in [63:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.A({
			wb_rst_i,
			wbs_stb_i,
			wbs_cyc_i,
			wbs_we_i,
			wbs_sel_i,
			wbs_dat_i,
			wbs_adr_i[23:0]
		}),
		.X({
			wb_rst_ibuf,
			wbs_stb_ibuf,
			wbs_cyc_ibuf,
			wbs_we_ibuf,
			wbs_sel_ibuf,
			wbs_dat_ibuf,
			wbs_adr_ibuf
		})
	);

	// Wishbone outputs
	sky130_fd_sc_hd__buf_8 buf_wb_out[32:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.A({wbs_ack_obuf, wbs_dat_obuf}),
		.X({wbs_ack_o,    wbs_dat_o})
	);

`ifdef DIODE
	(* keep *)
	sky130_fd_sc_hd__diode_2 diode_wb_out[32:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.DIODE({wbs_ack_obuf, wbs_dat_obuf})
	);
`endif

	// IOs inputs
`ifdef DIODE
	(* keep *)
	sky130_fd_sc_hd__diode_2 diode_io_in[15:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.DIODE(io_in)
	);
`endif

	sky130_fd_sc_hd__buf_8 buf_io_in[15:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.A(io_in),
		.X(iobuf_in)
	);

	// IOs outputs/enables
	sky130_fd_sc_hd__buf_8 buf_io_out[31:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.A({iobuf_oeb, iobuf_out}),
		.X({io_oeb,    io_out   })
	);

`ifdef DIODE
	(* keep *)
	sky130_fd_sc_hd__diode_2 diode_io_out[31:0] (
`ifdef USE_POWER_PINS
		.VPWR(VPWR),
		.VGND(VGND),
		.VPB(VPWR),
		.VNB(VGND),
`endif
		.DIODE({iobuf_oeb, iobuf_out}),
	);
`endif


	// Bus interface
	// -------------

	wb_splitter #(
		.N(N)
	) bus_if_I (
		.wbu_stb_i (wbs_stb_ibuf),
		.wbu_cyc_i (wbs_cyc_ibuf),
		.wbu_we_i  (wbs_we_ibuf),
		.wbu_sel_i (wbs_sel_ibuf),
		.wbu_dat_i (wbs_dat_ibuf),
		.wbu_adr_i ({8'h00, wbs_adr_ibuf}),
		.wbu_ack_o (wbs_ack_obuf),
		.wbu_dat_o (wbs_dat_obuf),
		.wbd_addr  (wb_addr),
		.wbd_rdata (wb_rdata_flat),
		.wbd_wdata (wb_wdata),
		.wbd_wmsk  (wb_wmsk),
		.wbd_we    (wb_we),
		.wbd_cyc   (wb_cyc),
		.wbd_ack   (wb_ack),
		.clk       (clk),
		.rst       (rst)
	);

	for (i=0; i<N; i=i+1)
		assign wb_rdata_flat[i*32+:32] = wb_rdata[i];


	// USB [0]
	// ---

`ifdef WITH_USB
	usb_sky130 usb_I (
		.pad_dp_i (usb_dp_i),
		.pad_dp_o (usb_dp_o),
		.pad_dp_oe(usb_dp_oe),
		.pad_dn_i (usb_dn_i),
		.pad_dn_o (usb_dn_o),
		.pad_dn_oe(usb_dn_oe),
		.pad_pu_o (usb_pu_o),
		.pad_pu_oe(usb_pu_oe),
		.wb_addr  (wb_addr[13:0]),
		.wb_rdata (wb_rdata[0]),
		.wb_wdata (wb_wdata),
		.wb_we    (wb_we),
		.wb_cyc   (wb_cyc[0]),
		.wb_ack   (wb_ack[0]),
		.irq      (usb_irq),
		.sof      (usb_sof),
		.clk      (clk),
		.rst      (rst)
	);
`else
	assign wb_ack[0] = wb_cyc[0];
	assign wb_rdata[0] = 32'h00000000;
`endif


	// MIDI UART [1]
	// ---------

`ifdef WITH_MIDI
	uart_wb #(
		.DIV_WIDTH(12),
		.DW(32)
	) midi_uart_I (
		.uart_tx  (midi_tx),
		.uart_rx  (midi_rx),
		.wb_addr  (wb_addr[1:0]),
		.wb_rdata (wb_rdata[1]),
		.wb_wdata (wb_wdata),
		.wb_we    (wb_we),
		.wb_cyc   (wb_cyc[1]),
		.wb_ack   (wb_ack[1]),
		.clk      (clk),
		.rst      (rst)
	);
`else
	assign wb_ack[1] = wb_cyc[1];
	assign wb_rdata[1] = 32'h00000000;
`endif


	// Audio [2]
	// -----

`ifdef WITH_AUDIO
	audio audio_I (
		.audio    (pcm_audio_out),
		.wb_addr  (wb_addr[1:0]),
		.wb_rdata (wb_rdata[2]),
		.wb_wdata (wb_wdata),
		.wb_we    (wb_we),
		.wb_cyc   (wb_cyc[2]),
		.wb_ack   (wb_ack[2]),
		.usb_sof  (usb_sof),
		.clk      (clk),
		.rst      (rst)
	);
`else
	assign wb_ack[2] = wb_cyc[2];
	assign wb_rdata[2] = 0;
`endif


	// Video [3]
	// ---------

`ifdef WITH_VIDEO
	vid_top video_I (
		.data     (vid_data),
		.vsync    (vid_vsync),
		.hsync    (vid_hsync),
		.de       (vid_de),
		.wb_addr  (wb_addr[13:0]),
		.wb_rdata (wb_rdata[3]),
		.wb_wdata (wb_wdata),
		.wb_wmsk  (wb_wmsk),
		.wb_we    (wb_we),
		.wb_cyc   (wb_cyc[3]),
		.wb_ack   (wb_ack[3]),
		.clk      (clk),
		.rst      (rst)
	);
`else
	assign wb_ack[3] = wb_cyc[3];
	assign wb_rdata[3] = 0;
`endif


	// RAM [4]
	// -------

`ifdef WITH_RAM

	reg         ram_we;
	reg         ram_ack;
	wire [31:0] ram_rdata;

	always @(posedge clk)
	begin
		ram_we  <= wb_cyc[4] & ~ram_ack & wb_we;
		ram_ack <= wb_cyc[4] & ~ram_ack;
	end

	assign wb_ack[4] = ram_ack;
	assign wb_rdata[4] = ram_ack ? ram_rdata : 32'h00000000;

	sky130_sram_1kbyte_1rw1r_32x256_8 ram_I (
		.clk0   (clk),
		.csb0   (1'b0),
		.web0   (~ram_we),
		.wmask0 (~wb_wmsk),
		.addr0  ( wb_addr[7:0]),
		.din0   ( wb_wdata),
		.dout0  ( ram_rdata),
		.clk1   (1'b0),
		.csb1   (1'b1),
		.addr1  (8'h00),
		.dout1  ()
	);

`else
	assign wb_ack[4] = wb_cyc[4];
	assign wb_rdata[4] = 0;
`endif



	// IO mapping
	// ----------

	// USB
	assign iobuf_out[2:0] = {  usb_pu_o,    usb_dp_o,  usb_dn_o  };
	assign iobuf_oeb[2:0] = { ~usb_pu_oe, ~usb_dp_oe, ~usb_dn_oe };

	assign { usb_dp_i, usb_dn_i } = iobuf_in[1:0];

	assign iobuf_out[3] = usb_sof;
	assign iobuf_oeb[3] = 1'b0;

	// MIDI
	assign midi_rx = iobuf_in[5];
	assign iobuf_out[4] = midi_tx;
	assign iobuf_oeb[5:4] = 2'b10;

	// PCM
	assign iobuf_out[7:6] = pcm_audio_out;
	assign iobuf_oeb[7:6] = 2'b00;

	// Video
	assign iobuf_out[15:8] = { vid_data, vid_vsync, vid_hsync, vid_de, ~clk };
	assign iobuf_oeb[15:8] = 8'h00;


	// Clock / Reset
	// -------------

	assign clk = wb_clk_i;
	assign rst = wb_rst_ibuf;

endmodule	// pyfive_top
