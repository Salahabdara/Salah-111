<?php require_once __DIR__.'/../config.php';
$path=$_GET['path']??'';

if($path==='match'){
  $u=require_role(['employer','admin','owner']);
  $title=trim($_POST['title']??''); $exp=intval($_POST['exp']??0); $skills=strtolower(trim($_POST['skills']??''));
  $rows=$pdo->query("SELECT id,full_name,skills_text,experience_years FROM users WHERE role='candidate' LIMIT 300")->fetchAll(PDO::FETCH_ASSOC);
  $terms=array_filter(array_map('trim', explode(',', $skills)), fn($s)=>$s!=='');
  $out=[];
  foreach($rows as $r){
    $score=0; $s= strtolower($r['skills_text'] ?? '');
    foreach($terms as $t){ if($t && str_contains($s, strtolower($t))) $score+=20; }
    $score += max(0, min(40, ($r['experience_years']??0) >= $exp ? 40 : 10));
    $score=min(100, $score);
    $out[]=['id'=>$r['id'],'full_name'=>$r['full_name'],'match_percent'=>intval($score),'can_download'=>false];
  }
  jsonout(['job_id'=>0,'results'=>$out]);
}

if($path==='request-access'){
  $u=require_role(['employer','admin','owner']);
  $job_id=intval($_POST['job_id']??0); $cand=intval($_POST['candidate_id']??0);
  $pdo->prepare("INSERT INTO access_requests(employer_id,job_id,candidate_id,status,created_at) VALUES(?,?,?,?,NOW())")->execute([$u['id'],$job_id,$cand,'pending']);
  jsonout(['message'=>'تم إرسال الطلب إلى الإدارة.']);
}

if($path==='cv-download'){
  $u=token_user(); if(!$u) jsonout(['message'=>'Unauthorized'],401);
  $cand=intval($_GET['candidate_id']??0); $job=intval($_GET['job_id']??0);
  if(!in_array($u['role'], ['admin','owner'])){
    $st=$pdo->prepare("SELECT 1 FROM job_access WHERE employer_id=? AND (job_id=? OR ?=0) AND active_until>=NOW()");
    $st->execute([$u['id'],$job,$job]);
    if(!$st->fetchColumn()){ http_response_code(402); echo json_encode(['message'=>'Payment/approval required']); exit; }
  }
  $st=$pdo->prepare("SELECT full_name,email,location,skills_text,experience_years,education FROM users WHERE id=? AND role='candidate'"); $st->execute([$cand]); $c=$st->fetch(PDO::FETCH_ASSOC);
  if(!$c) jsonout(['message'=>'Not found'],404);
  header("Content-Type: text/html; charset=utf-8");
  header("Content-Disposition: attachment; filename=candidate_cv.html");
  echo "<!doctype html><meta charset='utf-8'><style>body{font-family:Arial;padding:20px}h1{margin:0 0 10px} .muted{color:#555}</style>";
  echo "<h1>".htmlspecialchars($c['full_name'])."</h1>";
  echo "<div class='muted'>".htmlspecialchars($c['email']??'')." — ".htmlspecialchars($c['location']??'')."</div>";
  echo "<h3>الخبرة</h3><div>".intval($c['experience_years'])." سنوات</div>";
  echo "<h3>المهارات</h3><pre>".htmlspecialchars($c['skills_text']??'')."</pre>";
  echo "<h3>التعليم</h3><div>".htmlspecialchars($c['education']??'')."</div>";
  exit;
}

jsonout(['error'=>'Not found'],404);
