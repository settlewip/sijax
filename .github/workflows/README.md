# PHP 8.4 Compatibility Testing

This directory contains GitHub Actions workflows for testing Sijax compatibility with PHP 8.4.

## Workflow: php-8.4-compatibility.yml

This workflow runs comprehensive compatibility tests for PHP 8.4, including:

1. **PHP Syntax Check**: Validates all PHP files for syntax errors
2. **Autoloader Test**: Verifies that the Core_Loader autoloader works correctly
3. **Deprecated Features Check**: Tests for deprecated features that might cause issues
4. **JSON Encoding Test**: Ensures JSON encoding/decoding works properly
5. **Callback Registration Test**: Verifies Sijax request handling and callback registration
6. **TypeError Handling Test**: Tests the TypeError exception handling in Core_Sijax

### Running the Tests

The workflow is triggered on:
- Push to `copilot/ci-test-php-8-4-compatibility` branch
- Pull requests targeting `copilot/ci-test-php-8-4-compatibility` branch

### Test Results

All tests are designed to validate that Sijax core functionality works correctly with PHP 8.4.
Any failures will be reported in the Actions tab of the GitHub repository.

## Known Compatibility Considerations

### Dynamic Properties
PHP 8.2 deprecated dynamic properties, and PHP 8.4 may make these stricter. The codebase currently:
- Uses `Core_Sijax_Handler` which has `__get`, `__set`, and `__call` magic methods
- These methods allow for dynamic property access on the handler object
- Standard library classes like `stdClass` still support dynamic properties

### TypeError Handling
- Core_Sijax already includes TypeError handling for callback execution (see line 264 in Core_Sijax.php)
- This ensures graceful handling of type mismatches in PHP 8.0+

## Local Testing

To run compatibility tests locally:

```bash
# Check PHP syntax
find . -name "*.php" -not -path "./vendor/*" -exec php -l {} \;

# Run basic autoloader test
php -r "
require_once 'Loader/Core_Loader.php';
Core_Loader::registerPrefix('Core', __DIR__ . '/');
\$sijax = new Core_Sijax();
\$response = new Core_Sijax_Response([]);
echo 'Tests passed!' . PHP_EOL;
"
```

## Future Improvements

As PHP 8.4 reaches GA (General Availability), additional tests may be added for:
- Any new deprecations introduced in PHP 8.4
- Performance benchmarks
- Integration tests with various PHP frameworks
