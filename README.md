# RViz2 noVNC — AWS Experiment

Stripped-down version of the full ROS2 stack.
Tests only: **RViz2 streamed to browser via noVNC**.

## What was removed
- Gazebo / GzWeb
- Monaco code editor
- ttyd web terminals
- All Gazebo dependencies (~2GB saved)

## Stack
```
RViz2 → Xvfb (virtual display) → x11vnc → websockify → noVNC (browser)
```

## Local test first
```bash
docker compose build
docker compose up -d
# Open http://localhost:6090
# Then in a new terminal inside container:
docker compose exec rviz2 bash
/usr/local/bin/rviz2-wrapper
```

## AWS Setup (one time)

### 1. Create ECR repository
```bash
aws ecr create-repository \
  --repository-name rviz2-novnc \
  --region ap-northeast-1
```

### 2. Launch EC2 instance
- AMI: Ubuntu 22.04 LTS
- Instance type: t3.medium (2 vCPU, 4GB RAM minimum for RViz2)
- Security group — open inbound ports:
  - 22   (SSH)
  - 6090 (noVNC browser access)

### 3. Install Docker on EC2
```bash
sudo apt-get update
sudo apt-get install -y docker.io awscli
sudo usermod -aG docker ubuntu
```

### 4. Add GitHub Secrets
| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | IAM user key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret |
| `EC2_HOST` | EC2 public IP |
| `EC2_SSH_KEY` | EC2 private key (PEM contents) |
| `ECR_REGISTRY` | `<account-id>.dkr.ecr.ap-northeast-1.amazonaws.com` |

### 5. Push to main — pipeline does the rest
```bash
git push origin main
```

## Access RViz2
```
http://<EC2-public-ip>:6090
```

Then SSH into EC2 and run:
```bash
docker exec -it rviz2 bash
source /opt/ros/galactic/setup.bash
/usr/local/bin/rviz2-wrapper
```

## Port reference
| Port | Service |
|------|---------|
| 8080 | ttyd — browser terminal |
| 6090 | noVNC — RViz2 viewer |
| 5901 | VNC direct (optional) |

## Usage — two browser tabs is all you need
1. Open `http://<EC2-ip>:8080` — browser terminal
2. Open `http://<EC2-ip>:6090` — RViz2 viewer
3. In the terminal tab, run:
```bash
source /opt/ros/galactic/setup.bash
/usr/local/bin/rviz2-wrapper
```
4. RViz2 appears in the noVNC tab

## Smoke test
```bash
curl -sf http://<EC2-ip>:6090 && echo "noVNC OK"
curl -sf http://<EC2-ip>:8080 && echo "ttyd OK"
```
