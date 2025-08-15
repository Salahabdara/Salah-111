<?php
// إعدادات قاعدة البيانات
$servername = "sql312.infinityfree.com";
$username   = "if0_39710422";
$password   = "3JgCq73PehSkmv4"; // كلمة المرور من أول صورة
$dbname     = "if0_39710422_AndeedHRYemen";

// الاتصال بقاعدة البيانات
$conn = mysqli_connect($servername, $username, $password, $dbname);

// التحقق من الاتصال
if (!$conn) {
    die("فشل الاتصال بقاعدة البيانات: " . mysqli_connect_error());
}

// ضبط الترميز UTF-8 لدعم اللغة العربية
mysqli_set_charset($conn, "utf8");
?>
