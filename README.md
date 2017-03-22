```
# 创建账户
POST /sign_up
body(json):
{
    username: 'bill',
    password: 'rich',
    deposit: 200
}
return:
账户名已存在：报错信息 400
创建成功：帐户 id 与 token

# 登录
POST /login
body(json):
{
    username: 'bill',
    password: 'rich'
}
return:
登录失败: 报错信息 401
登录成功: 账户 id 与 token

⚠️：除注册登录接口其他所有接口调用时都须在header中放入
Authorization: Token token=${provided token}

# 查看账户情况
GET /accounts/:id?with=:other_id
return:
不提供 with 参数时返回单个用户的账户情况
提供 with 参数时返回两个用户之间的借入借出金额

# 查看所有账户(仅余额)
GET /accounts
```
```
# 创建借款请求
POST /loans
body(json):
{
    lender_id: 1,
    borrower_id: 2,
    amount: 50,
}
return:
金额不足以借出：报错信息 400
借款请求创建成功：创建成功的借款信息 200

# 接受借款请求
POST /loans/:id/confirm
body: empty
return:
金额不足以借出：报错信息 400
借款请求通过：被修改成已确认的借款信息 200

# 查看所有借款请求
GET /loans

# 查看单个借款请求
GET /loans/:id
```
```
# 发起还款
POST /pay_backs
body(json):
{
    lender_id: 1,
    borrower_id: 2,
    amount: 50,
}
return:
金额不足以还款：报错信息 400
还款超过借款：报错信息 400
还款成功：还款信息 200

# 查看所有还款
GET /pay_backs

# 查看单个还款
GET /pay_backs/:id
```

