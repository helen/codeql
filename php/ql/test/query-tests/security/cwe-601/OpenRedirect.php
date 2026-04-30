<?php
// Test: Open redirect detection

// VULNERABLE: User input in header redirect
$url = $_GET['redirect'];
header("Location: " . $url); // BAD

// VULNERABLE: Through variable
$target = $_POST['url'];
header("Location: $target"); // BAD

// VULNERABLE: wp_redirect
wp_redirect($_GET['next']); // BAD
