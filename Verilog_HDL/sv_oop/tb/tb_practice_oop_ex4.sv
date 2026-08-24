`timescale 1ns / 1ps

package my_package;
    class bus_txn;
        typedef enum {
            READ,  // 0
            WRITE  // 1
        } kind_e;
        static int count = 0;
        kind_e kind;
        int id;

        function new(kind_e kind, int id);
            this.kind = kind;
            this.id   = id;
            count++;
        endfunction

        // extern: class 외부에 info 함수 선언부가 존재한다
        extern function string info();
    endclass

    function string bus_txn::info();
        // $sformatf : string format func
        // formatting해서 string 타입으로 return
        return $sformatf("txn#%0d %s", id, kind.name());
    endfunction

endpackage

module tb_practice_oop_ex4 ();

    import my_package::*;

    my_package::bus_txn t1;
    my_package::bus_txn t2;

    initial begin
        $display("[ex04] the four places :: is used");
        t1 = new(bus_txn::READ, 1);
        t2 = new(bus_txn::WRITE, 1);

        $display(" 1) package       my_package::bus_txn");
        $display(" 2) static member bus_txn::count", bus_txn::count);
        $display(" 3) nested type bus_txn::READ = %d, bus_txn::WRITE = %d",
                 bus_txn::READ, bus_txn::WRITE);
        $display(" 4) out of bocy");
        $display("t1.info = %s", t1.info());
        $display("t2.info = %s", t2.info());
        $finish;
    end
endmodule
