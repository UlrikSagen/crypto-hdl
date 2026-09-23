library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

library crypto;

entity tb_counter is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_counter is
  constant WIDTH      : positive := 8;
  constant CLK_PERIOD : time     := 10 ns;

  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';
  signal enable : std_logic := '0';
  signal count  : unsigned(WIDTH - 1 downto 0);
begin

  clk <= not clk after CLK_PERIOD / 2;

  dut : entity crypto.counter
    generic map (WIDTH => WIDTH)
    port map (clk => clk, rst => rst, enable => enable, count => count);

  main : process
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop

      rst    <= '1';
      enable <= '0';
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      rst <= '0';
      wait until rising_edge(clk);

      if run("verktoykjeden_virker") then
        check_equal(1, 1, "Feiler denne, er noe fundamentalt galt");

      elsif run("null_etter_reset") then
        check_equal(count, 0, "Skal vaere null etter reset");

      elsif run("teller_opp") then
        enable <= '1';
        for i in 1 to 5 loop
          wait until rising_edge(clk);
        end loop;
        enable <= '0';
        wait for 1 ns;
        check_equal(count, 5, "Skal ha talt fem ganger");

      elsif run("staar_stille_uten_enable") then
        for i in 1 to 5 loop
          wait until rising_edge(clk);
        end loop;
        wait for 1 ns;
        check_equal(count, 0, "Skal ikke bevege seg uten enable");
      end if;

    end loop;

    test_runner_cleanup(runner);
  end process;

  test_runner_watchdog(runner, 1 ms);

end architecture;
