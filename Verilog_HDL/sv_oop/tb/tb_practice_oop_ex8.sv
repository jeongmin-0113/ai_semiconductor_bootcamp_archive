`timescale 1ns / 1ps

module tb_practice_oop_ex8 ();

    // parent class
    class transaction;
        string name = "transaction";

        virtual function void drive();
            $display("  %s driven ", name);
        endfunction

        // 호출시마다 cost 1을 반환
        virtual function int cost();
            return 1;
        endfunction
    endclass

    // child class
    class read_txn extends transaction;

        function new();
            name = "read_txn";
        endfunction

        virtual function void drive();
            $display("  %s driven ", name);
        endfunction

        virtual function int cost();
            return 10;
        endfunction
    endclass

    // grand child class
    class burst_read_txn extends read_txn;
        int len = 0;

        function new(int len);
            super.new();
            this.len = len;
        endfunction

        virtual function void drive();
            $display("  %s driven : len = %d", name, len);
        endfunction

        virtual function int cost();
            return super.cost() * len;
        endfunction
    endclass

    transaction lst[$];
    transaction t0;
    read_txn r0;
    burst_read_txn b0;
    int total;

    initial begin
        $display(
            "[ex08] three different children stored in one parent-type queue");
        t0 = new;
        r0 = new;
        b0 = new(10);

        lst.push_back(t0);
        lst.push_back(r0);
        lst.push_back(b0);

        total = 0;
        foreach(lst[i]) begin
            lst[i].drive();
            total += lst[i].cost();
        end

        $display("  total cost = %d", total);
    end

endmodule
