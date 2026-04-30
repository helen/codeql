<?php
// Test: SSRF detection

// VULNERABLE: User input in URL for file_get_contents
$url = $_GET['url'];
$response = file_get_contents($url); // BAD

// VULNERABLE: User input in fopen URL
fopen($_POST['endpoint'], "r"); // BAD

// VULNERABLE: curl with user input
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $_GET['target']); // BAD
curl_exec($ch);
