<?php
// Test: Unsafe deserialization detection

// VULNERABLE: Direct unserialize of user input
$data = $_GET['data'];
$obj = unserialize($data); // BAD

// VULNERABLE: Through variable
$cookie = $_COOKIE['session'];
$session = unserialize($cookie); // BAD

// SAFE: json_decode is safe (no object instantiation)
$safe = json_decode($_GET['json']); // GOOD (not modeled as deserialization)
