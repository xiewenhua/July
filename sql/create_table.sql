-- 仓库表
CREATE TABLE repositories(repo_id int NOT NULL AUTO_INCREMENT, repo_address char(50) NOT NULL, PRIMARY KEY(repo_id));

-- 门店表
CREATE TABLE stores(stor_id int NOT NULL AUTO_INCREMENT, stor_address char(50) NOT NULL, PRIMARY KEY(stor_id));

-- 商品表
CREATE TABLE goods(good_id int NOT NULL AUTO_INCREMENT, PRIMARY KEY(good_id));

-- 供应商表
CREATE TABLE vendors(vend_id int NOT NULL AUTO_INCREMENT, PRIMARY KEY(vend_id));

-- 每个门店有一个仓库
CREATE TABLE store_repositories(stor_id int NOT NULL, repo_id int NOT NULL, PRIMARY KEY(stor_id, repo_id));
ALTER TABLE  store_repositories ADD FOREIGN KEY(stor_id) REFERENCES stores(stor_id);
ALTER TABLE store_repositories ADD FOREIGN KEY(repo_id) REFERENCES repositories(repo_id);

-- 仓库进货批次号 批次号-仓库号-进货时间-供应商号 batch_id:进货批次号
CREATE TABLE batch(batch_id int NOT NULL AUTO_INCREMENT, repo_id int NOT NULL, batch_date datetime NOT NULL, vend_id int NOT NULL, PRIMARY KEY(batch_id));
ALTER TABLE batch ADD FOREIGN KEY(repo_id) REFERENCES repositories(repo_id);
ALTER TABLE batch ADD FOREIGN KEY(vend_id) REFERENCES vendors(vend_id);

-- 每一次进货可以进多种商品    添加本批次该商品剩余数量（surplus）
CREATE TABLE batch_goods(batch_id int NOT NULL, good_id int NOT NULL, purchase_price float NOT NULL, purchase_quantity int NOT NULL, surplus int NOT NULL, PRIMARY KEY(batch_id, good_id));
ALTER TABLE batch_goods ADD FOREIGN KEY(good_id) REFERENCES goods(good_id);
ALTER TABLE batch_goods ADD FOREIGN KEY(batch_id) REFERENCES batch(batch_id);

-- 门店可以销售多种商品
CREATE TABLE storegood(storegood_id int NOT NULL AUTO_INCREMENT, stor_id int NOT NULL, good_id int NOT NULL, PRIMARY KEY(storegood_id));
ALTER TABLE storegood ADD FOREIGN KEY(stor_id) REFERENCES stores(stor_id);
ALTER TABLE storegood ADD FOREIGN KEY(good_id) REFERENCES goods(good_id);

-- 每一种商品在同一个门店一个时刻只有一种售价
CREATE TABLE saleprices(storegood_id int NOT NULL, sale_date datetime NOT NULL, sale_price float NOT NULL, PRIMARY KEY(storegood_id, sale_date));
ALTER TABLE saleprices ADD FOREIGN KEY(storegood_id) REFERENCES storegood(storegood_id);

-- 门店销售订单号   !!!加一个订单总金额（反范式）
CREATE TABLE orders(order_num int NOT NULL AUTO_INCREMENT, order_date datetime NOT NULL, total_amount float NOT NULL, PRIMARY KEY(order_num));

-- 一个订单可以有多种商品
CREATE TABLE ordergoods(ordergood_id int NOT NULL AUTO_INCREMENT, order_num int NOT NULL, good_id int NOT NULL, ordergood_quantity int NOT NULL, PRIMARY KEY(ordergood_id));
ALTER TABLE ordergoods ADD FOREIGN KEY(order_num) REFERENCES orders(order_num);
ALTER TABLE ordergoods ADD FOREIGN KEY(good_id) REFERENCES goods(good_id);

-- 收款方式
CREATE TABLE paytype(paytype_id int NOT NULL AUTO_INCREMENT, paytype_name char(50) NOT NULL, PRIMARY KEY(paytype_id));

-- 订单的支付方式
CREATE TABLE orderpaytype(order_num int NOT NULL, paytype_id int NOT NULL, PRIMARY KEY(order_num, paytype_id));
ALTER TABLE orderpaytype ADD FOREIGN KEY(paytype_id) REFERENCES paytype(paytype_id);
ALTER TABLE orderpaytype ADD FOREIGN KEY(order_num) REFERENCES orders(order_num);

-- 销售订单的商品是哪些进货批次
CREATE TABLE ordergood_batch(ordergood_id int NOT NULL, batch_id int NOT NULL, PRIMARY KEY(ordergood_id, batch_id));
ALTER TABLE ordergood_batch ADD FOREIGN KEY(ordergood_id) REFERENCES ordergoods(ordergood_id);
ALTER TABLE ordergood_batch ADD FOREIGN KEY(batch_id) REFERENCES batch(batch_id);


-- 成本低的优先出货(自动的)

-- 创建入库单的存储过程
-- 创建售货单的存储过程


