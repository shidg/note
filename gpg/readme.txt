##生成密钥##
gpg --gen-key

##生成“撤销证书”，以备以后密钥作废时，可以请求外部的公钥服务器撤销你的公钥
gpg --gen-revoke

##导入密钥##
gpg --import 

##删除密钥##
gpg --delete-key

##查看已有密钥##
gpg --list-keys

##二进制密钥输出为ASCII码##
gpg --armor --output public_key --export [ID]

####二进制密钥输出为ASCII码##
gpg --armor --output private-key --export-secret-keys [ID]


##上传密钥（公）到密钥服务器##
gpg --send-keys [用户ID] --keyserver hkp://subkeys.pgp.net


##获取他人公钥##
gpg --keyserver hkp://subkeys.pgp.net --search-keys [用户ID]
gpg --recv-keys ID 

##验证公钥指纹##
gpg --fingerprint [用户ID]


##对文件进行加密##
gpg --recipient [用户ID] --output demo.en.txt --encrypt(-e) demo.txt

##解密文件##
gpg --decrypt(-d) demo.en.txt --output demo.de.txt
或者直接gpg demo.en.txt



##对文件进行签名##
1. gpg --sign (-s)  demo.txt
   签名后的文件为demo.txt.gpg,二进制存储

2. gpg --clearsign demo.txt
   签名后的文件为demo.txt.asc，ASCII码存储


##生成单独的签名文件，与文件内容分开存放##
gpg --detach-sign (-b)demo.txt
生成单独的签名文件demo.txt.sig，二进制

gpg --armor --detach-sign demo.txt
生成单独的签名文件demo.txt.asc，ASCII码格式



##验证签名##
gpg --verify git-2.2.0.tar.sig （git-2.2.0.tar） 括号中的文件名可以省略 
#提示如下
#SA key ID 96AFE6CB
#gpg: Can't check signature: No public key

#获取public key
gpg --recv-keys 96AFE6CB

gpg --verify git-2.2.0.tar.sig git-2.2.0.tar
#输出如下：
#gpg: Signature made Thu 27 Nov 2014 06:42:48 AM CST using RSA key ID 96AFE6CB
#gpg: Good signature from "Junio C Hamano <gitster@pobox.com>"
#gpg:                 aka "Junio C Hamano <jch@google.com>"
#gpg:                 aka "Junio C Hamano <junio@pobox.com>"
#gpg: WARNING: This key is not certified with a trusted signature!
#gpg:          There is no indication that the signature belongs to the owner.
#Primary key fingerprint: 96E0 7AF2 5771 9559 80DA  D100 20D0 4E5A 7136 60A7
#     Subkey fingerprint: E1F0 36B1 FEE7 221F C778  ECEF B0B5 E886 96AF E6CB

