-- Migrate data from BCM_ORDER_MGT into the normalized tables
CALL MIGRATE_BCM_ORDER_MGT();

-- Retrieve the order summary repbcm_order_mgtort
CALL GET_ORDER_SUMMARY_REPORT();

-- Retrieve the median order report
CALL GET_MEDIAN_ORDER_REPORT();


DESCRIBE BCM_ORDER_MGT;


-- Retrieve the supplier orders report
CALL GET_SUPPLIER_ORDERS_REPORT();
