-- 建表
drop database if exists db_user_behavior cascade;
--创建数据库
create database db_user_behavior;
--切换数据库
use db_user_behavior;

drop table if exists user_behavior;
create table user_behavior (
`user_id` string comment '用户ID',
`item_id` string comment '商品ID',
`category_id` string comment '商品类目ID',
`behavior_type` string  comment '行为类型，枚举类型，包括(pv, buy, cart, fav)',
`timestamp` int comment '行为时间戳',
`datetime` string comment '行为时间')
row format delimited
fields terminated by ','
lines terminated by '\n';

-- 加载数据
LOAD DATA LOCAL INPATH '/Users/linjiaxi/Desktop/Recommendation System /Hive/UserBehavior.csv'
OVERWRITE INTO TABLE user_behavior ;

--查看数据
select * from user_behavior limit 10;

--数据清洗，去掉完全重复的数据
insert overwrite table user_behavior
select user_id, item_id, category_id, behavior_type, `timestamp`,datetime
from user_behavior
group by user_id, item_id, category_id, behavior_type, `timestamp`,datetime;

--数据清洗，时间戳格式化成 datetime
insert overwrite table user_behavior
select user_id, item_id, category_id, behavior_type, `timestamp`, from_unixtime(timestamp, 'yyyy-MM-dd HH:mm:ss')
from user_behavior;

--查看时间是否有异常值
select date(datetime) as day from user_behavior group by date(datetime) order by day;

--数据清洗，去掉时间异常的数据
insert overwrite table user_behavior
select user_id, item_id, category_id, behavior_type, timestamp, datetime
from user_behavior
where cast(datetime as date) between '2017-11-25' and '2017-12-03';

--查看 behavior_type 是否有异常值
select behavior_type from user_behavior group by behavior_type;

--清洗后的数据量
select count(1) from user_behavior;