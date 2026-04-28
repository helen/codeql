<?php

// Test: Command injection via superglobals

// BAD: exec with user input
exec($_GET['cmd']);

// BAD: system with user input
system("ls " . $_POST['dir']);

// BAD: passthru with user input
passthru($_REQUEST['command']);

// GOOD: no user input
exec("ls -la");

// GOOD: escaped user input
exec(escapeshellcmd($_GET['cmd']));
