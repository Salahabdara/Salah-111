<?php
$seg = $_GET['seg'] ?? '';
$script = __DIR__ . '/' . $seg . '.php';
if(is_file($script)){
  $_GET['path'] = $_GET['path'] ?? '';
  require $script;
} else {
  header('Content-Type: application/json; charset=utf-8');
  http_response_code(404); echo json_encode(['error'=>'Not found']);
}
