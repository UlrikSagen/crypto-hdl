library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;

library crypto;

entity tb_sha256_pad is
    generic (
        runner_cfg : string;
        vector_input_file : string;
        vector_output_file : string
        );
end entity;

architecture sim of tb_sha256_pad is
    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal tvalid : std_logic; --out

    signal tdata : unsigned(31 downto 0);
    signal tready : std_logic; --in
    signal tlast : std_logic;
    signal tkeep : unsigned(3 downto 0);
    signal block_out : unsigned(511 downto 0);

    signal first : std_logic;
    signal start : std_logic;
    signal core_busy : std_logic := '0';

    signal checker_done : std_logic := '0';

begin

    clk <= not clk after CLK_PERIOD / 2;

    dut : entity crypto.sha256_pad
     port map(
        clk => clk,
        rst => rst,
        tdata => tdata,
        tvalid => tvalid,
        tready => tready,
        tlast => tlast,
        tkeep => tkeep,
        block_out => block_out,
        first => first,
        start => start,
        core_busy => core_busy
    );


    main : process
        file f : text;
        variable l : line;

        variable tkeep_v : unsigned(3 downto 0);
        variable tlast_v : std_logic;
        variable tdata_v : unsigned(31 downto 0);

    begin
        test_runner_setup(runner, runner_cfg);
        
        rst <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rst <= '0';
        wait until rising_edge(clk);

        while test_suite loop
            if run("Mot_pad_test_vectors") then
                file_open(f, vector_input_file, read_mode);

                    while not endfile(f) loop
                        readline(f, l);
                        hread(l, tkeep_v); read(l, tlast_v); hread(l, tdata_v);
                        tkeep <= tkeep_v;
                        tlast <= tlast_v;
                        tdata <= tdata_v;
                        tvalid <= '1';
                        wait until rising_edge(clk) and tready = '1';
                    end loop;

                    tvalid <= '0';
                    file_close(f);
            end if;
        end loop;

        wait until checker_done = '1';
        test_runner_cleanup(runner);

    end process;

    checker : process
        file f : text;
        variable l : line;

        variable first_v : std_logic;
        variable last_v : std_logic;
        variable block_v : unsigned(511 downto 0);

    begin
        file_open(f, vector_output_file, read_mode);
        while not endfile(f) loop
            wait until rising_edge(clk) and start = '1';
            readline(f, l);
            read(l, first_v); read(l, last_v); hread(l, block_v);
            check_equal(block_out, block_v, "block");
            check_equal(first, first_v, "first");
        end loop;
        file_close(f);
        checker_done <= '1';
        wait;
    end process;
end architecture;