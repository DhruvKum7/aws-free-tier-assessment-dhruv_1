<!-- README.md for aws-free-tier-assessment-dhruv_1 -->

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&height=230&text=AWS%20Cloud%20Infrastructure%20Lab&fontAlign=50&fontAlignY=35&color=0:0f172a,100:22c55e&fontColor=ffffff&animation=fadeIn" alt="AWS Cloud Infrastructure Lab banner"/>
</p>

<p align="center">
  <b>Designed, automated and cost-monitored a production-style AWS setup using Terraform.</b><br/>
  <sub>VPC · Subnetting · NAT/IGW · EC2 · ALB · Auto Scaling · RDS · ElastiCache · Billing Alarms · Architecture Design</sub>
</p>

---

<p align="center">
  <img src="https://skillicons.dev/icons?i=aws,terraform,linux,git,github" alt="Tech stack icons"/>
</p>

<p align="center">
  <a href="#-project-snapshot">Overview</a> •
  <a href="#-architecture--3d-view">Architecture</a> •
  <a href="#-what-i-implemented">What I Implemented</a> •
  <a href="#-how-to-run-quickly">How to Run</a> •
  <a href="#-why-this-project-matters">Why This Project Matters</a>
</p>

---

## 🚀 Project Snapshot

This repo is a hands-on AWS lab where I treated a **simple web app like a real production system**:

- Built a **fully custom VPC** from scratch (not default VPC).
- Deployed a **resume website on EC2 with Nginx** using **user_data**.
- Uplifted it to a **highly-available architecture** with **ALB + Auto Scaling Group** across multiple AZs.
- Implemented **cost-awareness** using **Free Tier alerts** and **CloudWatch billing alarms**.
- Designed a **multi-tier architecture** (web, app, DB, cache) to handle **~10,000 concurrent users**.

Everything infrastructure-related is **as-code** with Terraform.

---

## 🧱 Repository Layout

```text
.
├── q1-vpc/                    # Custom VPC, public/private subnets, IGW, NAT Gateway
├── q2-ec2-static-site/        # EC2 + Nginx static resume site in public subnet
├── q3-ha-asg-alb/             # ALB + Auto Scaling Group in private subnets
├── q4-billing-notes/          # Free-tier alerts + billing alarm screenshots
└── q5-architecture-diagram/   # High-level architecture diagram (PDF/PNG)
