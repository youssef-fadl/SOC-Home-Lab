# 🛡️ SOC Home Lab: Suricata IDS & Elastic Stack Integration

A lightweight, containerized SOC Home Lab optimized for low-resource environments. This project demonstrates how to monitor network traffic, detect intrusions using Suricata, and visualize security events in Kibana.

---

## 📋 Table of Contents

- [Introduction](#introduction)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Step 1: Environment Preparation (PowerShell)](#step-1-environment-preparation)
- [Step 2: Deploying ELK Stack via Docker](#step-2-deploying-elk-stack-via-docker)
- [Step 3: Configuring Parrot OS & Suricata](#step-3-configuring-parrot-os--suricata)
- [Step 4: Attack Simulation & Detection](#step-4-attack-simulation)
- [Step 5: Kibana Visualization](#step-5-kibana-visualization)
- [Challenges & Solutions](#challenges--solutions)
- [Conclusion](#conclusion)

---

## 📌 Introduction

The goal of this project is to build a functional Security Operations Center (SOC) lab using minimal resources. By leveraging **Docker** and **WSL2**, we host the Elastic Stack to analyze logs forwarded from a **Parrot OS** virtual machine running **Suricata IDS**.

**Key Features:**

- Real-time Network Intrusion Detection (IDS).
- Centralized Log Management with Elasticsearch.
- Automated environment setup via PowerShell.
- Resource-friendly architecture.

---

## 🏗️ Architecture

The following diagram illustrates the data flow from the endpoint to the dashboard:

`[Parrot OS (Suricata + Filebeat)] ---> [HTTP/Logstash Interface] ---> [Elasticsearch (Docker)] ---> [Kibana]`

---

## 🔧 Prerequisites

| Requirement | Description                       |
| :---------- | :-------------------------------- |
| **RAM**     | 8GB Minimum (16GB Recommended)    |
| **OS**      | Windows 10/11 with WSL2 enabled   |
| **Tools**   | Docker Desktop, VMware/VirtualBox |
| **VM**      | Parrot OS ISO                     |

---

## 🚀 Step-by-Step Implementation (Setup & Installation)

### Step 1: Environment Preparation

Run the provided PowerShell script to automate the system configuration. The script checks for and installs the following components if they are not already present:

- **Virtualization Support:** Enables the Virtual Machine Platform and Hyper-V features.
- **WSL2:** Installs Windows Subsystem for Linux (Version 2).
- **Docker Desktop:** Downloads and installs the latest Docker environment.

> [!CAUTION]
> **CRITICAL: AUTOMATIC SYSTEM REBOOT**
> This script will **automatically restart** your computer to finalize the installation of system features. **Please save all your work and close all applications before running the script.**

#### How to run (Execution Instructions)

1.  Download the **setup_WSL2_Docker.ps1** file to your computer.
2.  Right-click on the file **setup_WSL2_Docker.ps1**.
3.  Select **Run with PowerShell**.

![SOC Lab Diagram](openPS1.png)

_Note1: The script will automatically restart your computer after the installation is complete to apply changes. Please save your work before running it._

_Note2: If you receive a script execution error, run `Set-ExecutionPolicy RemoteSigned -Scope Process` then try again._
