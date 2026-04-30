<?php
// Test: Path injection detection

// VULNERABLE: Direct user input in file path
$path = $_GET['file'];
$content = file_get_contents($path); // BAD

// VULNERABLE: Through variable
$filename = $_POST['filename'];
$handle = fopen("/uploads/" . $filename, "r"); // BAD

// VULNERABLE: readfile
readfile($_GET['doc']); // BAD

// SAFE: basename strips directory traversal
$safe = basename($_GET['file']);
file_get_contents("/uploads/" . $safe); // GOOD

// SAFE: realpath resolves symlinks
$real = realpath($_GET['path']);
fopen($real, "r"); // GOOD
