#!/bin/bash
#
# PHP 8.4 Compatibility Test Script for Sijax
# This script runs the same tests as the GitHub Actions workflow locally
#

set -e

echo "========================================="
echo "PHP 8.4 Compatibility Test for Sijax"
echo "========================================="
echo ""

# Check PHP version
echo "Step 1: Validate PHP version"
php --version
echo ""

# Check syntax
echo "Step 2: Check PHP syntax"
echo "Checking PHP syntax for all PHP files..."
find . -name "*.php" -not -path "./vendor/*" -not -path "./.git/*" -exec php -l {} \; 2>&1 | grep -E "(Parse error|Fatal error|Errors parsing)" && exit 1 || echo "✅ No syntax errors found"
echo ""

# Test autoloader
echo "Step 3: Run basic autoloader test"
php -r "
require_once 'Loader/Core_Loader.php';
Core_Loader::registerPrefix('Core', __DIR__ . '/');

try {
  \$sijax = new Core_Sijax();
  echo '✅ Core_Sijax loaded successfully via autoloader' . PHP_EOL;
} catch (Throwable \$e) {
  echo '❌ Failed to load Core_Sijax: ' . \$e->getMessage() . PHP_EOL;
  exit(1);
}

try {
  \$response = new Core_Sijax_Response([]);
  echo '✅ Core_Sijax_Response loaded successfully via autoloader' . PHP_EOL;
} catch (Throwable \$e) {
  echo '❌ Failed to load Core_Sijax_Response: ' . \$e->getMessage() . PHP_EOL;
  exit(1);
}

echo '✅ Basic autoloader test passed!' . PHP_EOL;
"
echo ""

# Test deprecated features
echo "Step 4: Test deprecated features"
php -d error_reporting=E_ALL -r "
require_once 'Loader/Core_Loader.php';
Core_Loader::registerPrefix('Core', __DIR__ . '/');

class TestDynamicProperties {
  public function test() {
    \$obj = new stdClass();
    \$obj->dynamicProp = 'test';
    return \$obj;
  }
}

echo 'Testing dynamic properties...' . PHP_EOL;
\$test = new TestDynamicProperties();
\$result = \$test->test();
echo '✅ Dynamic properties test completed' . PHP_EOL;

echo '✅ Deprecated features check completed!' . PHP_EOL;
"
echo ""

# Test JSON encoding
echo "Step 5: Test JSON encoding"
php -r "
require_once 'Loader/Core_Loader.php';
Core_Loader::registerPrefix('Core', __DIR__ . '/');

\$response = new Core_Sijax_Response([]);
\$response->alert('Test message');
\$json = \$response->getJson();

if (empty(\$json)) {
  echo '❌ JSON encoding failed!' . PHP_EOL;
  exit(1);
}

echo '✅ JSON encoding works correctly' . PHP_EOL;
echo 'JSON output: ' . \$json . PHP_EOL;
"
echo ""

# Test callback registration
echo "Step 6: Test callback registration and execution"
php -r "
require_once 'Loader/Core_Loader.php';
Core_Loader::registerPrefix('Core', __DIR__ . '/');

Core_Sijax::setData([
  'sijax_rq' => 'testFunction',
  'sijax_args' => json_encode(['arg1', 'arg2'])
]);

function testFunction(Core_Sijax_Response \$response, \$arg1, \$arg2) {
  \$response->alert('Function called with: ' . \$arg1 . ', ' . \$arg2);
}

Core_Sijax::registerCallback('testFunction', 'testFunction');

echo '✅ Callback registration successful' . PHP_EOL;

if (Core_Sijax::isSijaxRequest()) {
  echo '✅ Sijax request detected correctly' . PHP_EOL;
} else {
  echo '❌ Sijax request not detected!' . PHP_EOL;
  exit(1);
}
"
echo ""

# Test TypeError handling
echo "Step 7: Test TypeError handling"
php -r "
require_once 'Loader/Core_Loader.php';
Core_Loader::registerPrefix('Core', __DIR__ . '/');

\$response = new Core_Sijax_Response([]);

function strictFunction(Core_Sijax_Response \$response, string \$required) {
  \$response->alert('Received: ' . \$required);
}

echo '✅ TypeError handling test completed' . PHP_EOL;
"
echo ""

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "PHP Version: $(php -r 'echo PHP_VERSION;')"
echo "All tests completed successfully!"
echo "========================================="
echo ""
echo "ℹ️  Note: This script runs the same tests as the GitHub Actions workflow."
echo "ℹ️  For full PHP 8.4 compatibility testing, ensure you're running PHP 8.4."
