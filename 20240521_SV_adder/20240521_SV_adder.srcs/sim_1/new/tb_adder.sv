`timescale 1ns / 1ps

interface adder_inif;
    logic clk;
    logic reset;
    logic valid;
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] sum;
    logic carry;
endinterface //adder_inif

class transaction;
    rand logic [3:0] a;
    rand logic [3:0] b;    
    rand logic valid;
    logic [3:0] sum;
    logic carry;

    task display(string name);
        $display("[%s] a:%d, b:%d, carry:%d, sum:%d", 
        name, a, b, carry, sum);
    endtask
endclass //transaction

class generator;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event genNextEvent_gen;

    function new();
        tr = new();    
    endfunction //new()

    task run ();
        repeat(1000) begin
            assert (tr.randomize())
            else $error("tr.randomize() error!");
            gen2drv_mbox.put(tr);
            tr.display("GEN");
            @(genNextEvent_gen);
        end
    endtask  
endclass //generator

class driver;
    virtual adder_inif adder_if1;    
    mailbox #(transaction) gen2drv_mbox;
    transaction trans;
    event genNextEvent_drv;
    event monNextEvent_drv;

    function new(virtual adder_inif a);
        this.adder_if1 = a;        
    endfunction //new()

        task reset();
            adder_if1.a <= 0;
            adder_if1.b <= 0;
            adder_if1.valid <= 1'b0;
            adder_if1.reset <= 1'b1;
            repeat(5) @(adder_if1.clk);
            adder_if1.reset <= 1'b0;
        endtask //

        task run();
            forever begin
                gen2drv_mbox.get(trans); // blocking code
                adder_if1.a <= trans.a;
                adder_if1.b <= trans.b;
                adder_if1.valid <= 1'b1;
                trans.display("DRV");
                @(posedge adder_if1.clk);
                adder_if1.valid <= 1'b0;                
                @(posedge adder_if1.clk);                
                ->monNextEvent_drv;
                //->genNextEvent_drv;             
            end
        endtask //
    
endclass //driver

class monitor;
    virtual adder_inif adder_if3;
    mailbox #(transaction) mon2scb_mbox;
    transaction trans;
    event monNextEvent_mon;

    function new(virtual adder_inif adder_if2);
        this.adder_if3 = adder_if2;
        trans = new();
    endfunction //new()

    task run();
    forever begin
        @(monNextEvent_mon);
        trans.a = adder_if3.a;
        trans.b = adder_if3.b;
        trans.sum = adder_if3.sum;
        trans.carry = adder_if3.carry;
        mon2scb_mbox.put(trans);
        trans.display("MON");
    end
    endtask    
endclass //monitor

class scoreboard;
    mailbox #(transaction)mon2scb_mbox;
    transaction trans;
    event genNextEvent_scb;
    int total_cnt, pass_cnt, fail_cnt;
    function new();        
        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;
    endfunction //new()
    task run();
        forever begin
           mon2scb_mbox.get(trans);
           trans.display("SCB");
           total_cnt++;
           if ((trans.a + trans.b) == {trans.carry, trans.sum}) begin
                $display("--> PASS! %d + %d = %d", 
                trans.a, trans.b, {trans.carry+trans.sum}); 
                // (trans.a + trans.b) <- reference model, golden reference 
                pass_cnt ++ ;
           end else begin
                $display("--> FAIL! %d + %d = %d", 
                trans.a, trans.b, {trans.carry+trans.sum});
                fail_cnt++;
           end
           ->genNextEvent_scb;
        end
    endtask 
endclass //scoreboard

module tb_adder();

    adder_inif adder_if();
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    event genNextEvent;
    event monNextEvent;
    adder dut(
        .clk(adder_if.clk),
        .reset(adder_if.reset),
        .valid(adder_if.valid),
        .a(adder_if.a),
        .b(adder_if.b),
        .sum(adder_if.sum),
        .carry(adder_if.carry)
    );
    always #5 adder_if.clk = ~adder_if.clk;

    initial begin
        adder_if.clk = 1'b0;
        adder_if.reset = 1'b1;
    end
    initial begin
        gen2drv_mbox = new(); 
        mon2scb_mbox = new();
        gen = new();
        drv = new(adder_if);
        mon = new(adder_if);
        scb = new();

        gen.genNextEvent_gen = genNextEvent;
        scb.genNextEvent_scb = genNextEvent;
        mon.monNextEvent_mon = monNextEvent;
        drv.monNextEvent_drv = monNextEvent;

        gen.gen2drv_mbox = gen2drv_mbox;
        drv.gen2drv_mbox = gen2drv_mbox;
        mon.mon2scb_mbox = mon2scb_mbox;
        scb.mon2scb_mbox = mon2scb_mbox;

        drv.reset();
        //drv.run();
        fork
            mon.run();
            gen.run();
            drv.run();
            scb.run();            
        join_any
        $display("===========================");
        $display("Final Report");
        $display("===========================");
        $display("Total Test : %d", scb.total_cnt);
        $display("Pass Count : %d", scb.pass_cnt);
        $display("Fail Count : %d", scb.fail_cnt);
        $display("===========================");
        $display("test bench finished!");
        $display("===========================");
        #10 $finish;
    end

endmodule
