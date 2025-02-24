Select * from bcm_order_mgt;

CREATE TABLE BCM_ORDER_MGT_COPY LIKE BCM_ORDER_MGT;

select * from BCM_ORDER_MGT_COPY;

INSERT INTO BCM_ORDER_MGT_COPY SELECT * FROM BCM_ORDER_MGT;

select * from invoice;

select * from purchase_order;