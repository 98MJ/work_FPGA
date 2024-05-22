`timescale 1ns / 1ps
interface register_inif;
    logic clk;
    logic reset;
    logic [15:0] i_data;
    logic [15:0] o_data;
endinterface //register_inif

class transaction;
    rand logic [15:0] i_data;
    logic [15:0] o_data;

    task display(string name);
        $display("[%s] i:%d, o:%d", name, i_data, o_data);
    endtask    
endclass //transaction

class generator;
    transaction tr_gen;
    mailbox #(transaction) gen2drv_mbox;
    event genNextEvent_gen;
    function new();
        tr_gen = new();
    endfunction //new()
    
    task run();
        repeat(1000)begin
            assert (tr_gen.randomize()) 
            else $error("tr_gen randomize() error!");
            gen2drv_mbox.put(tr_gen);
            tr_gen.display("GEN");
            @(genNextEvent_gen);
        end
    endtask 
endclass //generator

class driver;
    virtual register_inif regis_if_drv;
    mailbox #(transaction) gen2drv_mbox;
    transaction tr_drv;
    event genNextEvent_drv;
    event monNextEvent_drv;

    function new(virtual register_inif x);
        this.regis_if_drv = x;
    endfunction //new()

    task  reset();
        regis_if_drv.i_data <= 0;
        regis_if_drv.reset <= 1'b1;
        repeat(5) @(regis_if_drv.clk);
        regis_if_drv.reset <= 1'b0;
    endtask //
    task run();
    forever begin
        gen2drv_mbox.get(tr_drv);
        regis_if_drv.i_data <= tr_drv.i_data;
        tr_drv.display("DRV");
        repeat(2) @(posedge regis_if_drv.clk);
        ->monNextEvent_drv;
    end
    endtask
endclass //driver

class monitor;
    virtual register_inif regis_if_mon;
    mailbox #(transaction) mon2scb_mbox;
    transaction tr_mon;
    event monNextEvent_mon;
    function new(virtual register_inif x); 
        this.regis_if_mon = x;      
        tr_mon = new();  
    endfunction //new()

    task run();
    forever begin
        @(monNextEvent_mon);
        tr_mon.i_data = regis_if_mon.i_data;
        tr_mon.o_data = regis_if_mon.o_data;
        mon2scb_mbox.put(tr_mon);
        tr_mon.display("MON");
    end
    endtask
endclass //monitor

class scoreboard;
    mailbox #(transaction) mon2scb_mbox;
    transaction tr_scb;
    event genNextEvent_scb;
    int total_cnt, pass_cnt, fail_cnt;
    function new();
        total_cnt = 0;
        pass_cnt = 0;
        fail_cnt = 0;    
    endfunction //new()
    task run();
        forever begin
            mon2scb_mbox.get(tr_scb);
            tr_scb.display("SCB");
            total_cnt++;
            if (tr_scb.i_data == tr_scb.o_data) begin
                $display("--> PASS");
                pass_cnt++;
            end else begin
                $display("--> FAIL");
                fail_cnt++;
            end
            ->genNextEvent_scb;
        end        
        endtask

endclass //scoreboard

module tb_reg();

    register_inif regis();
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    event genNextEvent;
    event monNextEvent;

    register dut(
        .clk(regis.clk),
        .reset(regis.reset),
        .i_data(regis.i_data),
        .o_data(regis.o_data)
    );

    always #5 regis.clk = ~regis.clk;

    initial begin
        regis.clk = 1'b0;
        regis.reset = 1'b1;
    end
    initial begin
        gen2drv_mbox = new();
        mon2scb_mbox = new();
        gen = new();
        drv = new(regis);
        mon = new(regis);
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
