<?php

// DEBUG: Check if runtime file exists
$runtimePath = __DIR__.'/../vendor/autoload_runtime.php';

if (!file_exists($runtimePath)) {
    header('Content-Type: text/plain');
    echo "RUNTIME FILE MISSING!\n\n";
    echo "Attempting to generate...\n";
    
    // Try to generate manually
    system('php vendor/bin/runtime get --current --output=' . escapeshellarg($runtimePath));
    
    echo "Generation result: " . (file_exists($runtimePath) ? "SUCCESS" : "FAILED");
    echo "\n\nDirectory contents:\n";
    system('ls -la ' . escapeshellarg(dirname($runtimePath)));
    exit;
}

require_once $runtimePath;

return function (array $context) {
    return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']);
};