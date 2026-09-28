library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library vunit_lib;
context vunit_lib.vunit_context;

library crypto;

entity tb_sha256_core is
    generic (
        runner_cfg : string;
        vector_file : string
        );
end entity;

architecture sim of tb_sha256_core is
    constant CLK_PERIOD : time     := 10 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal block_in : unsigned(511 downto 0);
    signal digest : unsigned(255 downto 0);
    signal first : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic := '0';
begin

clk <= not clk after CLK_PERIOD / 2;    

dut : entity crypto.sha256_core
    port map (clk => clk, rst => rst, block_in => block_in, first => first, start => start, done => done, digest => digest);

main : process
    file f : text;
    variable l : line;
    
    variable last : natural := 0;
    variable first_v : std_logic := '0';
    variable blk_v : unsigned(511 downto 0);
    variable digest_v : unsigned(255 downto 0);
begin
    test_runner_setup(runner, runner_cfg);

    rst <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);

    while test_suite loop
        if run ("mot_core_vectors") then
            file_open(f, vector_file, read_mode);
                while not endfile(f) loop
                    readline(f, l);
                    read(l, first_v); read(l, last); hread(l, blk_v); hread(l, digest_v);
                    first <= first_v;
                    block_in <= blk_v;

                    start <= '1';
                    wait until rising_edge(clk);
                    start <= '0';
                    wait until done = '1' and rising_edge(clk);

                    if last = 1 then
                        check_equal(digest, digest_v);
                    end if;
                end loop;
        end if;
    end loop;
    test_runner_cleanup(runner);
end process;
end architecture;