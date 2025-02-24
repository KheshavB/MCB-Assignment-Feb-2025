-- Created SUPPLIER table for normalisation

CREATE TABLE SUPPLIER (
    SUPPLIER_ID INT AUTO_INCREMENT PRIMARY KEY,  
    SUPPLIER_NAME VARCHAR(200) NOT NULL,           
    SUPPLIER_ADDRESS VARCHAR(200),                 
    SUPPLIER_TOWN VARCHAR(200),                     
    SUPPLIER_REGION VARCHAR(200),                   
    SUPPLIER_CONTACT_NAME VARCHAR(200),            
    SUPPLIER_CONTACT_NO1 VARCHAR(200),              
    SUPPLIER_CONTACT_NO2 VARCHAR(200)               
);

-- Created PURCHASE_ORDER table to store orders
CREATE TABLE PURCHASE_ORDER (
    ORDER_ID INT AUTO_INCREMENT PRIMARY KEY,      
    ORDER_REFERENCE VARCHAR(200) NOT NULL,           
    ORDER_DATE DATE NOT NULL,                       
    ORDER_STATUS VARCHAR(200),               
    ORDER_TOTAL_AMOUNT DECIMAL(12,2),              
    SUPPLIER_ID INT,                             
    FOREIGN KEY (SUPPLIER_ID) REFERENCES SUPPLIER(SUPPLIER_ID)
);

-- Created INVOICE table to store invoice details for orders
CREATE TABLE INVOICE (
    INVOICE_ID INT AUTO_INCREMENT PRIMARY KEY,      
    ORDER_ID INT,                                   
    INVOICE_REFERENCE VARCHAR(200),                  
    INVOICE_TOTAL_AMOUNT DECIMAL(12,2),            
    INVOICE_STATUS VARCHAR(200),                    
    FOREIGN KEY (ORDER_ID) REFERENCES PURCHASE_ORDER(ORDER_ID)
);
