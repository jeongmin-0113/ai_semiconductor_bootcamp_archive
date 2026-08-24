`timescale 1ns / 1ps

// virtual function (static binding, dynamic binding)
module tb_practice_oop_ex6 ();

    class transaction;
        function void hello_nonvirtual();
            $display("  execute: transaction::hello_nonvirtual()");
        endfunction

        virtual function void hello_virtual();
            $display("  execute: tranasction::hello_virtual()");
        endfunction
    endclass

    class read_txn extends transaction;
        function void hello_nonvirtual();
            $display("  execute: read_txn::hello_nonvirtual()");
        endfunction

        virtual function void hello_virtual();
            $display("  execute: tranasction::hello_virtual()");
        endfunction
    endclass

    transaction t;
    read_txn r;

    initial begin
        $display("[ex06] handle is transaction, actual object is read_txn");
        r = new;
        t = r; // 업캐스팅: handle은 transaction(parent), object는 read_txn(child)

        $display(" A) t.hello_nonvirtual() execute");
        t.hello_nonvirtual();
        $display(" B) r.hello_nonvirtual() execute");
        r.hello_nonvirtual();

        $display(" C) t.hello_virtual() execute");
        t.hello_virtual();
        $display(" D) r.hello_virtual() execute");
        r.hello_virtual();

    end
endmodule
