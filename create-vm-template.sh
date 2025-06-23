#!/bin/bash

# Proxmox VMテンプレート作成スクリプト
# 初回のみ実行

echo "Proxmox VMテンプレート作成スクリプトを開始します。"

# Cloud-initイメージのダウンロードURL
IMG_URL="https://cloud-images.ubuntu.com/releases/noble/release/ubuntu-24.04-server-cloudimg-amd64.img"
IMG_NAME="ubuntu-24.04-server-cloudimg-amd64.img"

# テンプレートVMのIDを対話形式で入力
read -p "テンプレートVMのIDを入力してください(例:9000):" TEMPLATE_VMID

# ストレージの選択
echo "利用可能なストレージを表示します:"
pvesm status | grep -E '^(local|local-lvm|.+)' | awk '{print $1 " (" $2 ")"}'
read -p "Cloud-initイメージを保存するストレージのIDを入力してください(例:local-lvm):" STORAGE_ID

# イメージのダウンロード
echo "${IMG_NAME}をダウンロードしています..."
wget -O /var/tmp/${IMG_NAME} ${IMG_URL}

if [ $? -ne 0 ]; then
    echo "イメージのダウンロードに失敗しました。スクリプトを終了します。"
    exit 1
fi
echo "イメージのダウンロードが完了しました:/var/tmp/${IMG_NAME}"

# VMの作成
echo "テンプレートVM(ID:${TEMPLATE_VMID})を作成しています..."
qm create ${TEMPLATE_VMID} --name ubuntu-cloudinit-template --memory 2048 --net0 virtio,bridge=vmbr0

# ダウンロードしたイメージをVMのディスクとしてインポート
echo "イメージをVMディスクとしてインポートしています..."
qm importdisk ${TEMPLATE_VMID} /var/tmp/${IMG_NAME} ${STORAGE_ID}

# ディスクのアタッチとCloud-initの設定
echo "ディスクをVMにアタッチし、Cloud-initを設定しています..."
qm set ${TEMPLATE_VMID} --scsihw virtio-scsi-pci
qm set ${TEMPLATE_VMID} --scsi0 ${STORAGE_ID}:vm-${TEMPLATE_VMID}-disk-0,discard=on,ssd=1
qm set ${TEMPLATE_VMID} --ide2 ${STORAGE_ID}:cloudinit
qm set ${TEMPLATE_VMID} --boot c --bootdisk scsi0
qm set ${TEMPLATE_VMID} --serial0 socket --vga serial0
qm set ${TEMPLATE_VMID} --cpu host
qm set ${TEMPLATE_VMID} --agent 1 # QEMU Guest Agentを有効にする

# テンプレートに変換
echo "VMをテンプレートに変換しています..."
qm template ${TEMPLATE_VMID}

# 一時ファイルの削除
echo "一時ファイルを削除しています..."
rm /var/tmp/${IMG_NAME}

echo "Proxmox VMテンプレートの作成が完了しました。テンプレートID:${TEMPLATE_VMID}"
echo "このテンプレートを使用して新しいVMを作成できます。"
