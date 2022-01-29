
-- Cleaning Data with SQL--

SELECT * FROM dbo.HOUS�NGDATA

-- Let's convert SaleDate column into Date format 

SELECT SaleDate, convert(date,SaleDate) 
FROM dbo.HOUS�NGDATA

UPDATE dbo.HOUS�NGDATA
	SET SaleDate = convert(date,SaleDate)

SELECT * FROM dbo.HOUS�NGDATA -- We didn't get modified SaleDate column, Let's try another way

ALTER TABLE dbo.HOUS�NGDATA
	ADD SaleDateConverted date;

UPDATE dbo.HOUS�NGDATA
	SET SaleDateConverted = CONVERT(date, SaleDate)
 
 -----------------------------------------------------------------------------------------------------


--Looking at PropertyAddress column

SELECT A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM dbo.HOUS�NGDATA A
JOIN dbo.HOUS�NGDATA B 
ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
		WHERE A.PropertyAddress is null 

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM dbo.HOUS�NGDATA A
JOIN dbo.HOUS�NGDATA B 
ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
		WHERE A.PropertyAddress is null 

SELECT * FROM dbo.HOUS�NGDATA -- We've replaced null values with correct addresses

 -----------------------------------------------------------------------------------------------------


--Parsing Address into separate columns 

SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as Address_,
		SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM dbo.HOUS�NGDATA


ALTER TABLE dbo.HOUS�NGDATA
	ADD Address_ nvarchar(255);

UPDATE dbo.HOUS�NGDATA
	SET Address_ = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) 


ALTER TABLE dbo.HOUS�NGDATA
	ADD City_ NVARCHAR(255);

UPDATE dbo.HOUS�NGDATA
	SET City_ = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

 -----------------------------------------------------------------------------------------------------


-- Diving into OwnerAddress Column

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
		PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM dbo.HOUS�NGDATA


ALTER TABLE dbo.HOUS�NGDATA
	ADD Owner_Address NVARCHAR(255);

UPDATE dbo.HOUS�NGDATA
	SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE dbo.HOUS�NGDATA
	ADD Owner_City NVARCHAR(255);

UPDATE dbo.HOUS�NGDATA
	SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE dbo.HOUS�NGDATA
	ADD Owner_State NVARCHAR(255);

UPDATE dbo.HOUS�NGDATA
	SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

 -----------------------------------------------------------------------------------------------------


-- Chancing Y and N values to Yes and No in 'SoldAsVacans' column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM dbo.HOUS�NGDATA
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
			ELSE SoldAsVacant
END
FROM dbo.HOUS�NGDATA

UPDATE dbo.HOUS�NGDATA
SET SoldAsVacant = CASE
					WHEN SoldAsVacant='Y' THEN 'Yes'
						WHEN SoldAsVacant='N' THEN 'No'
							ELSE SoldAsVacant
					END

 -----------------------------------------------------------------------------------------------------

-- Let's Remove Duplicates

WITH ROWNUMBER_ AS 
(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY
					ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
			ORDER BY
					UniqueID
					) RowNum

 FROM dbo.HOUS�NGDATA
 )
SELECT * FROM ROWNUMBER_
	WHERE RowNum > 1


WITH ROWNUMBER_ AS 
(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY
					ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
			ORDER BY
					UniqueID
					) RowNum

 FROM dbo.HOUS�NGDATA
 )
DELETE FROM ROWNUMBER_
			WHERE RowNum > 1

 -----------------------------------------------------------------------------------------------------

-- Let's Delete some columns which are we don't need anymore

Select *  FROM dbo.HOUS�NGDATA 

ALTER TABLE dbo.HOUS�NGDATA 
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate



