<?php require_once __DIR__.'/../config.php';
$path=$_GET['path']??'';
if($path==='login'){
  $email=$_POST['email']??''; $pass=$_POST['password']??'';
  $st=$pdo->prepare("SELECT * FROM users WHERE email=? AND role IN ('employer','admin','owner')"); $st->execute([$email]); $u=$st->fetch(PDO::FETCH_ASSOC);
  if(!$u || !password_verify($pass,$u['password'])) jsonout(['message'=>'بيانات غير صحيحة أو ليس لديك صلاحية شركة.'],401);
  jsonout(['token'=>token_for($u),'user'=>['id'=>$u['id'],'role'=>$u['role'],'full_name'=>$u['full_name']]]);
}
jsonout(['error'=>'Not found'],404);
