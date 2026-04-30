<?php
// Test: Command injection detection

// VULNERABLE: Direct superglobal to exec
$cmd = $_GET['cmd'];
exec($cmd); // BAD

// VULNERABLE: Through concatenation
$host = $_POST['host'];
system("ping " . $host); // BAD

// SAFE: escapeshellarg
$safe_host = escapeshellarg($_GET['host']);
exec("ping " . $safe_host); // GOOD

// SAFE: escapeshellcmd
$safe_cmd = escapeshellcmd($_POST['cmd']);
system($safe_cmd); // GOOD

// VULNERABLE: passthru
passthru($_GET['command']); // BAD

// VULNERABLE: shell_exec
$output = shell_exec($_GET['cmd']); // BAD

// VULNERABLE: proc_open
proc_open($_GET['cmd'], [], $pipes); // BAD
