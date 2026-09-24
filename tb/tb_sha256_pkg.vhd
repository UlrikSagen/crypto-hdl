library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library vunit_lib;
context vunit_lib.vunit_context;

library crypto;
use crypto.sha256_pkg.all;

entity tb_sha256_pkg is
    generic (runner_cfg : string);
end entity;

architecture sim of tb_sha256_pkg is
begin
    process
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            if run("rotr") then
                check_equal(rotr(x"6a09e667", 7), unsigned'(x"ced413cc"), "rotr(6a09e667,7)");
                check_equal(rotr(x"00000001", 7), unsigned'(x"02000000"), "rotr(00000001,7)");
            end if;
            if run("sigma0") then
                check_equal(sigma0(x"6a09e667"),  unsigned'(x"ba0cf582"), "sigma0(6a09e667)");
                check_equal(sigma0(x"61626380"), unsigned'(x"940e90ef"), "sigma0(61626380)");
            end if;
            if run("sigma1") then
                check_equal(sigma1(x"6a09e667"),  unsigned'(x"cfe5da3c"), "sigma1(6a09e667)");
                check_equal(sigma1(x"80000000"), unsigned'(x"00205000"), "sigma1(80000000)");
            end if;
            if run("capsigma0") then
                check_equal(capsigma0(x"6a09e667"), unsigned'(x"ce20b47e"), "capsigma0");
                check_equal(capsigma0(x"00000001"), unsigned'(x"40080400"), "capsigma0(00000001)");
                check_equal(capsigma0(x"80000000"), unsigned'(x"20040200"), "capsigma0(80000000)");
            end if;
            if run("capsigma1") then
                check_equal(capsigma1(x"6a09e667"), unsigned'(x"55b65510"), "capsigma1");
                check_equal(capsigma1(x"61626380"), unsigned'(x"c0b865f2"), "capsigma1(61626380)");
            end if;
            if run("ch") then
                check_equal(ch(x"6a09e667", x"bb67ae85", x"3c6ef372"),  unsigned'(x"3e67b715"), "ch");
                check_equal(ch(x"ffffffff", x"bb67ae85", x"3c6ef372"), unsigned'(x"bb67ae85"), "ch(alle 1 -> y)");
                check_equal(ch(x"00000000", x"bb67ae85", x"3c6ef372"), unsigned'(x"3c6ef372"), "ch(alle 0 -> z)");
            end if;
            if run("maj") then
                check_equal(maj(x"6a09e667", x"bb67ae85", x"3c6ef372"), unsigned'(x"3a6fe667"), "maj");
                check_equal(maj(x"ffffffff", x"ffffffff", x"3c6ef372"), unsigned'(x"ffffffff"), "maj(to av tre 1)");
                check_equal(maj(x"00000000", x"00000000", x"ffffffff"), unsigned'(x"00000000"), "maj(to av tre 0)");
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;

    test_runner_watchdog(runner, 1 ms);
end architecture;