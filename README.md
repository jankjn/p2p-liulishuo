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
默认已有账号:

```javascript
 { username: 'lender', password: 'lender', deposit: 100 }
 { username: 'borrower', password: 'borrower', deposit: 0 }
```
调用示例(using [httpie](https://httpie.org/))

```sh
# 登录
http p2p-liulishuo.herokuapp.com/login username=lender password=lender
{
    "id": 1,
    "token": "cd9e8c61-d0a7-4d55-b1b4-523dc1608659"
}

# 查看账户列表
http p2p-liulishuo.herokuapp.com/accounts 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
[
    {
        "created_at": "2017-03-22T08:44:51.991Z",
        "deposit": "0.0",
        "id": 2,
        "updated_at": "2017-03-22T08:44:51.998Z",
        "username": "borrower"
    },
    {
        "created_at": "2017-03-22T08:44:51.889Z",
        "deposit": "100.0",
        "id": 1,
        "updated_at": "2017-03-22T11:05:11.864Z",
        "username": "lender"
    }
]
# 发起借款请求
http POST p2p-liulishuo.herokuapp.com/loans lender_id:=1 borrower_id:=2 amount:=100 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
{
    "amount": "100.0",
    "borrower_id": 2,
    "confirmed": false,
    "created_at": "2017-03-22T11:23:53.559Z",
    "id": 1,
    "lender_id": 1,
    "updated_at": "2017-03-22T11:23:53.559Z"
}
# 同意借款请求
http POST p2p-liulishuo.herokuapp.com/loans/1/confirm 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
{
    "amount": "100.0",
    "borrower_id": 2,
    "confirmed": true,
    "created_at": "2017-03-22T11:23:53.559Z",
    "id": 1,
    "lender_id": 1,
    "updated_at": "2017-03-22T11:25:04.456Z"
}
# 查看账户状态
http p2p-liulishuo.herokuapp.com/accounts/1 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
{
    "borrows": "0.0",
    "deposit": "0.0",
    "lends": "100.0"
}
# 查看与2号用户之间的债务状态
http 'p2p-liulishuo.herokuapp.com/accounts/1?with=2' 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
{
    "borrows": "0.0",
    "lends": "100.0"
}
# 还钱(失败，当前用户必须为还款记录中的借款者)
http POST p2p-liulishuo.herokuapp.com/pay_backs lender_id:=1 borrower_id:=2 amount:=100 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
HTTP/1.1 403 Forbidden
{
    "error": "only borrower can confirm a loan"
}
# 还钱(登录使用借款者的 token)
http POST p2p-liulishuo.herokuapp.com/pay_backs lender_id:=1 borrower_id:=2 amount:=100 'Authorization: Token token=7a7f055d-dd4e-4f36-acbc-61f93db78532'
{
    "amount": "100.0",
    "borrower_id": 2,
    "created_at": "2017-03-22T11:30:27.661Z",
    "id": 1,
    "lender_id": 1,
    "updated_at": "2017-03-22T11:30:27.661Z"
}
# 还钱后的两者债务状况
http 'p2p-liulishuo.herokuapp.com/accounts/1?with=2' 'Authorization: Token token=cd9e8c61-d0a7-4d55-b1b4-523dc1608659'
{
    "borrows": "0.0",
    "lends": "0.0"
}

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

