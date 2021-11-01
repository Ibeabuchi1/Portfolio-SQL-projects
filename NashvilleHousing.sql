/****** VIEW THE DATASET  ******/
SELECT TOP 1000 *
FROM Portfolio..Nashville_housing

-- CONVERT THE 'SaleDate' COLUMN FROM TIMEDATE, TO DATE
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio..Nashville_housing

ALTER TABLE Nashville_housing
ADD DateSold  Date;

UPDATE Nashville_housing
SET DateSold =  CONVERT(Date, SaleDate)

--EXAMINE PROPERTY ADDRESS
SELECT PropertyAddress
FROM Portfolio..Nashville_housing
WHERE PropertyAddress IS NULL

--POPULATE THE NULL VALUES WITH THE ADDRESS USING SELF JOIN
SELECT PropertyAddress
FROM Portfolio..Nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..Nashville_housing a
JOIN Portfolio..Nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
--ORDER BY ParcelID

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..Nashville_housing a
JOIN Portfolio..Nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- BREAK UP THE PROPERTY ADDRESS INTO (ADDRESS, CITY)
SELECT PropertyAddress
FROM Portfolio..Nashville_housing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PropertyLandAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM Portfolio..Nashville_housing 


-- UPDATE THE TABLE
ALTER TABLE Nashville_housing
ADD PropertyLandAddress  VARCHAR(255);

UPDATE Nashville_housing
SET PropertyLandAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE Nashville_housing
ADD PropertCity  VARCHAR(255);

UPDATE Nashville_housing
SET PropertyCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--SPLIT OwnerAddress USING PARSENAME
SELECT OwnerAddress
FROM Nashville_housing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
FROM Nashville_housing

ALTER TABLE Nashville_housing
ADD PropertyState  VARCHAR(255);

UPDATE Nashville_housing
SET PropertyState= PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN SoldAsVacant
SELECT SoldAsVacant,
		CASE
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
FROM Nashville_housing


UPDATE Nashville_housing
SET SoldAsVacant = 
		CASE
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END
FROM Nashville_housing

--CONFIRMATION
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_housing


--REMOVE DUPLICATES AND UNUSED COLUMNS
--REMOVE DUPLICATES
WITH RomNumCTE AS
(SELECT *,
	ROW_NUMBER()
		OVER (
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) Row_Num
FROM Nashville_housing
--ORDER BY ParcelID
)
DELETE *
FROM RomNumCTE
WHERE Row_Num > 1


-- REMOVE UNUSED COLUMNS
SELECT * 
FROM Nashville_housing

ALTER TABLE Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



