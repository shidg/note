##sign验证文件完整性##
gpg --verify git-2.2.0.tar.sign git-2.2.0.tar
#提示如下
#SA key ID 96AFE6CB
#gpg: Can't check signature: No public key

#获取public key
gpg --recv-keys 96AFE6CB
gpg --verify git-2.2.0.tar.sign git-2.2.0.tar
#输出如下：
#gpg: Signature made Thu 27 Nov 2014 06:42:48 AM CST using RSA key ID 96AFE6CB
#gpg: Good signature from "Junio C Hamano <gitster@pobox.com>"
#gpg:                 aka "Junio C Hamano <jch@google.com>"
#gpg:                 aka "Junio C Hamano <junio@pobox.com>"
#gpg: WARNING: This key is not certified with a trusted signature!
#gpg:          There is no indication that the signature belongs to the owner.
#Primary key fingerprint: 96E0 7AF2 5771 9559 80DA  D100 20D0 4E5A 7136 60A7
#     Subkey fingerprint: E1F0 36B1 FEE7 221F C778  ECEF B0B5 E886 96AF E6CB

