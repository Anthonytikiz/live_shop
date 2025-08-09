<?php

use App\Kernel;

$autoloadPath = dirname(__DIR__).'/vendor/autoload_runtime.php';

// Debugging block
if (!file_exists($autoloadPath)) {
    header('Content-Type: text/plain');
    echo "CRITICAL: autoload_runtime.php missing!\n\n";
    echo "Scanned path: $autoloadPath\n\n";
    
    echo "Vendor directory contents:\n";
    echo implode("\n", scandir(dirname($autoloadPath)));
    
    echo "\n\nComposer installed packages:\n";
    passthru('composer show -i');
    exit(1);
}

require_once $autoloadPath;

return function (array $context) {
    return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']);
};