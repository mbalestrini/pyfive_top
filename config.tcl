# Design
set ::env(DESIGN_NAME) "pyfive_top"

set ::env(DESIGN_IS_CORE) 1

# Diode insertion
	#  Spray
set ::env(DIODE_INSERTION_STRATEGY) 0
	# Smart-"ish"
#set ::env(DIODE_INSERTION_STRATEGY) 3
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10


# Timing configuration
set ::env(CLOCK_PERIOD) "20.000"
set ::env(CLOCK_PORT) "wb_clk_i"


# Sources
# -------
# Local sources + no2usb sources
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v $::env(DESIGN_DIR)/no2usb/rtl/*.v]


# Macros
set ::env(VERILOG_FILES_BLACKBOX) "\
	$::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_32x256_8.v"

set ::env(EXTRA_LEFS) "\
	$::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef"

set ::env(EXTRA_GDS_FILES) "\
	$::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds"


# Need blackbox for cells
set ::env(SYNTH_READ_BLACKBOX_LIB) 1



# Floorplanning
# -------------
# Fixed area and pin position
set ::env(FP_SIZING) "absolute"
# set ::env(DIE_AREA) "0 0 2121.2 1242.53"
set ::env(DIE_AREA) "0 0 2270.68 1367.17"

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg


# Halo around the Macros
set ::env(FP_PDN_HORIZONTAL_HALO) 4.5
set ::env(FP_PDN_VERTICAL_HALO) 4.5


# TODO: Check this orginal configuration and see if we need to use it
# # PDN special config
# 	# Ensure we have met4 vertical stripes between SRAMs with
# 	# alternate polarity
# set ::env(FP_PDN_VOFFSET) 7.11
# set ::env(FP_PDN_VPITCH) [expr 861.37 / 7]
# 	# Ensure we have one horizontal stripe in the very top/bot
# 	# row of cell (not sure where 0.24 comes from ...)
# set ::env(FP_PDN_HOFFSET) [expr 50 - (2.72 * 4) + 0.24]
# set ::env(FP_PDN_HPITCH) 180
# set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn.tcl

# set ::env(FP_PDN_VOFFSET) 6
# set ::env(FP_PDN_VPITCH) 131
# set ::env(FP_PDN_HOFFSET) 6
# set ::env(FP_PDN_HPITCH) 202

set ::env(FP_PDN_VOFFSET) 66
set ::env(FP_PDN_VPITCH) 265.15
set ::env(FP_PDN_HOFFSET) 40
set ::env(FP_PDN_HPITCH) 251.0





# Placement
# ---------

set ::env(PL_TARGET_DENSITY) 0.25


# SRAM is 386.480 BY 456.235, place 3 at the top
set ::env(MACRO_PLACEMENT_CFG) $::env(DESIGN_DIR)/macro_placement.cfg



# Routing
# -------
set ::env(ROUTING_CORES) 16


# It's overly worried about congestion, but it's fine
set ::env(GRT_ALLOW_CONGESTION) 1

# Avoid li1 for routing if possible
set ::env(RT_MIN_LAYER) {met1} 

# Don't route on met5
set ::env(RT_MAX_LAYER) {met4}







# NOTE: Not needed anymore?
# # Obstructions
#     # li1 over the SRAM areas
# 	# met5 over the whole design
# set ::env(GLB_RT_OBS) "li1 0.00 22.68 1748.00 486.24, li1 0.00 851.08 1748.00 486.24, met5 0.0 0.0 1748.0 1360.0"


# DRC
# ---

# Can't run DRC on final GDS because SRAM
set ::env(MAGIC_DRC_USE_GDS) 0
set ::env(RUN_MAGIC_DRC) 0
set ::env(QUIT_ON_MAGIC_DRC) 0


# Tape Out
# --------

# TODO: Check why this was needed and decide if is needed
# set ::env(MAGIC_ZEROIZE_ORIGIN) 0






# ^^^ Until this point were the original configuration parameters in the project ^^^

# set ::env(VDD_NETS) [list {vccd1}]
# set ::env(GND_NETS) [list {vssd1}] 

# set ::env(FP_PDN_MACRO_HOOKS) "\
# 	audio_I.fifo_I.ram_I vccd1 vssd1 \
# 	video_I.chr_I.ram_I vccd1 vssd1 \
# 	video_I.scr_I.ram_lo_I vccd1 vssd1 \
# 	video_I.scr_I.ram_hi_I vccd1 vssd1 \
# 	ram_I vccd1 vssd1 \							  
# 	usb_I.core_I.rx_buf_I.ram_I vccd1 vssd1 \		 
# 	usb_I.core_I.ep_status_I.ram_I vccd1 vssd1 \	 
# 	usb_I.core_I.tx_buf_I.ram_I vccd1 vssd1 \		
# 	" 

# save some time
# set ::env(RUN_KLAYOUT_XOR) 0
# set ::env(RUN_KLAYOUT_DRC) 0 	



# Specifies a time margin for the slack when fixing hold violations. Normally the resizer will stop when it reaches zero slack. This option allows you to overfix.
# (Default: 0.1ns.)
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.5

# Specifies a time margin for the slack when fixing hold violations. Normally the resizer will stop when it reaches zero slack. This option allows you to overfix.
# (Default: 0.05ns)
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.5

# Specifies a time margin for the slack when fixing setup violations.
# (Default: 0.05ns)
# set ::env(PL_RESIZER_SETUP_SLACK_MARGIN) 0.3

# Specifies a time margin for the slack when fixing setup violations.
# (Default: 0.025ns)
# set ::env(GLB_RESIZER_SETUP_SLACK_MARGIN) 0.3



# Cell library specific config
# ----------------------------

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
