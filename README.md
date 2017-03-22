### 基本思路
- 记录借款和还款记录
- 用户实体记录认证信息和存款余额
- 借款记录创建时默认未生效，须经借出者确认再生效
- 借款记录创建时和确认时都会检查是否满足条件
- 满足条件的还款立即生效
- 修改两个用户存款的操作在同一事务中进行
- 用户借出数额为用户作为借出者时借出记录与还款记录之差
- 用户借得数额为用户作为借取者时借出记录与还款记录之差
- 若要计算两个用户之间的债务记录就加上另一个用户作为借出者或者借取者的条件

### demo 地址（仅api）
https://p2p-liulishuo.herokuapp.com/

```
# bin/rake routes
      Prefix Verb URI Pattern                  Controller#Action
confirm_loan POST /loans/:id/confirm(.:format) loans#confirm
       loans GET  /loans(.:format)             loans#index
             POST /loans(.:format)             loans#create
        loan GET  /loans/:id(.:format)         loans#show
   pay_backs GET  /pay_backs(.:format)         pay_backs#index
             POST /pay_backs(.:format)         pay_backs#create
    pay_back GET  /pay_backs/:id(.:format)     pay_backs#show
    accounts GET  /accounts(.:format)          accounts#index
             POST /accounts(.:format)          accounts#create
     account GET  /accounts/:id(.:format)      accounts#show
     sign_up POST /sign_up(.:format)           accounts#create
       login POST /login(.:format)             sessions#create
```

### api doc
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

