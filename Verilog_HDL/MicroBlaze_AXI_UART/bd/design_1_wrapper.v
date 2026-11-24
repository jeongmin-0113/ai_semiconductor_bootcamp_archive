//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Tue Nov 24 14:35:13 2026
//Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (btn_tri_io,
    fnd_com_tri_io,
    fnd_font_tri_io,
    led_tri_io,
    reset,
    sw_tri_io,
    sys_clock,
    uart_rx,
    uart_tx,
    usb_uart_rxd,
    usb_uart_txd);
  inout [3:0]btn_tri_io;
  inout [3:0]fnd_com_tri_io;
  inout [7:0]fnd_font_tri_io;
  inout [15:0]led_tri_io;
  input reset;
  inout [15:0]sw_tri_io;
  input sys_clock;
  input uart_rx;
  output uart_tx;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [0:0]btn_tri_i_0;
  wire [1:1]btn_tri_i_1;
  wire [2:2]btn_tri_i_2;
  wire [3:3]btn_tri_i_3;
  wire [0:0]btn_tri_io_0;
  wire [1:1]btn_tri_io_1;
  wire [2:2]btn_tri_io_2;
  wire [3:3]btn_tri_io_3;
  wire [0:0]btn_tri_o_0;
  wire [1:1]btn_tri_o_1;
  wire [2:2]btn_tri_o_2;
  wire [3:3]btn_tri_o_3;
  wire [0:0]btn_tri_t_0;
  wire [1:1]btn_tri_t_1;
  wire [2:2]btn_tri_t_2;
  wire [3:3]btn_tri_t_3;
  wire [0:0]fnd_com_tri_i_0;
  wire [1:1]fnd_com_tri_i_1;
  wire [2:2]fnd_com_tri_i_2;
  wire [3:3]fnd_com_tri_i_3;
  wire [0:0]fnd_com_tri_io_0;
  wire [1:1]fnd_com_tri_io_1;
  wire [2:2]fnd_com_tri_io_2;
  wire [3:3]fnd_com_tri_io_3;
  wire [0:0]fnd_com_tri_o_0;
  wire [1:1]fnd_com_tri_o_1;
  wire [2:2]fnd_com_tri_o_2;
  wire [3:3]fnd_com_tri_o_3;
  wire [0:0]fnd_com_tri_t_0;
  wire [1:1]fnd_com_tri_t_1;
  wire [2:2]fnd_com_tri_t_2;
  wire [3:3]fnd_com_tri_t_3;
  wire [0:0]fnd_font_tri_i_0;
  wire [1:1]fnd_font_tri_i_1;
  wire [2:2]fnd_font_tri_i_2;
  wire [3:3]fnd_font_tri_i_3;
  wire [4:4]fnd_font_tri_i_4;
  wire [5:5]fnd_font_tri_i_5;
  wire [6:6]fnd_font_tri_i_6;
  wire [7:7]fnd_font_tri_i_7;
  wire [0:0]fnd_font_tri_io_0;
  wire [1:1]fnd_font_tri_io_1;
  wire [2:2]fnd_font_tri_io_2;
  wire [3:3]fnd_font_tri_io_3;
  wire [4:4]fnd_font_tri_io_4;
  wire [5:5]fnd_font_tri_io_5;
  wire [6:6]fnd_font_tri_io_6;
  wire [7:7]fnd_font_tri_io_7;
  wire [0:0]fnd_font_tri_o_0;
  wire [1:1]fnd_font_tri_o_1;
  wire [2:2]fnd_font_tri_o_2;
  wire [3:3]fnd_font_tri_o_3;
  wire [4:4]fnd_font_tri_o_4;
  wire [5:5]fnd_font_tri_o_5;
  wire [6:6]fnd_font_tri_o_6;
  wire [7:7]fnd_font_tri_o_7;
  wire [0:0]fnd_font_tri_t_0;
  wire [1:1]fnd_font_tri_t_1;
  wire [2:2]fnd_font_tri_t_2;
  wire [3:3]fnd_font_tri_t_3;
  wire [4:4]fnd_font_tri_t_4;
  wire [5:5]fnd_font_tri_t_5;
  wire [6:6]fnd_font_tri_t_6;
  wire [7:7]fnd_font_tri_t_7;
  wire [0:0]led_tri_i_0;
  wire [1:1]led_tri_i_1;
  wire [10:10]led_tri_i_10;
  wire [11:11]led_tri_i_11;
  wire [12:12]led_tri_i_12;
  wire [13:13]led_tri_i_13;
  wire [14:14]led_tri_i_14;
  wire [15:15]led_tri_i_15;
  wire [2:2]led_tri_i_2;
  wire [3:3]led_tri_i_3;
  wire [4:4]led_tri_i_4;
  wire [5:5]led_tri_i_5;
  wire [6:6]led_tri_i_6;
  wire [7:7]led_tri_i_7;
  wire [8:8]led_tri_i_8;
  wire [9:9]led_tri_i_9;
  wire [0:0]led_tri_io_0;
  wire [1:1]led_tri_io_1;
  wire [10:10]led_tri_io_10;
  wire [11:11]led_tri_io_11;
  wire [12:12]led_tri_io_12;
  wire [13:13]led_tri_io_13;
  wire [14:14]led_tri_io_14;
  wire [15:15]led_tri_io_15;
  wire [2:2]led_tri_io_2;
  wire [3:3]led_tri_io_3;
  wire [4:4]led_tri_io_4;
  wire [5:5]led_tri_io_5;
  wire [6:6]led_tri_io_6;
  wire [7:7]led_tri_io_7;
  wire [8:8]led_tri_io_8;
  wire [9:9]led_tri_io_9;
  wire [0:0]led_tri_o_0;
  wire [1:1]led_tri_o_1;
  wire [10:10]led_tri_o_10;
  wire [11:11]led_tri_o_11;
  wire [12:12]led_tri_o_12;
  wire [13:13]led_tri_o_13;
  wire [14:14]led_tri_o_14;
  wire [15:15]led_tri_o_15;
  wire [2:2]led_tri_o_2;
  wire [3:3]led_tri_o_3;
  wire [4:4]led_tri_o_4;
  wire [5:5]led_tri_o_5;
  wire [6:6]led_tri_o_6;
  wire [7:7]led_tri_o_7;
  wire [8:8]led_tri_o_8;
  wire [9:9]led_tri_o_9;
  wire [0:0]led_tri_t_0;
  wire [1:1]led_tri_t_1;
  wire [10:10]led_tri_t_10;
  wire [11:11]led_tri_t_11;
  wire [12:12]led_tri_t_12;
  wire [13:13]led_tri_t_13;
  wire [14:14]led_tri_t_14;
  wire [15:15]led_tri_t_15;
  wire [2:2]led_tri_t_2;
  wire [3:3]led_tri_t_3;
  wire [4:4]led_tri_t_4;
  wire [5:5]led_tri_t_5;
  wire [6:6]led_tri_t_6;
  wire [7:7]led_tri_t_7;
  wire [8:8]led_tri_t_8;
  wire [9:9]led_tri_t_9;
  wire reset;
  wire [0:0]sw_tri_i_0;
  wire [1:1]sw_tri_i_1;
  wire [10:10]sw_tri_i_10;
  wire [11:11]sw_tri_i_11;
  wire [12:12]sw_tri_i_12;
  wire [13:13]sw_tri_i_13;
  wire [14:14]sw_tri_i_14;
  wire [15:15]sw_tri_i_15;
  wire [2:2]sw_tri_i_2;
  wire [3:3]sw_tri_i_3;
  wire [4:4]sw_tri_i_4;
  wire [5:5]sw_tri_i_5;
  wire [6:6]sw_tri_i_6;
  wire [7:7]sw_tri_i_7;
  wire [8:8]sw_tri_i_8;
  wire [9:9]sw_tri_i_9;
  wire [0:0]sw_tri_io_0;
  wire [1:1]sw_tri_io_1;
  wire [10:10]sw_tri_io_10;
  wire [11:11]sw_tri_io_11;
  wire [12:12]sw_tri_io_12;
  wire [13:13]sw_tri_io_13;
  wire [14:14]sw_tri_io_14;
  wire [15:15]sw_tri_io_15;
  wire [2:2]sw_tri_io_2;
  wire [3:3]sw_tri_io_3;
  wire [4:4]sw_tri_io_4;
  wire [5:5]sw_tri_io_5;
  wire [6:6]sw_tri_io_6;
  wire [7:7]sw_tri_io_7;
  wire [8:8]sw_tri_io_8;
  wire [9:9]sw_tri_io_9;
  wire [0:0]sw_tri_o_0;
  wire [1:1]sw_tri_o_1;
  wire [10:10]sw_tri_o_10;
  wire [11:11]sw_tri_o_11;
  wire [12:12]sw_tri_o_12;
  wire [13:13]sw_tri_o_13;
  wire [14:14]sw_tri_o_14;
  wire [15:15]sw_tri_o_15;
  wire [2:2]sw_tri_o_2;
  wire [3:3]sw_tri_o_3;
  wire [4:4]sw_tri_o_4;
  wire [5:5]sw_tri_o_5;
  wire [6:6]sw_tri_o_6;
  wire [7:7]sw_tri_o_7;
  wire [8:8]sw_tri_o_8;
  wire [9:9]sw_tri_o_9;
  wire [0:0]sw_tri_t_0;
  wire [1:1]sw_tri_t_1;
  wire [10:10]sw_tri_t_10;
  wire [11:11]sw_tri_t_11;
  wire [12:12]sw_tri_t_12;
  wire [13:13]sw_tri_t_13;
  wire [14:14]sw_tri_t_14;
  wire [15:15]sw_tri_t_15;
  wire [2:2]sw_tri_t_2;
  wire [3:3]sw_tri_t_3;
  wire [4:4]sw_tri_t_4;
  wire [5:5]sw_tri_t_5;
  wire [6:6]sw_tri_t_6;
  wire [7:7]sw_tri_t_7;
  wire [8:8]sw_tri_t_8;
  wire [9:9]sw_tri_t_9;
  wire sys_clock;
  wire uart_rx;
  wire uart_tx;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  IOBUF btn_tri_iobuf_0
       (.I(btn_tri_o_0),
        .IO(btn_tri_io[0]),
        .O(btn_tri_i_0),
        .T(btn_tri_t_0));
  IOBUF btn_tri_iobuf_1
       (.I(btn_tri_o_1),
        .IO(btn_tri_io[1]),
        .O(btn_tri_i_1),
        .T(btn_tri_t_1));
  IOBUF btn_tri_iobuf_2
       (.I(btn_tri_o_2),
        .IO(btn_tri_io[2]),
        .O(btn_tri_i_2),
        .T(btn_tri_t_2));
  IOBUF btn_tri_iobuf_3
       (.I(btn_tri_o_3),
        .IO(btn_tri_io[3]),
        .O(btn_tri_i_3),
        .T(btn_tri_t_3));
  design_1 design_1_i
       (.btn_tri_i({btn_tri_i_3,btn_tri_i_2,btn_tri_i_1,btn_tri_i_0}),
        .btn_tri_o({btn_tri_o_3,btn_tri_o_2,btn_tri_o_1,btn_tri_o_0}),
        .btn_tri_t({btn_tri_t_3,btn_tri_t_2,btn_tri_t_1,btn_tri_t_0}),
        .fnd_com_tri_i({fnd_com_tri_i_3,fnd_com_tri_i_2,fnd_com_tri_i_1,fnd_com_tri_i_0}),
        .fnd_com_tri_o({fnd_com_tri_o_3,fnd_com_tri_o_2,fnd_com_tri_o_1,fnd_com_tri_o_0}),
        .fnd_com_tri_t({fnd_com_tri_t_3,fnd_com_tri_t_2,fnd_com_tri_t_1,fnd_com_tri_t_0}),
        .fnd_font_tri_i({fnd_font_tri_i_7,fnd_font_tri_i_6,fnd_font_tri_i_5,fnd_font_tri_i_4,fnd_font_tri_i_3,fnd_font_tri_i_2,fnd_font_tri_i_1,fnd_font_tri_i_0}),
        .fnd_font_tri_o({fnd_font_tri_o_7,fnd_font_tri_o_6,fnd_font_tri_o_5,fnd_font_tri_o_4,fnd_font_tri_o_3,fnd_font_tri_o_2,fnd_font_tri_o_1,fnd_font_tri_o_0}),
        .fnd_font_tri_t({fnd_font_tri_t_7,fnd_font_tri_t_6,fnd_font_tri_t_5,fnd_font_tri_t_4,fnd_font_tri_t_3,fnd_font_tri_t_2,fnd_font_tri_t_1,fnd_font_tri_t_0}),
        .led_tri_i({led_tri_i_15,led_tri_i_14,led_tri_i_13,led_tri_i_12,led_tri_i_11,led_tri_i_10,led_tri_i_9,led_tri_i_8,led_tri_i_7,led_tri_i_6,led_tri_i_5,led_tri_i_4,led_tri_i_3,led_tri_i_2,led_tri_i_1,led_tri_i_0}),
        .led_tri_o({led_tri_o_15,led_tri_o_14,led_tri_o_13,led_tri_o_12,led_tri_o_11,led_tri_o_10,led_tri_o_9,led_tri_o_8,led_tri_o_7,led_tri_o_6,led_tri_o_5,led_tri_o_4,led_tri_o_3,led_tri_o_2,led_tri_o_1,led_tri_o_0}),
        .led_tri_t({led_tri_t_15,led_tri_t_14,led_tri_t_13,led_tri_t_12,led_tri_t_11,led_tri_t_10,led_tri_t_9,led_tri_t_8,led_tri_t_7,led_tri_t_6,led_tri_t_5,led_tri_t_4,led_tri_t_3,led_tri_t_2,led_tri_t_1,led_tri_t_0}),
        .reset(reset),
        .sw_tri_i({sw_tri_i_15,sw_tri_i_14,sw_tri_i_13,sw_tri_i_12,sw_tri_i_11,sw_tri_i_10,sw_tri_i_9,sw_tri_i_8,sw_tri_i_7,sw_tri_i_6,sw_tri_i_5,sw_tri_i_4,sw_tri_i_3,sw_tri_i_2,sw_tri_i_1,sw_tri_i_0}),
        .sw_tri_o({sw_tri_o_15,sw_tri_o_14,sw_tri_o_13,sw_tri_o_12,sw_tri_o_11,sw_tri_o_10,sw_tri_o_9,sw_tri_o_8,sw_tri_o_7,sw_tri_o_6,sw_tri_o_5,sw_tri_o_4,sw_tri_o_3,sw_tri_o_2,sw_tri_o_1,sw_tri_o_0}),
        .sw_tri_t({sw_tri_t_15,sw_tri_t_14,sw_tri_t_13,sw_tri_t_12,sw_tri_t_11,sw_tri_t_10,sw_tri_t_9,sw_tri_t_8,sw_tri_t_7,sw_tri_t_6,sw_tri_t_5,sw_tri_t_4,sw_tri_t_3,sw_tri_t_2,sw_tri_t_1,sw_tri_t_0}),
        .sys_clock(sys_clock),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
  IOBUF fnd_com_tri_iobuf_0
       (.I(fnd_com_tri_o_0),
        .IO(fnd_com_tri_io[0]),
        .O(fnd_com_tri_i_0),
        .T(fnd_com_tri_t_0));
  IOBUF fnd_com_tri_iobuf_1
       (.I(fnd_com_tri_o_1),
        .IO(fnd_com_tri_io[1]),
        .O(fnd_com_tri_i_1),
        .T(fnd_com_tri_t_1));
  IOBUF fnd_com_tri_iobuf_2
       (.I(fnd_com_tri_o_2),
        .IO(fnd_com_tri_io[2]),
        .O(fnd_com_tri_i_2),
        .T(fnd_com_tri_t_2));
  IOBUF fnd_com_tri_iobuf_3
       (.I(fnd_com_tri_o_3),
        .IO(fnd_com_tri_io[3]),
        .O(fnd_com_tri_i_3),
        .T(fnd_com_tri_t_3));
  IOBUF fnd_font_tri_iobuf_0
       (.I(fnd_font_tri_o_0),
        .IO(fnd_font_tri_io[0]),
        .O(fnd_font_tri_i_0),
        .T(fnd_font_tri_t_0));
  IOBUF fnd_font_tri_iobuf_1
       (.I(fnd_font_tri_o_1),
        .IO(fnd_font_tri_io[1]),
        .O(fnd_font_tri_i_1),
        .T(fnd_font_tri_t_1));
  IOBUF fnd_font_tri_iobuf_2
       (.I(fnd_font_tri_o_2),
        .IO(fnd_font_tri_io[2]),
        .O(fnd_font_tri_i_2),
        .T(fnd_font_tri_t_2));
  IOBUF fnd_font_tri_iobuf_3
       (.I(fnd_font_tri_o_3),
        .IO(fnd_font_tri_io[3]),
        .O(fnd_font_tri_i_3),
        .T(fnd_font_tri_t_3));
  IOBUF fnd_font_tri_iobuf_4
       (.I(fnd_font_tri_o_4),
        .IO(fnd_font_tri_io[4]),
        .O(fnd_font_tri_i_4),
        .T(fnd_font_tri_t_4));
  IOBUF fnd_font_tri_iobuf_5
       (.I(fnd_font_tri_o_5),
        .IO(fnd_font_tri_io[5]),
        .O(fnd_font_tri_i_5),
        .T(fnd_font_tri_t_5));
  IOBUF fnd_font_tri_iobuf_6
       (.I(fnd_font_tri_o_6),
        .IO(fnd_font_tri_io[6]),
        .O(fnd_font_tri_i_6),
        .T(fnd_font_tri_t_6));
  IOBUF fnd_font_tri_iobuf_7
       (.I(fnd_font_tri_o_7),
        .IO(fnd_font_tri_io[7]),
        .O(fnd_font_tri_i_7),
        .T(fnd_font_tri_t_7));
  IOBUF led_tri_iobuf_0
       (.I(led_tri_o_0),
        .IO(led_tri_io[0]),
        .O(led_tri_i_0),
        .T(led_tri_t_0));
  IOBUF led_tri_iobuf_1
       (.I(led_tri_o_1),
        .IO(led_tri_io[1]),
        .O(led_tri_i_1),
        .T(led_tri_t_1));
  IOBUF led_tri_iobuf_10
       (.I(led_tri_o_10),
        .IO(led_tri_io[10]),
        .O(led_tri_i_10),
        .T(led_tri_t_10));
  IOBUF led_tri_iobuf_11
       (.I(led_tri_o_11),
        .IO(led_tri_io[11]),
        .O(led_tri_i_11),
        .T(led_tri_t_11));
  IOBUF led_tri_iobuf_12
       (.I(led_tri_o_12),
        .IO(led_tri_io[12]),
        .O(led_tri_i_12),
        .T(led_tri_t_12));
  IOBUF led_tri_iobuf_13
       (.I(led_tri_o_13),
        .IO(led_tri_io[13]),
        .O(led_tri_i_13),
        .T(led_tri_t_13));
  IOBUF led_tri_iobuf_14
       (.I(led_tri_o_14),
        .IO(led_tri_io[14]),
        .O(led_tri_i_14),
        .T(led_tri_t_14));
  IOBUF led_tri_iobuf_15
       (.I(led_tri_o_15),
        .IO(led_tri_io[15]),
        .O(led_tri_i_15),
        .T(led_tri_t_15));
  IOBUF led_tri_iobuf_2
       (.I(led_tri_o_2),
        .IO(led_tri_io[2]),
        .O(led_tri_i_2),
        .T(led_tri_t_2));
  IOBUF led_tri_iobuf_3
       (.I(led_tri_o_3),
        .IO(led_tri_io[3]),
        .O(led_tri_i_3),
        .T(led_tri_t_3));
  IOBUF led_tri_iobuf_4
       (.I(led_tri_o_4),
        .IO(led_tri_io[4]),
        .O(led_tri_i_4),
        .T(led_tri_t_4));
  IOBUF led_tri_iobuf_5
       (.I(led_tri_o_5),
        .IO(led_tri_io[5]),
        .O(led_tri_i_5),
        .T(led_tri_t_5));
  IOBUF led_tri_iobuf_6
       (.I(led_tri_o_6),
        .IO(led_tri_io[6]),
        .O(led_tri_i_6),
        .T(led_tri_t_6));
  IOBUF led_tri_iobuf_7
       (.I(led_tri_o_7),
        .IO(led_tri_io[7]),
        .O(led_tri_i_7),
        .T(led_tri_t_7));
  IOBUF led_tri_iobuf_8
       (.I(led_tri_o_8),
        .IO(led_tri_io[8]),
        .O(led_tri_i_8),
        .T(led_tri_t_8));
  IOBUF led_tri_iobuf_9
       (.I(led_tri_o_9),
        .IO(led_tri_io[9]),
        .O(led_tri_i_9),
        .T(led_tri_t_9));
  IOBUF sw_tri_iobuf_0
       (.I(sw_tri_o_0),
        .IO(sw_tri_io[0]),
        .O(sw_tri_i_0),
        .T(sw_tri_t_0));
  IOBUF sw_tri_iobuf_1
       (.I(sw_tri_o_1),
        .IO(sw_tri_io[1]),
        .O(sw_tri_i_1),
        .T(sw_tri_t_1));
  IOBUF sw_tri_iobuf_10
       (.I(sw_tri_o_10),
        .IO(sw_tri_io[10]),
        .O(sw_tri_i_10),
        .T(sw_tri_t_10));
  IOBUF sw_tri_iobuf_11
       (.I(sw_tri_o_11),
        .IO(sw_tri_io[11]),
        .O(sw_tri_i_11),
        .T(sw_tri_t_11));
  IOBUF sw_tri_iobuf_12
       (.I(sw_tri_o_12),
        .IO(sw_tri_io[12]),
        .O(sw_tri_i_12),
        .T(sw_tri_t_12));
  IOBUF sw_tri_iobuf_13
       (.I(sw_tri_o_13),
        .IO(sw_tri_io[13]),
        .O(sw_tri_i_13),
        .T(sw_tri_t_13));
  IOBUF sw_tri_iobuf_14
       (.I(sw_tri_o_14),
        .IO(sw_tri_io[14]),
        .O(sw_tri_i_14),
        .T(sw_tri_t_14));
  IOBUF sw_tri_iobuf_15
       (.I(sw_tri_o_15),
        .IO(sw_tri_io[15]),
        .O(sw_tri_i_15),
        .T(sw_tri_t_15));
  IOBUF sw_tri_iobuf_2
       (.I(sw_tri_o_2),
        .IO(sw_tri_io[2]),
        .O(sw_tri_i_2),
        .T(sw_tri_t_2));
  IOBUF sw_tri_iobuf_3
       (.I(sw_tri_o_3),
        .IO(sw_tri_io[3]),
        .O(sw_tri_i_3),
        .T(sw_tri_t_3));
  IOBUF sw_tri_iobuf_4
       (.I(sw_tri_o_4),
        .IO(sw_tri_io[4]),
        .O(sw_tri_i_4),
        .T(sw_tri_t_4));
  IOBUF sw_tri_iobuf_5
       (.I(sw_tri_o_5),
        .IO(sw_tri_io[5]),
        .O(sw_tri_i_5),
        .T(sw_tri_t_5));
  IOBUF sw_tri_iobuf_6
       (.I(sw_tri_o_6),
        .IO(sw_tri_io[6]),
        .O(sw_tri_i_6),
        .T(sw_tri_t_6));
  IOBUF sw_tri_iobuf_7
       (.I(sw_tri_o_7),
        .IO(sw_tri_io[7]),
        .O(sw_tri_i_7),
        .T(sw_tri_t_7));
  IOBUF sw_tri_iobuf_8
       (.I(sw_tri_o_8),
        .IO(sw_tri_io[8]),
        .O(sw_tri_i_8),
        .T(sw_tri_t_8));
  IOBUF sw_tri_iobuf_9
       (.I(sw_tri_o_9),
        .IO(sw_tri_io[9]),
        .O(sw_tri_i_9),
        .T(sw_tri_t_9));
endmodule
