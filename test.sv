

program automatic test;
  `include "test_collection.sv"

  initial begin
     
    run_test("test_base");
    $display("inside test.sv");
  end

endprogram
