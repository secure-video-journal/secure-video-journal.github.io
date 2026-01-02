---
layout: post
title:  "How Secure Video Journal Encrypts Your Memories"
date:   2025-07-02 09:00:00 +0100
categories: security privacy
published: false
description: "A technical walkthrough of how your video diary travels from camera to encrypted archive—and back only when you ask."
# image: /assets/img/encrypted-memories.png
---

Video diaries are as personal as it gets.  
Here’s the exact path a clip takes from your camera to our encrypted archive—and back only when you ask for it.

---

### 1. Capture → Encrypted Upload  

1. **Browser → S3** over TLS 1.3 (multipart, resumable).  
2. Upload lands in an **S3 bucket with Server-Side Encryption** (AES-256, SSE-KMS).  
3. A one-time **signed URL** prevents anyone replaying the POST.

*(diagram placeholder)*  
<!-- replace /assets/img/ingest-arch.png -->

---

### 2. Transcription in a Sealed Room  

* Clips are pulled into an **isolated processing VPC**—no public IPs.  
* A transcoder strips metadata; frames live only in RAM.  
* Transcripts stay on our subnet; nothing goes to third-party LLM endpoints.

---

### 3. Cue Extraction Pipeline  

* **Whisper-large** (fine-tuned) for verbals → token timestamps  
* **MediaPipe Face & Pose** for micro-expressions + posture vectors  
* Aggregated cues stored as **JSON blobs**—no raw video leaves the node.

---

### 4. Storage & Key Management  

| Layer | Key type | Rotation |
|-------|----------|----------|
| S3 objects | AWS KMS CMK | 12 months |
| Transcripts | Same CMK, separate prefix | 12 months |
| Derived cues | Client-side AES-GCM (future Zero-Knowledge tier) | User-controlled |

Deleting an entry **shreds the object + cues + transcript** and queues the CMK for later key-material deletion (7-day safety window).

---

### 5. Access Control  

* Each clip tagged with the user’s Cognito ID → IAM policy denies *any* role outside that ID.  
* Admin console can read **metadata only**, never content.

---

### 6. Sharing—If You Want To  

Generate a **48-hour, view-only link** → client fetches a short-lived decryption token → plays in sandboxed player (screenshots blocked by CSS + JavaScript).

---

### 7. Coming Soon: Passphrase-Protected Clips  

We’re testing optional **client-side AES-GCM**:  
*Encrypt first, upload second.* Our servers would see only ciphertext; cue extraction would run in a secure enclave.

---

**Bottom line:** every diary stays encrypted by default, analysed inside a sealed room, and leaves our storage only when *you* export it.

---

Questions? Ping us anytime or read the full technical white-paper (<https://securevideojournal.com/whitepaper.pdf>).

