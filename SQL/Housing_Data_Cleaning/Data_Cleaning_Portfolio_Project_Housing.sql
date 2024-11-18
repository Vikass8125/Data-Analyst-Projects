-- Using the housing_data_cleaning database
USE housing_data_cleaning;

SELECT *
FROM cleaning;

-- Standardize Date Format
SELECT SaleDateConverted, STR_TO_DATE(SaleDate, '%Y-%m-%d') AS SaleDateConverted
FROM cleaning;

-- Update SaleDate with the proper format
UPDATE cleaning
SET SaleDate = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-- If additional column is needed for date conversion
ALTER TABLE cleaning
ADD SaleDateConverted DATE;

UPDATE cleaning
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-- Populate Property Address Data
SELECT *
FROM cleaning
ORDER BY ParcelID;

-- Populate missing PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM cleaning a
JOIN cleaning b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update PropertyAddress with missing values
SET SQL_SAFE_UPDATES = 0;

UPDATE cleaning a
JOIN cleaning b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Break Address into Individual Columns (Address, City, State)
SELECT
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM cleaning;

-- Add new columns for split address
ALTER TABLE cleaning
ADD PropertySplitAddress VARCHAR(255),
ADD PropertySplitCity VARCHAR(255);

-- Update Address and City columns
UPDATE cleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

-- Split OwnerAddress into Address, City, and State
SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerSplitCity,
  SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerSplitState
FROM cleaning;

-- Add new columns for owner details
ALTER TABLE cleaning
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnerSplitState VARCHAR(255);

-- Update owner details
UPDATE cleaning
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM cleaning
GROUP BY SoldAsVacant
ORDER BY 2;

-- Update SoldAsVacant with 'Yes' and 'No'
UPDATE cleaning
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END;

-- Remove Duplicates
WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM cleaning
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Delete Unused Columns
ALTER TABLE cleaning
DROP COLUMN OwnerAddress;

ALTER TABLE cleaning
DROP COLUMN TaxDistrict;

ALTER TABLE cleaning
DROP COLUMN PropertyAddress;

ALTER TABLE cleaning
DROP COLUMN SaleDate;
