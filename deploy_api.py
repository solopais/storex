import paramiko, sys

HOST='101.43.110.190'; USER='root'; PWD='Haozai666'
LOCAL=r'D:\phpstudy_pro\WWW\storex\api.php'

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(HOST, username=USER, password=PWD, timeout=20)

_, out, _ = ssh.exec_command("for d in /www/wwwroot/*/; do if [ -f \"${d}api.php\" ]; then echo \"$d\"; fi; done")
root = out.read().decode().strip().split('\n')[0]
if not root:
    print("ERR: 找不到站点根"); sys.exit(1)
print("ROOT:", root)

sftp = ssh.open_sftp()
remote = root + 'api.php'
sftp.put(LOCAL, remote)
sftp.close()
print("uploaded ->", remote)

ssh.exec_command("chown -R www:www " + remote)
print("chown done")

_, o2, e2 = ssh.exec_command("cd " + root + " && /www/server/php/80/bin/php sync-hash.php 2>&1; echo '---'; /www/server/php/80/bin/php -r \"require 'functions.php'; if(function_exists('refresh_license_hash')){refresh_license_hash();echo 'refreshed';}else{echo 'no-func';}\" 2>&1")
print(o2.read().decode())
print("ERR:", e2.read().decode())

ssh.close()
print("DONE")
