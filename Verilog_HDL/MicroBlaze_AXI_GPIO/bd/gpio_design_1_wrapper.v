//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Fri Nov 20 15:35:34 2026
//Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
//Command     : generate_target gpio_design_1_wrapper.bd
//Design      : gpio_design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module gpio_design_1_wrapper
   (GPIOA,
    GPIOB,
    GPIOC,
    GPIOD,
    GPIOE,
    reset,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd);
  inout [3:0]GPIOA;
  inout [3:0]GPIOB;
  inout [3:0]GPIOC;
  inout [3:0]GPIOD;
  inout [3:0]GPIOE;
  input reset;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [3:0]GPIOA;
  wire [3:0]GPIOB;
  wire [3:0]GPIOC;
  wire [3:0]GPIOD;
  wire [3:0]GPIOE;
  wire reset;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  gpio_design_1 gpio_design_1_i
       (.GPIOA(GPIOA),
        .GPIOB(GPIOB),
        .GPIOC(GPIOC),
        .GPIOD(GPIOD),
        .GPIOE(GPIOE),
        .reset(reset),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
