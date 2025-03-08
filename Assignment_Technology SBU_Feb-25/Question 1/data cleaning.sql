-- Remove Non-Numeric Characters from `ORDER_TOTAL_AMOUNT` and `INVOICE_AMOUNT`

UPDATE BCM_ORDER_MGT
SET ORDER_TOTAL_AMOUNT = NULL
WHERE ORDER_TOTAL_AMOUNT NOT REGEXP '^[0-9,.]+$';

UPDATE BCM_ORDER_MGT
SET ORDER_TOTAL_AMOUNT = REPLACE(ORDER_TOTAL_AMOUNT, ',', '')
WHERE ORDER_TOTAL_AMOUNT IS NOT NULL;

UPDATE BCM_ORDER_MGT
SET INVOICE_AMOUNT = NULL
WHERE INVOICE_AMOUNT NOT REGEXP '^[0-9,.]+$';

UPDATE BCM_ORDER_MGT
SET INVOICE_AMOUNT = REPLACE(INVOICE_AMOUNT, ',', '')
WHERE INVOICE_AMOUNT IS NOT NULL;

-- Remove Non-Numeric Characters from `ORDER_LINE_AMOUNT`

UPDATE BCM_ORDER_MGT
SET ORDER_LINE_AMOUNT = NULL
WHERE ORDER_LINE_AMOUNT NOT REGEXP '^[0-9,.]+$';

UPDATE BCM_ORDER_MGT
SET ORDER_LINE_AMOUNT = REPLACE(ORDER_LINE_AMOUNT, ',', '')
WHERE ORDER_LINE_AMOUNT IS NOT NULL;

-- Remove Invalid Characters from `SUPP_CONTACT_NUMBER`

UPDATE BCM_ORDER_MGT
SET SUPP_CONTACT_NUMBER = REGEXP_REPLACE(SUPP_CONTACT_NUMBER, '[^0-9,]', '')
WHERE SUPP_CONTACT_NUMBER IS NOT NULL;

-- Ensuring `ORDER_DATE` is in a Valid Format (`DD-MMM-YYYY`)

UPDATE BCM_ORDER_MGT
SET ORDER_DATE = NULL
WHERE STR_TO_DATE(ORDER_DATE, '%d-%b-%Y') IS NULL;

-- Ensuring `INVOICE_DATE` is in a Valid Format (`DD-MMM-YYYY`)

UPDATE BCM_ORDER_MGT
SET INVOICE_DATE = NULL
WHERE INVOICE_DATE IS NOT NULL AND STR_TO_DATE(INVOICE_DATE, '%d-%b-%Y') IS NULL;

-- Converting NULL fields to Default Values (`0.00`)

UPDATE BCM_ORDER_MGT
SET ORDER_TOTAL_AMOUNT = '0.00'
WHERE ORDER_TOTAL_AMOUNT IS NULL OR ORDER_TOTAL_AMOUNT = '';

UPDATE BCM_ORDER_MGT
SET INVOICE_AMOUNT = '0.00'
WHERE INVOICE_AMOUNT IS NULL OR INVOICE_AMOUNT = '';

UPDATE BCM_ORDER_MGT
SET ORDER_LINE_AMOUNT = '0.00'
WHERE ORDER_LINE_AMOUNT IS NULL OR ORDER_LINE_AMOUNT = '';

-- Trimming Spaces from All Fields to Ensure Clean Data

UPDATE BCM_ORDER_MGT
SET ORDER_REF = TRIM(ORDER_REF),
    ORDER_DATE = TRIM(ORDER_DATE),
    SUPPLIER_NAME = TRIM(SUPPLIER_NAME),
    SUPP_CONTACT_NAME = TRIM(SUPP_CONTACT_NAME),
    SUPP_ADDRESS = TRIM(SUPP_ADDRESS),
    SUPP_CONTACT_NUMBER = TRIM(SUPP_CONTACT_NUMBER),
    SUPP_EMAIL = TRIM(SUPP_EMAIL),
    ORDER_TOTAL_AMOUNT = TRIM(ORDER_TOTAL_AMOUNT),
    ORDER_DESCRIPTION = TRIM(ORDER_DESCRIPTION),
    ORDER_STATUS = TRIM(ORDER_STATUS),
    ORDER_LINE_AMOUNT = TRIM(ORDER_LINE_AMOUNT),
    INVOICE_REFERENCE = TRIM(INVOICE_REFERENCE),
    INVOICE_DATE = TRIM(INVOICE_DATE),
    INVOICE_STATUS = TRIM(INVOICE_STATUS),
    INVOICE_HOLD_REASON = TRIM(INVOICE_HOLD_REASON),
    INVOICE_AMOUNT = TRIM(INVOICE_AMOUNT),
    INVOICE_DESCRIPTION = TRIM(INVOICE_DESCRIPTION);
