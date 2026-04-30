<?php
// Test: Code injection detection

// VULNERABLE: eval with user input
eval($_GET['code']); // BAD

// VULNERABLE: Through variable
$code = $_POST['expression'];
eval($code); // BAD

// VULNERABLE: assert with string
assert($_GET['assertion']); // BAD

// SAFE: intval prevents code injection
eval(intval($_GET['num'])); // GOOD
