DELIMITER $$

DROP PROCEDURE IF EXISTS MIGRATE_BCM_ORDER_MGT$$

CREATE PROCEDURE MIGRATE_BCM_ORDER_MGT()
BEGIN
    -- Declare local variables for supplier and invoice processing

    DECLARE done INT DEFAULT 0;
    DECLARE v_supplier_id INT;
    DECLARE v_order_id INT;
    DECLARE v_invoice_details TEXT;
    DECLARE pos INT DEFAULT 0;
    DECLARE inv_ref VARCHAR(200) DEFAULT '';
    DECLARE v_town VARCHAR(200);
    DECLARE clean_order_date DATE;

    -- Declare variables for raw table columns

    DECLARE r_ORDER_REF VARCHAR(200);
    DECLARE r_ORDER_DATE VARCHAR(200);
    DECLARE r_SUPPLIER_NAME VARCHAR(200);
    DECLARE r_SUPP_ADDRESS VARCHAR(200);
    DECLARE r_SUPP_CONTACT_NAME VARCHAR(200);
    DECLARE r_SUPP_CONTACT_NUMBER VARCHAR(200);
    DECLARE r_ORDER_TOTAL_AMOUNT DECIMAL(12,2);
    DECLARE r_ORDER_STATUS VARCHAR(200);
    DECLARE r_INVOICE_REFERENCE VARCHAR(200);
    DECLARE r_INVOICE_AMOUNT DECIMAL(12,2);
    DECLARE r_INVOICE_STATUS VARCHAR(200);

    -- Cursor to loop through all records in the raw BCM_ORDER_MGT table

    DECLARE cur CURSOR FOR
      SELECT ORDER_REF, ORDER_DATE, SUPPLIER_NAME, SUPP_ADDRESS, SUPP_CONTACT_NAME,
             SUPP_CONTACT_NUMBER, ORDER_TOTAL_AMOUNT, ORDER_STATUS, 
             INVOICE_REFERENCE, INVOICE_AMOUNT, INVOICE_STATUS
      FROM BCM_ORDER_MGT;

    -- Exit loop when no more records are found

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;
    OPEN cur;

    read_loop: LOOP
       FETCH cur INTO r_ORDER_REF, r_ORDER_DATE, r_SUPPLIER_NAME, r_SUPP_ADDRESS, r_SUPP_CONTACT_NAME,
                    r_SUPP_CONTACT_NUMBER, r_ORDER_TOTAL_AMOUNT, r_ORDER_STATUS, 
                    r_INVOICE_REFERENCE, r_INVOICE_AMOUNT, r_INVOICE_STATUS;
       IF done THEN
          LEAVE read_loop;
       END IF;

       -- STEP 1: CLEAN & VALIDATE ORDER_DATE

       SET r_ORDER_DATE = TRIM(r_ORDER_DATE);  
       SET clean_order_date = STR_TO_DATE(r_ORDER_DATE, '%d-%b-%Y');

       -- If conversion fails, set a default date

       IF clean_order_date IS NULL THEN
           SET clean_order_date = '2000-01-01';  -- Default date to avoid NULL errors
       END IF;

       -- STEP 2: CHECK & INSERT SUPPLIER

       SET v_supplier_id = (SELECT SUPPLIER_ID FROM SUPPLIER
                             WHERE UPPER(SUPPLIER_NAME) = UPPER(r_SUPPLIER_NAME)
                             LIMIT 1);

       IF v_supplier_id IS NULL THEN
         -- Extract the town from the address if available (Assuming 'Street, Town, Region' format)

         SET v_town = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(r_SUPP_ADDRESS, ',', 2), ',', -1));

         INSERT INTO SUPPLIER(
           SUPPLIER_NAME, SUPPLIER_ADDRESS, SUPPLIER_TOWN, SUPPLIER_REGION,
           SUPPLIER_CONTACT_NAME, SUPPLIER_CONTACT_NO1, SUPPLIER_CONTACT_NO2
         ) VALUES (
           r_SUPPLIER_NAME, r_SUPP_ADDRESS, v_town, '',  -- Region not provided; default to empty
           r_SUPP_CONTACT_NAME, r_SUPP_CONTACT_NUMBER, ''  -- Only one contact number provided
         );
         SET v_supplier_id = LAST_INSERT_ID();
       END IF;

       -- STEP 3: INSERT PURCHASE ORDER

       INSERT INTO PURCHASE_ORDER(
         ORDER_REFERENCE, ORDER_DATE, ORDER_STATUS, ORDER_TOTAL_AMOUNT, SUPPLIER_ID
       ) VALUES (
         r_ORDER_REF, clean_order_date, r_ORDER_STATUS, r_ORDER_TOTAL_AMOUNT, v_supplier_id
       );
       SET v_order_id = LAST_INSERT_ID();

       -- STEP 4: PROCESS INVOICE REFERENCES (if available)
       SET v_invoice_details = r_INVOICE_REFERENCE;
       WHILE v_invoice_details IS NOT NULL AND v_invoice_details <> '' DO
           SET pos = LOCATE('|', v_invoice_details);
           IF pos > 0 THEN
               SET inv_ref = LEFT(v_invoice_details, pos - 1);
               SET v_invoice_details = SUBSTRING(v_invoice_details, pos + 1);
           ELSE
               SET inv_ref = v_invoice_details;
               SET v_invoice_details = '';
           END IF;

           INSERT INTO INVOICE(
             ORDER_ID, INVOICE_REFERENCE, INVOICE_TOTAL_AMOUNT, INVOICE_STATUS
           ) VALUES (
             v_order_id, inv_ref, r_INVOICE_AMOUNT, r_INVOICE_STATUS
           );
       END WHILE;
    END LOOP;

    CLOSE cur;
    COMMIT;
END$$

DELIMITER ;
