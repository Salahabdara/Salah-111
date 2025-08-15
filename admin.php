<?php require_once __DIR__.'/../config.php';
$path=$_GET['path']??'';
$u=require_role(['admin','owner']);

if($path==='open-access'){
  $employer=intval($_POST['employer_id']??0);
  $job=intval($_POST['job_id']??0);
  $days=intval($_POST['days']??30);
  $pdo->prepare("INSERT INTO job_access(employer_id,job_id,active_until) VALUES(?,?,DATE_ADD(NOW(), INTERVAL ? DAY)) ON DUPLICATE KEY UPDATE active_until=DATE_ADD(NOW(), INTERVAL ? DAY)")->execute([$employer,$job,$days,$days]);
  jsonout(['message'=>'تم فتح الصلاحية.']);
}

if($path==='settings'){
  if($_SERVER['REQUEST_METHOD']==='POST'){
    foreach(['site_name','site_tagline'] as $k){ $v=trim($_POST[$k]??''); $pdo->prepare("INSERT INTO settings(k,v) VALUES(?,?) ON DUPLICATE KEY UPDATE v=VALUES(v)")->execute([$k,$v]); }
    jsonout(['message'=>'saved']);
  } else {
    $rows=$pdo->query("SELECT k,v FROM settings")->fetchAll(PDO::FETCH_KEY_PAIR);
    jsonout($rows);
  }
}

jsonout(['error'=>'Not found'],404);
