`timescale 1ns / 1ps

module tb_practice_oop_ex5();

    class base_packet;
        static string KIND = "BASE";
        int id;

        function new(int id);
            this.id = id;
        endfunction

        function string info();
            return $sformatf("%s#%d", KIND, id);
        endfunction

        virtual function string info_virtual();
            return $sformatf("%s#%d", KIND, id);
        endfunction
    endclass

    class eth_packet extends base_packet;
        static string KIND = "ETH";
        bit [47:0] mac_da;

        function new(int id, bit [47:0] da);
            super.new(id);
            this.mac_da = da;
        endfunction

        virtual function string info_virtual();
            return $sformatf("%s#%d (mac = %d)", KIND, id, mac_da);
        endfunction
    endclass

    eth_packet e;
    initial begin
        $display("[ex05] asking the child objects e (actual type = eth_packet)");
        e = new(2, 47'haabbccddee);
        $display("base_packet::KINT = %s", base_packet::KIND);
        $display("eth_packet::KINT = %s", eth_packet::KIND);

        $display("e.info() = %s", e.info());
        $display("e.info_virtual() = %s", e.info_virtual());
    end
endmodule
