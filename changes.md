## Changes made to original pyfive_top design presented for MPW-1

- Adapt config.tcl current tools
- Replace `sram_1rw1r_32_256_8_sky130` with `sky130_sram_1kbyte_1rw1r_32x256_8` in config.tcl, verilog files and placement
    > Matthew Guthaus:  the sram_* one is the initial prototype made with the commercial PDK before the MPWs. Use the sky_* one.

    https://open-source-silicon.slack.com/archives/C016ULUQXDF/p1638887299168100?thread_ts=1638527584.163300&cid=C016ULUQXDF


    Modules usring sram:
        usb_ep_buf
        usb_ep_status
        fifo_sync_256x32_sky130
        pyfive_top
        vid_ram_char
        vid_ram_screen

        
- PDN changes in config to accomodate new sram macros and to work with the way the PDN generation works in the new version of the tools
    
- I had to make the design bigger, because I was having issues with cells not being connected (LVS erros) or unsolvable congestions

- Once I managed to harden the design without LVS errors some HOLD violations came up that I solved changing the density a little and using the SLACK_MARGINs openlane configuration variables. I also changed the clock period to 20ns, to be closer to the 48MHz I suppose usb_core needs


        