-- Creation of report of orders summary
DELIMITER $$

DROP PROCEDURE IF EXISTS GET_ORDER_SUMMARY_REPORT$$


CREATE PROCEDURE GET_ORDER_SUMMARY_REPORT()
BEGIN
  SELECT 
  
      -- Combine region and town for supplier location details
      CONCAT(s.SUPPLIER_REGION, ' ', s.SUPPLIER_TOWN) AS `Region Town/Village`,
      
      -- Extract numeric part of the order reference by skipping the first two characters
      CAST(SUBSTRING(po.ORDER_REFERENCE, 3) AS UNSIGNED) AS `Order Reference`,
      
      -- Format order date as Year-Month (e.g., 2024-01)
      DATE_FORMAT(po.ORDER_DATE, '%Y-%m') AS `Order Period`,
      
      -- Format supplier name in title case using the INITCAP function
      INITCAP(s.SUPPLIER_NAME) AS `Supplier Name`,
      
      -- Format the order total amount with commas and two decimal places
      FORMAT(po.ORDER_TOTAL_AMOUNT, 2) AS `Order Total Amount`,
      po.ORDER_STATUS AS `Order Status`,
      
      -- Aggregate all invoice references for the order, separated by commas
      GROUP_CONCAT(inv.INVOICE_REFERENCE ORDER BY inv.INVOICE_REFERENCE SEPARATOR ', ') AS `Invoice Reference`,
      
      -- Sum for invoice total amounts and formating the result
      FORMAT(SUM(inv.INVOICE_TOTAL_AMOUNT), 2) AS `Invoice Total Amount`,
      
      -- Determine action based on invoice statuses:
      -- "No Action" if all are Paid, "To follow up" if any are Pending, or "To verify" if any are blank
      CASE
        WHEN SUM(CASE WHEN inv.INVOICE_STATUS <> 'Paid' THEN 1 ELSE 0 END) = 0 THEN 'No Action'
        WHEN SUM(CASE WHEN inv.INVOICE_STATUS = 'Pending' THEN 1 ELSE 0 END) > 0 THEN 'To follow up'
        WHEN SUM(CASE WHEN inv.INVOICE_STATUS IS NULL OR TRIM(inv.INVOICE_STATUS) = '' THEN 1 ELSE 0 END) > 0 THEN 'To verify'
        ELSE 'No Action'
      END AS `Action`
  FROM PURCHASE_ORDER po
  JOIN SUPPLIER s ON po.SUPPLIER_ID = s.SUPPLIER_ID
  JOIN INVOICE inv ON inv.ORDER_ID = po.ORDER_ID
  GROUP BY s.SUPPLIER_REGION, s.SUPPLIER_TOWN, po.ORDER_REFERENCE, po.ORDER_DATE,
           s.SUPPLIER_NAME, po.ORDER_TOTAL_AMOUNT, po.ORDER_STATUS
  ORDER BY s.SUPPLIER_REGION, po.ORDER_TOTAL_AMOUNT DESC;
END$$

DELIMITER ;
