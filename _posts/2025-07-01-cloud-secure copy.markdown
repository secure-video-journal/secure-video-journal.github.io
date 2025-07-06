---
layout: post
title:  "What Does It Mean to Be Cloud-Secure?"
date:   2025-07-01 09:00:00 +0100
categories: security privacy
---

Cloud storage shouldn’t feel like leaving your diary on a park bench. Yet headlines keep reminding us that *“in the cloud”* can mean *“everywhere.”*  
So what turns a plain cloud app into a **cloud-secure** one?

---

### 1. Encryption at Rest - Keys or It Didn’t Happen  

The gold-standard is **AES-256** encryption managed by cloud Key-Management Services (KMS).  
If someone grabs a hard-drive in a data-centre, they still see scrambled bytes - no key, no data.

*How we do it* → Server-side encryption (SSE-S3) with dedicated KMS keys; rotation every 12 months.

---

### 2. Encryption in Transit - TLS 1.3 as Table Stakes  

Every request travels through **TLS 1.3 with HSTS**.  
Older protocols (TLS 1.0/1.1) are disabled; certificate pinning in the mobile PWA blocks “coffee-shop” snooping.

---

### 3. Don’t Let Data Roam  

APIs talk **only** inside a private VPC; no third-party AI or analytics sees raw entries.  
Logs strip PII and age-out after 30 days.

---

### 4. Authentication ≠ Password  

* **2-Factor Auth** by default
* **Geo-lock** on admin logins  
* **Session lock-out** after 30 minutes idle

---

### 5. True Deletion - Not Just “Soft Delete”  

Click *Delete Entry* → object and transcript wiped from primary + replicated buckets, cryptographic key scheduled for hard delete after 7 days (user can undo within that window).

---

### 6. The Litmus Test  

Cloud-secure means: **if the vendor vanished tomorrow, your data would still be unreadable to anyone else.**  
Hold every service - ours included - to that bar.

---

*Next up: a deeper dive into how Secure Video Journal applies these principles clip-by-clip.*
