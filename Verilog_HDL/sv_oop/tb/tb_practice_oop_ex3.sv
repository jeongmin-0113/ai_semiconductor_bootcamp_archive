`timescale 1ns / 1ps

module tb_practice_oop_ex3 ();

    class packet;
        static int num_created = 0;
        int my_serial;

        function new();
            num_created++;
            my_serial = num_created;
        endfunction
    endclass

    packet p1, p2, p3;

    initial begin
        $display("[ex03] static member vs pre-object member");
        // 초기값 지정, 인스턴스 없이도 패킷 클래스의 state member에 접근 가능
        $display("before creating any object : packet::num_created = %d",
                 packet::num_created);
        p1 = new();
        p2 = new();
        p3 = new();

        $display("p1.my_serial = %d", p1.my_serial);
        $display("p2.my_serial = %d", p2.my_serial);
        $display("p3.my_serial = %d", p3.my_serial);

        $display("without object -> packet::num_created = %d",
                 packet::num_created);
        $display("with object -> p1.num_created = %d", p1.num_created);

    end
endmodule
