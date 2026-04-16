# VPS Setup Guide

## Architecture

```
Mac (Source of Truth)          VPS (Remote Compute)
─────────────────────          ────────────────────
Claude Code CLI                Long-running agents
~/Documents/                   systemd daemons
~/CLAUDE.md                    Python scripts
                               Screen sessions
        ↕ WireGuard VPN
        ↕ SSHFS mount (/vps → VPS /root)
        ↕ rsync sync
```

**Why this matters:** Claude Code runs on Mac (your terminal), but heavy tasks
(scraping, batch enrichment, 24/7 daemons) run on the VPS to keep your Mac free.

---

## Recommended VPS Specs

| Resource | Minimum | Recommended |
|---|---|---|
| vCPU | 2 | 4–6 |
| RAM | 4 GB | 8–12 GB |
| Storage | 40 GB SSD | 100–200 GB |
| Network | 100 Mbps | 1 Gbps |
| OS | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| Location | EU preferred | EU preferred (GDPR) |

**Providers:** Contabo (cheapest), Hetzner (best value/reliability), OVH (EU-only)

---

## Step 1 — Initial VPS hardening

```bash
# On VPS (as root):

# Update system
apt update && apt upgrade -y

# Create deploy user (optional but recommended)
useradd -m -s /bin/bash deploy
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys

# Harden SSH
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
systemctl restart sshd

# Install fail2ban
apt install -y fail2ban
systemctl enable fail2ban --now

# Firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 51820/udp   # WireGuard
ufw enable
```

---

## Step 2 — WireGuard VPN

WireGuard creates a private encrypted tunnel between Mac and VPS.
Subnet: `10.X.0.0/24` (customize X to your preference)

### VPS side:
```bash
apt install -y wireguard

# Generate keys
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
chmod 600 /etc/wireguard/server_private.key

VPS_PRIV=$(cat /etc/wireguard/server_private.key)
VPS_PUB=$(cat /etc/wireguard/server_public.key)
echo "VPS public key: $VPS_PUB"

# Create config (replace 10.YOUR_WG with your chosen subnet, e.g. 10.77)
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $VPS_PRIV
Address = 10.YOUR_WG.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# Mac
PublicKey = MAC_PUBLIC_KEY_HERE
AllowedIPs = 10.YOUR_WG.0.2/32
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

systemctl enable wg-quick@wg0 --now
```

### Mac side:
```bash
brew install wireguard-tools

# Generate Mac keys
wg genkey | tee ~/.config/wireguard/mac_private.key | wg pubkey > ~/.config/wireguard/mac_public.key
MAC_PRIV=$(cat ~/.config/wireguard/mac_private.key)
MAC_PUB=$(cat ~/.config/wireguard/mac_public.key)
echo "Mac public key: $MAC_PUB"  # Put this in VPS config above

mkdir -p /etc/wireguard
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $MAC_PRIV
Address = 10.YOUR_WG.0.2/24
DNS = 1.1.1.1

[Peer]
# VPS
PublicKey = VPS_PUBLIC_KEY_HERE
Endpoint = YOUR_VPS_PUBLIC_IP:51820
AllowedIPs = 10.YOUR_WG.0.1/32
PersistentKeepalive = 25
EOF

# Update VPS wg0.conf with Mac's public key, then:
wg-quick up wg0

# Test
ping 10.YOUR_WG.0.1   # Should reach VPS
```

---

## Step 3 — SSHFS mount (VPS files on Mac)

```bash
# Mac
brew install --cask macfuse
brew install gromgit/fuse/sshfs-mac

mkdir -p ~/mnt/vps

# Mount VPS /root to ~/mnt/vps
sshfs root@10.YOUR_WG.0.1:/root ~/mnt/vps \
  -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 \
  -o allow_other,defer_permissions

# Make it persistent (add to cron or launchd)
# Simple cron approach (check every 5 min):
echo "*/5 * * * * mountpoint -q $HOME/mnt/vps || sshfs root@10.YOUR_WG.0.1:/root $HOME/mnt/vps -o reconnect,ServerAliveInterval=15" | crontab -
```

---

## Step 4 — Install Claude Code on VPS

```bash
# On VPS:
curl -fsSL https://claude.ai/install.sh | sh

# Create credentials directory
mkdir -p /root/.credentials
chmod 700 /root/.credentials

# Copy mcp-keys.env from Mac (after SSHFS mount)
# From Mac:
cp ~/.claude/mcp-keys.env ~/mnt/vps/.claude/mcp-keys.env
chmod 600 ~/mnt/vps/.claude/mcp-keys.env

# Sync ~/.claude/ to VPS
rsync -avz ~/.claude/ root@YOUR_VPS_IP:/root/.claude/ \
  --exclude='projects/-Users-*/memory/*' \
  --exclude='mcp-keys.env'
```

---

## Step 5 — Sync strategy

**Recommended sync flow:**

```bash
# Mac → VPS (push config changes)
rsync -avz ~/.claude/rules/ root@YOUR_VPS_IP:/root/.claude/rules/
rsync -avz ~/.claude/expertise/ root@YOUR_VPS_IP:/root/.claude/expertise/
rsync -avz ~/.claude/skills/ root@YOUR_VPS_IP:/root/.claude/skills/

# VPS → Mac (pull generated data, logs)
rsync -avz root@YOUR_VPS_IP:/root/data/ ~/data/
```

Add a shell alias for convenience:
```bash
alias sync-vps='rsync -avz ~/.claude/rules/ ~/.claude/expertise/ ~/.claude/skills/ root@YOUR_VPS_IP:/root/.claude/'
```

---

## Step 6 — Running agents on VPS

For long-running Claude Code sessions on VPS, use `screen` or `tmux`:

```bash
# On VPS:
apt install -y tmux screen

# Start a named session
screen -S claude-agent
# or
tmux new -s claude-agent

# Inside the session:
cd /root/workspace
source /root/.claude/mcp-keys.env
claude

# Detach: Ctrl+A, D (screen) or Ctrl+B, D (tmux)
# Reattach:
screen -r claude-agent
tmux attach -t claude-agent
```

---

## Step 7 — Update ecosystem-map.md

After setup, update `~/.claude/rules/ecosystem-map.md`:
```markdown
## SSH
- VPS: `ssh root@YOUR_VPS_IP` | X GB / Y vCPU / Z GB storage
- Mac: `ssh mac` (10.X.0.2) nebo ~/mnt/vps/ (SSHFS)
- WG: 10.X.0.0/24 (VPS=.1, Mac=.2)
```

---

## Troubleshooting

**WireGuard not connecting:**
```bash
wg show          # Check peer status on both sides
ufw status       # Verify port 51820/udp is open on VPS
ping YOUR_VPS_PUBLIC_IP  # Basic connectivity
```

**SSHFS mount drops:**
```bash
# Force remount
umount ~/mnt/vps 2>/dev/null; sshfs root@10.X.0.1:/root ~/mnt/vps -o reconnect
```

**rsync permission errors:**
```bash
# Ensure SSH key auth works
ssh root@YOUR_VPS_IP 'echo ok'
# Check key in ~/.ssh/authorized_keys on VPS
```
