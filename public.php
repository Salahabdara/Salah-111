<?php require_once __DIR__.'/../config.php';
$path=$_GET['path']??'';
if($path==='home'){
  $settings=['site_name'=>null,'site_tagline'=>null];
  foreach(['site_name','site_tagline'] as $k){ $st=$pdo->prepare("SELECT v FROM settings WHERE k=?"); $st->execute([$k]); $settings[$k]=$st->fetchColumn(); }
  $fj=$pdo->query("SELECT id,title,company_name,location FROM jobs WHERE published=1 AND featured=1 ORDER BY id DESC LIMIT 6")->fetchAll(PDO::FETCH_ASSOC);
  $ft=$pdo->query("SELECT id,title,issuer,location FROM tenders WHERE published=1 AND featured=1 ORDER BY id DESC LIMIT 6")->fetchAll(PDO::FETCH_ASSOC);
  $ads=$pdo->query("SELECT title,image_url,target_url FROM ads WHERE active=1 AND (placement='home' OR placement='all') ORDER BY id DESC LIMIT 6")->fetchAll(PDO::FETCH_ASSOC);
  jsonout(['settings'=>$settings,'featured_jobs'=>$fj,'featured_tenders'=>$ft,'ads'=>$ads]);
}
if($path==='jobs'){ jsonout($pdo->query("SELECT id,title,company_name,location FROM jobs WHERE published=1 ORDER BY id DESC")->fetchAll(PDO::FETCH_ASSOC)); }
if($path==='job'){ $id=intval($_GET['id']??0); $st=$pdo->prepare("SELECT * FROM jobs WHERE id=? AND published=1"); $st->execute([$id]); jsonout($st->fetch(PDO::FETCH_ASSOC)?:[]); }
if($path==='tenders'){ jsonout($pdo->query("SELECT id,title,issuer,location FROM tenders WHERE published=1 ORDER BY id DESC")->fetchAll(PDO::FETCH_ASSOC)); }
if($path==='tender'){ $id=intval($_GET['id']??0); $st=$pdo->prepare("SELECT * FROM tenders WHERE id=? AND published=1"); $st->execute([$id]); jsonout($st->fetch(PDO::FETCH_ASSOC)?:[]); }
jsonout(['error'=>'Not found'],404);
