# jenkins  ssh 方式添加git仓库
1.  Change "Host Key Verification Strategy" to "Accept first connection" 
    Dashboard > Manage Jenkins > Configure Global Security > Git Host Key Verification Configuration. Then in Host Key Verification Strategy select Accept first connection.
2.  系统管理 > credentials(凭据) > 全局 > 添加凭据> ssh username whith privete key
