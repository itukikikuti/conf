#!/bin/bash

# Proxmox VM作成スクリプト

echo "Proxmox VM作成スクリプトを開始します。"

# テンプレートVMのIDを対話形式で入力
read -p "使用するテンプレートVMのIDを入力してください (例: 9000): " TEMPLATE_VMID

# 新しいVMのIDを対話形式で入力
read -p "新しいVMのIDを入力してください (例: 100): " NEW_VMID

# 新しいVMのホスト名を対話形式で入力
read -p "新しいVMのホスト名を入力してください (例: ubuntu-server-01): " VM_HOSTNAME

# VMに割り当てるメモリサイズを対話形式で入力 (MB)
read -p "VMに割り当てるメモリサイズをMBで入力してください (例: 2048): " VM_MEMORY

# VMに割り当てるCPUコア数を対話形式で入力
read -p "VMに割り当てるCPUコア数を入力してください (例: 2): " VM_CPU_CORES

# VMのディスクサイズを対話形式で入力 (GB)
read -p "VMのディスクサイズをGBで入力してください (例: 30): " VM_DISK_SIZE

# VMを配置するストレージのIDを対話形式で入力
echo "利用可能なストレージを表示します:"
pvesm status | grep -E '^(local|local-lvm|.+)' | awk '{print $1 " (" $2 ")"}'
read -p "新しいVMのディスクを配置するストレージのIDを入力してください (例: local-lvm): " VM_STORAGE_ID

# Cloud-init設定ファイルをダウンロードして一時ファイルに保存
echo "Cloud-init設定ファイルをダウンロードしています..."
wget -O /var/tmp/cloud-config.yaml https://raw.githubusercontent.com/itukikikuti/server-auto-install/refs/heads/main/cloud-config.yaml

if [ $? -ne 0 ]; then
    echo "Cloud-init設定ファイルのダウンロードに失敗しました。スクリプトを終了します。"
    exit 1
fi
echo "Cloud-init設定ファイルのダウンロードが完了しました: /var/tmp/cloud-config.yaml"

# 新しいVMのクローン作成
echo "テンプレートVM (ID: ${TEMPLATE_VMID}) から新しいVM (ID: ${NEW_VMID}) をクローンしています..."
qm clone ${TEMPLATE_VMID} ${NEW_VMID} --name ${VM_HOSTNAME}

# VMの設定変更
echo "新しいVMの設定を変更しています..."
# ディスクサイズのリサイズ
qm resize ${NEW_VMID} scsi0 ${VM_DISK_SIZE}G
# メモリとCPUの設定
qm set ${NEW_VMID} --memory ${VM_MEMORY} --cores ${VM_CPU_CORES}
# Cloud-init設定の適用 (qm set の stdin から読み込む形式)
qm set ${NEW_VMID} --cicustom "user=local:snippets/cloud-config-${NEW_VMID}.yaml" # 後ほど作成するsnippetを参照
# Cloud-init設定ファイルをProxmoxのsnippetとしてアップロード
# (注意: Proxmoxのストレージ設定に依存しますが、通常は 'local' ストレージの 'snippets' フォルダです)
SNIPPET_STORAGE="local" # 必要に応じて変更してください
mkdir -p /var/lib/vz/snippets/
cp /var/tmp/cloud-config.yaml /var/lib/vz/snippets/cloud-config-${NEW_VMID}.yaml
qm set ${NEW_VMID} --cicustom "user=${SNIPPET_STORAGE}:snippets/cloud-config-${NEW_VMID}.yaml"

read -p "Cloud-initで作成するユーザー名: " VM_USER
read -p "初期パスワードを設定: " VM_PASSWORD

# Cloud-initのユーザー設定とネットワーク設定はqm setで指定
# ホスト名の設定
qm set ${NEW_VMID} --ciuser ${VM_USER} # Cloud-initで作成するユーザー名 (rootとして設定する例、必要に応じて変更)
qm set ${NEW_VMID} --cipassword ${VM_PASSWORD} # 初期パスワードを設定 (セキュリティのため、Cloud-initでSSHキーを設定することを推奨)
qm set ${NEW_VMID} --ipconfig0 ip=dhcp # DHCPを使用する例、固定IPが必要な場合は適宜変更
# 例: 固定IPアドレスの場合
# qm set ${NEW_VMID} --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1


# QEMU Guest Agent の有効化
qm set ${NEW_VMID} --agent 1

echo "新しいVM (ID: ${NEW_VMID}, ホスト名: ${VM_HOSTNAME}) の作成と設定が完了しました。"
echo "VMを起動しています..."
qm start ${NEW_VMID}

# 一時ファイルの削除
echo "一時ファイルを削除しています..."
rm /var/tmp/cloud-config.yaml
rm /var/lib/vz/snippets/cloud-config-${NEW_VMID}.yaml

echo "VMが正常に起動したら、Cloud-initが適用されます。"
echo "SSHで接続できるようになるまでしばらくお待ちください。"
