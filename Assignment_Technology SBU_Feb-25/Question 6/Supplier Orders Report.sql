-- Supplier Orders Report Procedure between January 1 2024 and August 31 2024 

DELIMITER $$

DROP PROCEDURE IF EXISTS GET_SUPPLIER_ORDERS_REPORT$$

CREATE PROCEDURE GET_SUPPLIER_ORDERS_REPORT()
BEGIN
  SELECT 
      -- Format the month as "Month YYYY" (e.g., "January 2024")
      DATE_FORMAT(po.ORDER_DATE, '%M %Y') AS `Month`,
      s.SUPPLIER_NAME AS `Supplier Name`,
      s.SUPPLIER_CONTACT_NAME AS `Supplier Contact Name`,
      s.SUPPLIER_CONTACT_NO1 AS `Supplier Contact No. 1`,
      s.SUPPLIER_CONTACT_NO2 AS `Supplier Contact No. 2`,
      COUNT(po.ORDER_ID) AS `Total Orders`,
      -- Sum and format the total order amount
      FORMAT(SUM(po.ORDER_TOTAL_AMOUNT), 2) AS `Order Total Amount`
  FROM PURCHASE_ORDER po
  JOIN SUPPLIER s ON po.SUPPLIER_ID = s.SUPPLIER_ID
  WHERE po.ORDER_DATE BETWEEN '2024-01-01' AND '2024-08-31'
  GROUP BY DATE_FORMAT(po.ORDER_DATE, '%M %Y'),
           s.SUPPLIER_NAME, s.SUPPLIER_CONTACT_NAME, s.SUPPLIER_CONTACT_NO1, s.SUPPLIER_CONTACT_NO2
  ORDER BY `Total Orders` DESC;
END$$

DELIMITER ;
