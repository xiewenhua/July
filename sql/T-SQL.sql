-- 仓库表
CREATE TABLE repositories
(
    repo_id int NOT NULL,
    repo_address char(50) NOT NULL,
    PRIMARY KEY(repo_id)
)
GO

-- 门店表
CREATE TABLE stores
(
    stor_id int NOT NULL,
    stor_address char(50) NOT NULL,
    PRIMARY KEY(stor_id)
)
GO

-- 商品表
CREATE TABLE goods
(
    good_id int NOT NULL,
    PRIMARY KEY(good_id)
)
GO

-- 供应商表
CREATE TABLE vendors
(
    vend_id int NOT NULL,
    PRIMARY KEY(vend_id)
)
GO

-- 每个门店有一个仓库
CREATE TABLE store_repositories
(
    stor_id int NOT NULL,
    repo_id int NOT NULL,
    PRIMARY KEY(stor_id, repo_id)
)
GO
ALTER TABLE  store_repositories ADD FOREIGN KEY(stor_id) REFERENCES stores(stor_id)
GO
ALTER TABLE store_repositories ADD FOREIGN KEY(repo_id) REFERENCES repositories(repo_id)
GO

-- 仓库进货批次号 批次号-仓库号-进货时间-供应商号 batch_id:进货批次号
CREATE TABLE batch
(
    batch_id int NOT NULL,
    repo_id int NOT NULL,
    batch_date datetime NOT NULL,
    vend_id int NOT NULL,
    PRIMARY KEY(batch_id)
)
GO
ALTER TABLE batch ADD FOREIGN KEY(repo_id) REFERENCES repositories(repo_id)
GO
ALTER TABLE batch ADD FOREIGN KEY(vend_id) REFERENCES vendors(vend_id)
GO

-- 每一次进货可以进多种商品    添加本批次该商品剩余数量（surplus）
CREATE TABLE batch_goods
(
    batch_id int NOT NULL,
    good_id int NOT NULL,
    purchase_price float NOT NULL,
    purchase_quantity int NOT NULL,
    surplus int NOT NULL,
    PRIMARY KEY(batch_id, good_id)
)
GO
ALTER TABLE batch_goods ADD FOREIGN KEY(good_id) REFERENCES goods(good_id)
GO
ALTER TABLE batch_goods ADD FOREIGN KEY(batch_id) REFERENCES batch(batch_id)
GO

-- 门店可以销售多种商品
CREATE TABLE storegood
(
    storegood_id int NOT NULL,
    stor_id int NOT NULL,
    good_id int NOT NULL,
    PRIMARY KEY(storegood_id)
)
GO
ALTER TABLE storegood ADD FOREIGN KEY(stor_id) REFERENCES stores(stor_id)
GO
ALTER TABLE storegood ADD FOREIGN KEY(good_id) REFERENCES goods(good_id)
GO

-- 每一种商品在同一个门店一个时刻只有一种售价
CREATE TABLE saleprices
(
    storegood_id int NOT NULL,
    sale_date datetime NOT NULL,
    sale_price float NOT NULL,
    PRIMARY KEY(storegood_id, sale_date)
)
GO
ALTER TABLE saleprices ADD FOREIGN KEY(storegood_id) REFERENCES storegood(storegood_id)
GO

-- 门店销售订单号   !!!加一个订单总金额（反范式）
CREATE TABLE orders
(
    order_num int NOT NULL,
    order_date datetime NOT NULL,
    total_amount float NOT NULL,
    PRIMARY KEY(order_num)
)
GO

-- 一个订单可以有多种商品
CREATE TABLE ordergoods
(
    ordergood_id int NOT NULL,
    order_num int NOT NULL,
    good_id int NOT NULL,
    ordergood_quantity int NOT NULL,
    PRIMARY KEY(ordergood_id)
)
GO
ALTER TABLE ordergoods ADD FOREIGN KEY(order_num) REFERENCES orders(order_num)
GO
ALTER TABLE ordergoods ADD FOREIGN KEY(good_id) REFERENCES goods(good_id)
GO

-- 收款方式
CREATE TABLE paytype
(
    paytype_id int NOT NULL,
    paytype_name char(50) NOT NULL,
    PRIMARY KEY(paytype_id)
)
GO

-- 订单的支付方式
CREATE TABLE orderpaytype
(
    order_num int NOT NULL,
    paytype_id int NOT NULL,
    PRIMARY KEY(order_num, paytype_id)
)
GO
ALTER TABLE orderpaytype ADD FOREIGN KEY(paytype_id) REFERENCES paytype(paytype_id)
GO
ALTER TABLE orderpaytype ADD FOREIGN KEY(order_num) REFERENCES orders(order_num)
GO

-- 销售订单的商品是哪些进货批次
CREATE TABLE ordergood_batch
(
    ordergood_id int NOT NULL,
    batch_id int NOT NULL,
    PRIMARY KEY(ordergood_id, batch_id)
)
GO
ALTER TABLE ordergood_batch ADD FOREIGN KEY(ordergood_id) REFERENCES ordergoods(ordergood_id)
GO
ALTER TABLE ordergood_batch ADD FOREIGN KEY(batch_id) REFERENCES batch(batch_id)
GO


-- 成本低的优先出货(自动的)
-- 创建入库单的存储过程
-- 因为入库的可能是多种商品, SQL Server 支持Table类型（MySQL是不支持的）
CREATE TYPE goodlisttype AS TABLE(
    good_id int NOT NULL,
    purchase_price float NOT NULL,
    purchase_quantity int NOT NULL
)
GO

CREATE PROC ruku(
    @batch_id int,
    @repo_id int,
    @batch_date datetime,
    @vend_id int,
    @goodlist goodlisttype  READONLY
)
AS
BEGIN
    BEGIN TRANSACTION
    INSERT INTO
    batch
    VALUES
        (@batch_id, @repo_id, @batch_date, @vend_id)
    INSERT INTO
    batch_goods
        (
        batch_id,
        good_id,
        purchase_price,
        purchase_quantity,
        surplus
        )
    SELECT
        @batch_id,
        good_id,
        purchase_price,
        purchase_quantity,
        good_id
    FROM
        @goodlist
    COMMIT TRANSACTION
END
GO

-- 执行存储过程示例


-- 创建售货单的存储过程

-- 为了测试存储过程，需要在相关表中插入几行记录
INSERT INTO repositories
VALUES(10001, '西丽'),
    (10002, '荔枝世界')
GO
INSERT INTO goods
VALUES(10001),
    (10002),
    (10003)
GO
INSERT INTO vendors
VALUES(1001),
    (1002),
    (1003)
GO

-- 定义并复制Table类型
DECLARE @goodlist AS goodlisttype
INSERT INTO @goodlist
    SELECT 10001, 543, 365
UNION ALL
    SELECT 10002, 899, 500
UNION ALL
    SELECT 10003, 788, 1000
-- 执行存储过程
EXEC ruku @batch_id =10001,@repo_id= 10001,@batch_date='2020-07-03',@vend_id=1001,@goodlist=@goodlist
GO
