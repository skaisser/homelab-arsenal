# 📈 TrueNAS Scale Job Management

Comprehensive guide for managing system jobs, tasks, and services in TrueNAS Scale.

## 📋 Table of Contents
- [System Jobs](#-system-jobs)
- [Service Management](#-service-management)
- [Task Scheduling](#-task-scheduling)
- [Job Monitoring](#-job-monitoring)
- [Troubleshooting](#-troubleshooting)

## 📊 System Jobs

### List Active Jobs
```bash
# List all running jobs
systemctl list-jobs

# Show specific job details
systemctl status job_name

# List failed jobs
systemctl --failed
```

### Job Control
```bash
# Stop/Kill a job
systemctl stop job_name
systemctl kill job_name

# Restart a job
systemctl restart job_name

# Reset failed job status
systemctl reset-failed job_name
```

## ⚙️ Service Management

### Service Operations
```bash
# List all services
systemctl list-units --type=service

# Check service status
systemctl status service_name

# Start/Stop service
systemctl start service_name
systemctl stop service_name

# Enable/Disable on boot
systemctl enable service_name
systemctl disable service_name
```

## 📅 Task Scheduling

### Cron Jobs
```bash
# Edit user crontab
crontab -e

# List user cron jobs
crontab -l

# View system cron jobs
cat /etc/crontab
```

### Example Cron Entries
```bash
# Run daily at 2 AM
0 2 * * * /usr/local/bin/backup_script.sh

# Run every 5 minutes
*/5 * * * * /usr/local/bin/check_service.sh

# Run weekly on Sunday at 1 AM
0 1 * * 0 /usr/local/bin/weekly_maintenance.sh
```

## 📋 Job Monitoring

### View Job Logs
```bash
# View system journal
journalctl

# Follow job logs in real-time
journalctl -f -u job_name

# View logs since last boot
journalctl -b -u job_name

# Show logs with timestamps
journalctl --since "1 hour ago" -u job_name
```

### Resource Usage
```bash
# Monitor process resources
top -c

# View specific job resources
systemctl status job_name

# Check CPU/Memory usage
ps aux | grep job_name
```

## 🔧 Troubleshooting

### Common Issues

1. **Failed Jobs**
   ```bash
   # Check job status
   systemctl status job_name
   
   # View error logs
   journalctl -xe -u job_name
   ```

2. **Stuck Jobs**
   ```bash
   # List hanging jobs
   systemctl list-jobs
   
   # Force stop job
   systemctl kill -s SIGKILL job_name
   ```

3. **Resource Issues**
   ```bash
   # Check system resources
   top
   
   # View process tree
   pstree -p job_pid
   ```

### Best Practices

#### Job Management
- Use descriptive job names
- Set appropriate timeouts
- Implement logging
- Monitor resource usage

#### Scheduling
- Stagger job start times
- Set realistic intervals
- Consider dependencies
- Plan for failures

#### Maintenance
- Regular log rotation
- Clean up old job files
- Document job purposes
- Test job recovery

> 💡 **Pro Tips**:
> - Use `nice` for low-priority jobs
> - Set up job notifications
> - Implement job timeouts
> - Keep logs organized

## 📊 Quick Reference

### Common Commands
```bash
# Job Operations
systemctl status    # Check job status
systemctl start     # Start job
systemctl stop      # Stop job
systemctl restart   # Restart job

# Log Viewing
journalctl          # View logs
journalctl -f       # Follow logs
journalctl -u       # Unit logs

# Scheduling
crontab -e          # Edit schedule
crontab -l          # List schedule
```

### Monitoring Commands
```bash
# System monitoring
top                 # Process viewer
htop                # Enhanced top
ps aux              # Process status

# Log monitoring
tail -f            # Follow log file
grep -r "error"     # Search logs
```

---

✅ Use this guide as a reference for managing jobs and services in TrueNAS Scale. Always test commands in a safe environment first.
