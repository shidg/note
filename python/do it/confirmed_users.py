#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#

# 创建一个待验证用户列表
unconfirmed_users = ['alice','brian','candace']

# 创建一个用于存储已验证用户的空列表
confirmed_users = []

# 验证每个用户，直到没有未验证的用户为止
# 将每个经过验证的列表都移到已验证的用户列表中

while unconfirmed_users:
    current_user = unconfirmed_users.pop()

    print("Verifying user: " + current_user.title())
    confirmed_users.append(current_user)

#显示所有已验证用户
print("\nThe following users have been confirmed: ")

for confirmed_user in confirmed_users:
    print(confirmed_user.title())


