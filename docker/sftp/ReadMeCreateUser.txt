sudo mkdir /sftp/inanzzz
sudo mkdir /sftp/inanzzz/upload
sudo useradd -d /sftp/inanzzz -G sftp inanzzz -s /usr/sbin/nologin
echo "inanzzz:inanzzz" | sudo chpasswd
sudo chown inanzzz:sftp -R /sftp/inanzzz/upload
