`timescale 1ns / 1ps

module tb_practice_oop_ex2 ();

    // parent class
    class base_packet;
        int id;

        function new(int id);
            this.id = id;
        endfunction

         function void print();
            $display(" 1) base_packet (id = %d)", id);
        endfunction
    endclass

    // child class, ethernet packet
    class eth_packet extends base_packet;
        bit [47:0] mac_da;  // 6byte

        function new(int id, bit [47:0] da);
            super.new(id);  // parent class init
            mac_da = da;
        endfunction

         function void print();
            super.print();
            $display(" 2) eth_packet (mac_da = %012d)", mac_da);
        endfunction
    endclass

    // child class
    class bad_packet extends base_packet;
        function new(int id);
            super.new(id);
        endfunction

         function void print();
            $display(" 3) bad_packet where did id go? (id = %d)", id);
        endfunction
    endclass

    eth_packet e;
    bad_packet b;
    base_packet ba;

    initial begin
        $display("[ex02] with super.print() vs without super.print()");
        e = new(7, 48'haabbccddeeff);
        b = new(9);
        ba = b;
        $display(" A) e.print() -- calls super.print()");
        e.print();
        $display(" B) b.print() -- not calls super.print()");
        b.print();
        $display(" C) ba.print() -- bad packet in base packet");
        ba.print();
        #1;
    end

endmodule
