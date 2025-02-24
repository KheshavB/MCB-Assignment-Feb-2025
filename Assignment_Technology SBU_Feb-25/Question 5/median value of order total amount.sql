DELIMITER $$

DROP PROCEDURE IF EXISTS GET_MEDIAN_ORDER_REPORT$$


CREATE PROCEDURE GET_MEDIAN_ORDER_REPORT()
BEGIN
  -- Declare local variables for total count and offset
  DECLARE total INT;
  DECLARE offset_val INT;
  
  -- Calculate total number of orders and determine the offset for the median order
  SELECT COUNT(*) INTO total FROM PURCHASE_ORDER;
  SET offset_val = CEIL(total/2) - 1;
  
  SELECT 
      -- Extract numeric part of the order reference by removing the first two characters (e.g., "PO")
      CAST(SUBSTRING(ORDER_REFERENCE, 3) AS UNSIGNED) AS `Order Reference`,
      
      -- Format order date as DD-MON-YYYY (e.g., 01-JAN-2024)
      DATE_FORMAT(ORDER_DATE, '%d-%b-%Y') AS `Order Date`,
      
      -- Convert supplier name to uppercase
      UPPER(s.SUPPLIER_NAME) AS `Supplier Name`,
      
      -- Format order total amount with commas and two decimal places
      FORMAT(ORDER_TOTAL_AMOUNT, 2) AS `Order Total Amount`,
      
      ORDER_STATUS AS `Order Status`,
      
      -- Subquery to aggregate invoice references with a pipe delimiter
      (SELECT GROUP_CONCAT(INVOICE_REFERENCE SEPARATOR '|') 
       FROM INVOICE 
       WHERE ORDER_ID = po.ORDER_ID 
       ORDER BY INVOICE_REFERENCE) AS `Invoice References`
  FROM PURCHASE_ORDER po
  JOIN SUPPLIER s ON po.SUPPLIER_ID = s.SUPPLIER_ID
  ORDER BY ORDER_TOTAL_AMOUNT
  LIMIT offset_val, 1;  -- Use the local variable 'offset_val'
END$$

DELIMITER ;
