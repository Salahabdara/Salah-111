CREATE DATABASE IF NOT EXISTS yemenhr_db;
USE yemenhr_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('job_seeker', 'employer', 'admin') DEFAULT 'job_seeker',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employer_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(150),
    salary DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employer_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tenders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    deadline DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    cover_letter TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS admin_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT IGNORE INTO users (id,name,email,password,role) VALUES
(1,'مدير الموقع','admin@example.com','$2y$10$hY1o1u2p0wz5l6e7f8g9qu7Eo3H1CkH1E1Z3f3s8v2o7r1zQFQm6e','admin'),
(2,'شركة المستقبل','future@example.com','$2y$10$0bR0c8Q9YyVZv2nZl2iR2eZ8mHf5S1f8a9X4u1mN9o2Pq1KfG3r7K','employer'),
(3,'أحمد علي','ahmed@example.com','$2y$10$XyZ1a2B3c4D5e6F7g8H9iuz0v1w2x3y4z5A6b7C8d9E0f1G2h3I4','job_seeker');

INSERT IGNORE INTO jobs (employer_id, title, description, location, salary) VALUES
(2, 'مهندس برمجيات', 'مطلوب مهندس برمجيات بخبرة 3 سنوات', 'صنعاء', 800.00),
(2, 'مصمم جرافيك', 'مصمم مبدع للعمل بدوام كامل', 'عدن', 600.00);

INSERT IGNORE INTO tenders (title, description, deadline) VALUES
('توريد أجهزة كمبيوتر', 'توريد 50 جهاز كمبيوتر لمؤسسة حكومية', '2025-09-30'),
('إنشاء مبنى إداري', 'بناء مبنى إداري من 3 طوابق', '2025-12-15');


ALTER TABLE jobs ADD COLUMN IF NOT EXISTS logo_path VARCHAR(255) NULL;


ALTER TABLE jobs ADD COLUMN IF NOT EXISTS logo_path VARCHAR(255) NULL;

-- v3: حقل مسار السيرة الذاتية للطلبات
ALTER TABLE applications ADD COLUMN IF NOT EXISTS resume_path VARCHAR(255) NULL;
CREATE INDEX IF NOT EXISTS idx_jobs_created ON jobs(created_at);
CREATE INDEX IF NOT EXISTS idx_jobs_salary ON jobs(salary);
CREATE INDEX IF NOT EXISTS idx_jobs_title ON jobs(title);

-- v4: حالة الطلب
ALTER TABLE applications ADD COLUMN IF NOT EXISTS status ENUM('new','in_review','rejected','accepted') DEFAULT 'new';
CREATE INDEX IF NOT EXISTS idx_apps_status ON applications(status);

-- v5: حقول ملف المرشح + متطلبات الوظيفة + درجة المطابقة
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS phone VARCHAR(60) NULL,
  ADD COLUMN IF NOT EXISTS city VARCHAR(120) NULL,
  ADD COLUMN IF NOT EXISTS country VARCHAR(120) NULL,
  ADD COLUMN IF NOT EXISTS dob DATE NULL,
  ADD COLUMN IF NOT EXISTS education_level ENUM('primary','secondary','diploma','bachelor','master','phd') NULL,
  ADD COLUMN IF NOT EXISTS major VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS institution VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS grad_year INT NULL,
  ADD COLUMN IF NOT EXISTS total_experience_years DECIMAL(4,1) NULL,
  ADD COLUMN IF NOT EXISTS last_job_title VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS last_company VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS last_job_desc TEXT NULL,
  ADD COLUMN IF NOT EXISTS skills_text TEXT NULL;

ALTER TABLE jobs
  ADD COLUMN IF NOT EXISTS required_skills_text TEXT NULL,
  ADD COLUMN IF NOT EXISTS min_experience_years DECIMAL(4,1) NULL,
  ADD COLUMN IF NOT EXISTS required_education_level ENUM('primary','secondary','diploma','bachelor','master','phd') NULL;

ALTER TABLE applications
  ADD COLUMN IF NOT EXISTS match_score INT NULL;

-- v6: توسعة الملف الشخصي + متطلبات وظيفة متقدمة + تفسير ATS
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS languages TEXT NULL,
  ADD COLUMN IF NOT EXISTS certifications TEXT NULL,
  ADD COLUMN IF NOT EXISTS projects TEXT NULL,
  ADD COLUMN IF NOT EXISTS portfolio_url VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS linkedin_url VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS github_url VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS expected_salary INT NULL,
  ADD COLUMN IF NOT EXISTS job_type_pref ENUM('full_time','part_time','contract','remote','hybrid') NULL,
  ADD COLUMN IF NOT EXISTS willing_relocate TINYINT(1) NULL;

ALTER TABLE jobs
  ADD COLUMN IF NOT EXISTS required_languages TEXT NULL,
  ADD COLUMN IF NOT EXISTS keywords TEXT NULL,
  ADD COLUMN IF NOT EXISTS job_type ENUM('full_time','part_time','contract','remote','hybrid') NULL,
  ADD COLUMN IF NOT EXISTS salary_min INT NULL,
  ADD COLUMN IF NOT EXISTS salary_max INT NULL;

ALTER TABLE applications
  ADD COLUMN IF NOT EXISTS match_explainer TEXT NULL;

-- v7: رسائل، شركات، مقابلات، i18n
CREATE TABLE IF NOT EXISTS companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  owner_user_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  website VARCHAR(255) NULL,
  city VARCHAR(120) NULL,
  country VARCHAR(120) NULL,
  description TEXT NULL,
  logo_path VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE jobs
  ADD COLUMN IF NOT EXISTS company_id INT NULL;

CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  from_user_id INT NOT NULL,
  to_user_id INT NOT NULL,
  subject VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  job_id INT NULL,
  application_id INT NULL,
  scheduled_at DATETIME NULL,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE applications
  ADD COLUMN IF NOT EXISTS interview_at DATETIME NULL,
  ADD COLUMN IF NOT EXISTS interview_location VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS interview_note TEXT NULL;

-- v8: توصيات، حفظ، مراجعات، تحسينات SEO
CREATE TABLE IF NOT EXISTS saved_jobs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  job_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_saved (user_id, job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS saved_searches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  query TEXT NOT NULL,
  email_alert TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS company_reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  user_id INT NOT NULL,
  rating TINYINT NOT NULL, -- 1..5
  comment TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- v9: Push + Chat + Payments + Analytics
CREATE TABLE IF NOT EXISTS webpush_subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  endpoint TEXT NOT NULL,
  p256dh VARCHAR(255) NOT NULL,
  auth VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_ep (endpoint(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS chat_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  application_id INT NOT NULL,
  from_user_id INT NOT NULL,
  to_user_id INT NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE jobs
  ADD COLUMN IF NOT EXISTS is_featured TINYINT(1) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS featured_until DATETIME NULL;

CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  job_id INT NOT NULL,
  provider VARCHAR(50) NOT NULL, -- stripe
  provider_ref VARCHAR(120) NULL,
  amount_cents INT NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  status VARCHAR(40) NOT NULL DEFAULT 'created',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- v10: RBAC + Subscriptions + Invoices + AI tables
CREATE TABLE IF NOT EXISTS roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(64) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS role_permissions (
  role_id INT NOT NULL,
  permission_id INT NOT NULL,
  PRIMARY KEY(role_id, permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id INT NULL;

CREATE TABLE IF NOT EXISTS plans (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(64) UNIQUE,
  name VARCHAR(120) NOT NULL,
  price_cents INT NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  period_days INT NOT NULL DEFAULT 30,
  max_jobs INT DEFAULT 5,
  featured_slots INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  plan_id INT NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active', -- active, past_due, canceled
  current_period_start DATETIME NOT NULL DEFAULT NOW(),
  current_period_end DATETIME NOT NULL,
  next_invoice_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  subscription_id INT NOT NULL,
  amount_cents INT NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  due_date DATETIME NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'open', -- open, paid, void
  pdf_path VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- فهارس
CREATE INDEX IF NOT EXISTS idx_jobs_featured_until ON jobs(featured_until);

-- v12: Fraud tables + settings + blacklist + documents
CREATE TABLE IF NOT EXISTS settings (
  k VARCHAR(100) PRIMARY KEY,
  v TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO settings(k,v) VALUES ('fraud_alert_threshold','80'), ('fraud_alert_permission','admin_only');

CREATE TABLE IF NOT EXISTS fraud_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  candidate_user_id INT NOT NULL,
  fraud_score INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed TINYINT(1) DEFAULT 0,
  reviewed_by INT NULL,
  reviewed_at DATETIME NULL,
  review_note VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS fraud_blacklist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  candidate_user_id INT NOT NULL UNIQUE,
  fraud_score INT NOT NULL,
  reason TEXT,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS fraud_documents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  candidate_user_id INT NOT NULL,
  path VARCHAR(255) NOT NULL,
  orig_name VARCHAR(255) NOT NULL,
  mime VARCHAR(100) NOT NULL,
  uploaded_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- v13/v14 schema additions
CREATE TABLE IF NOT EXISTS talent_hunt_searches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employer_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  sector VARCHAR(100),
  level VARCHAR(50),
  skills TEXT,
  min_experience INT DEFAULT 0,
  education VARCHAR(100),
  languages VARCHAR(200),
  location VARCHAR(150),
  exclude_high_fraud TINYINT(1) DEFAULT 1,
  urgent TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS talent_hunt_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employer_id INT NOT NULL,
  name VARCHAR(150) NOT NULL,
  payload JSON,
  auto_run_enabled TINYINT(1) DEFAULT 0,
  auto_run_frequency ENUM('daily','every3','weekly','monthly','off') DEFAULT 'off',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS talent_hunt_invites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employer_id INT NOT NULL,
  candidate_user_id INT NOT NULL,
  job_title VARCHAR(200),
  message TEXT,
  status ENUM('sent','read','accepted','rejected') DEFAULT 'sent',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS talent_hunt_auto_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  template_id INT NOT NULL,
  run_at DATETIME NOT NULL,
  candidate_user_id INT NOT NULL,
  match_score INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT,
  url VARCHAR(255),
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS events_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  actor_user_id INT NULL,
  target_user_id INT NULL,
  meta JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS permissions_change_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  actor_user_id INT NOT NULL,
  target_user_id INT NOT NULL,
  changes JSON NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
