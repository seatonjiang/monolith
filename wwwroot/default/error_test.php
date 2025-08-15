<?php
/**
 * PHP错误日志测试文件
 * 此文件包含各种类型的PHP错误，用于测试PHP错误日志功能
 */

// 设置页面编码
header('Content-Type: text/html; charset=utf-8');

// 显示页面标题
echo "<h1>PHP错误日志测试</h1>";
echo "<p>此页面用于测试PHP错误日志功能，会触发各种类型的PHP错误。</p>";
echo "<p>错误日志位置: /var/log/php/php-error.log</p>";
echo "<hr>";

// 函数：记录测试结果
function logTest($errorType, $description) {
    echo "<div style='margin-bottom: 20px;'>";
    echo "<h3>测试: $errorType</h3>";
    echo "<p>$description</p>";
    echo "<pre style='background-color: #f5f5f5; padding: 10px; border-radius: 5px;'>";

    // 捕获输出
    ob_start();

    // 尝试执行可能导致错误的代码
    try {
        // 根据错误类型执行不同的测试
        switch ($errorType) {
            case '语法错误测试':
                // 注意：这里故意使用错误的语法，但为了让文件能够执行，
                // 我们使用eval来执行这段代码
                eval("echo 'This is a test';");
                echo "这行不会执行，因为上面有语法错误";
                break;

            case '警告测试':
                // 尝试包含一个不存在的文件会触发警告
                include 'non_existent_file.php';
                echo "警告已触发，但代码继续执行";
                break;

            case '通知测试':
                // 使用未定义的变量会触发通知
                echo $undefined_variable;
                echo "通知已触发，但代码继续执行";
                break;

            case '致命错误测试':
                // 调用不存在的函数会触发致命错误
                non_existent_function();
                echo "这行不会执行，因为上面有致命错误";
                break;

            case '用户自定义错误测试':
                // 触发用户自定义错误
                trigger_error("这是一个用户自定义错误", E_USER_ERROR);
                echo "这行不会执行，因为上面有用户自定义错误";
                break;

            case '用户自定义警告测试':
                // 触发用户自定义警告
                trigger_error("这是一个用户自定义警告", E_USER_WARNING);
                echo "用户自定义警告已触发，但代码继续执行";
                break;

            case '用户自定义通知测试':
                // 触发用户自定义通知
                trigger_error("这是一个用户自定义通知", E_USER_NOTICE);
                echo "用户自定义通知已触发，但代码继续执行";
                break;

            case '异常测试':
                // 抛出一个异常
                throw new Exception("这是一个测试异常");
                echo "这行不会执行，因为上面抛出了异常";
                break;
        }
    } catch (Exception $e) {
        echo "捕获到异常: " . $e->getMessage();
    }

    // 获取输出并结束捕获
    $output = ob_get_clean();
    echo htmlspecialchars($output);
    echo "</pre>";
    echo "</div>";
}

// 执行各种错误测试
logTest('语法错误测试', '测试PHP语法错误');
logTest('警告测试', '测试PHP警告 (E_WARNING)');
logTest('通知测试', '测试PHP通知 (E_NOTICE)');
logTest('致命错误测试', '测试PHP致命错误 (E_ERROR)');
logTest('用户自定义错误测试', '测试用户自定义错误 (E_USER_ERROR)');
logTest('用户自定义警告测试', '测试用户自定义警告 (E_USER_WARNING)');
logTest('用户自定义通知测试', '测试用户自定义通知 (E_USER_NOTICE)');
logTest('异常测试', '测试PHP异常');

// 显示完成信息
echo "<hr>";
echo "<p>测试完成。请检查PHP错误日志文件以查看记录的错误。</p>";
