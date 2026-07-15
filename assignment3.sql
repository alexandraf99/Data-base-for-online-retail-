-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema assignment3
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema assignment3
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `assignment3` DEFAULT CHARACTER SET utf8 ;
USE `assignment3` ;

-- -----------------------------------------------------
-- Table `assignment3`.`Customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignment3`.`Customer` (
  `customerId` INT NOT NULL,
  `Country` VARCHAR(45) NULL,
  `firstName` VARCHAR(45) NULL,
  `lastName` VARCHAR(45) NULL,
  `phoneNumber` VARCHAR(45) NULL,
  PRIMARY KEY (`customerId`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `assignment3`.`Invoice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignment3`.`Invoice` (
  `inv_number` INT NOT NULL,
  `inv_time` VARCHAR(45) NULL,
  `Customer_customerId` INT NOT NULL,
  PRIMARY KEY (`inv_number`),
  INDEX `fk_Invoice_Customer_idx` (`Customer_customerId` ASC) VISIBLE,
  CONSTRAINT `fk_Invoice_Customer`
    FOREIGN KEY (`Customer_customerId`)
    REFERENCES `assignment3`.`Customer` (`customerId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `assignment3`.`Product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignment3`.`Product` (
  `productCode` INT NOT NULL,
  `productDescription` VARCHAR(45) NULL,
  `inventoryQuantityt` INT NULL,
  `product_price` VARCHAR(45) NULL,
  PRIMARY KEY (`productCode`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `assignment3`.`Line`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `assignment3`.`Line` (
  `inv_number` INT NOT NULL,
  `line_number` VARCHAR(45) NOT NULL,
  `inv_quantity` VARCHAR(45) NULL,
  `Invoice_inv_number` INT NOT NULL,
  `Product_productCode` INT NOT NULL,
  PRIMARY KEY (`inv_number`, `Invoice_inv_number`, `line_number`),
  INDEX `fk_Line_Invoice1_idx` (`Invoice_inv_number` ASC) VISIBLE,
  INDEX `fk_Line_Product1_idx` (`Product_productCode` ASC) VISIBLE,
  CONSTRAINT `fk_Line_Invoice1`
    FOREIGN KEY (`Invoice_inv_number`)
    REFERENCES `assignment3`.`Invoice` (`inv_number`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Line_Product1`
    FOREIGN KEY (`Product_productCode`)
    REFERENCES `assignment3`.`Product` (`productCode`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


ALTER TABLE CUSTOMER
ADD CONSTRAINT chk_customerId_5digits
CHECK (customerId REGEXP '^[0-9]{5}$');

ALTER TABLE LINE
ALTER inv_quantity SET DEFAULT 0;

ALTER TABLE LINE
ADD CHECK (inv_quantity >= 1 AND inv_quantity <= 200);

ALTER TABLE INVOICE
DROP FOREIGN KEY Customer_customerId;

ALTER TABLE INVOICE
ADD CONSTRAINT Customer_ID
FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID)
ON DELETE CASCADE
ON UPDATE CASCADE;


ALTER TABLE LINE
DROP FOREIGN KEY fk_Line_Invoice1, 
DROP FOREIGN KEY fk_Line_Product1;

ALTER TABLE LINE
ADD CONSTRAINT fk_invoice
    FOREIGN KEY (Invoice_inv_number)
    REFERENCES INVOICE(inv_number)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
ADD CONSTRAINT fk_product
    FOREIGN KEY (Product_productCode)
    REFERENCES PRODUCT(productCode)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

INSERT INTO PRODUCT (productCode, productDescription, inventoryQuantityt, product_price)
SELECT 
    D.ProductCode,
    MAX(D.Description),
    MAX(D.`Inventory Quantity`),
    MAX(D.`Product Price`)
FROM data D
GROUP BY D.ProductCode;

INSERT INTO CUSTOMER (customerId, Country)
SELECT DISTINCT TRIM(D.CustomerID), D.Country
FROM data D
WHERE TRIM(D.CustomerID) REGEXP '^[0-9]{5}$';

INSERT INTO	INVOICE(inv_number, inv_time, Customer_customerId)
SELECT D.InvoiceNo,D.InvoiceTime,CustomerID
FROM data D;


ALTER TABLE INVOICE
ADD CONSTRAINT chk_invoice_date
CHECK (inv_time > '2010-01-01 00:00:00');

ALTER TABLE PRODUCT
ADD COLUMN Inventory_Status VARCHAR(15);

SET SQL_SAFE_UPDATES = 0;

UPDATE PRODUCT
SET Inventory_Status = "Low Inventory" 
WHERE inventoryQuantityt < 5;

UPDATE PRODUCT
SET Inventory_Status = "In Stock"
WHERE inventoryQuantityt >= 5;
