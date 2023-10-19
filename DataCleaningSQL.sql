/*
Data Cleaning using SQL Queries
In this project, I have cleaned data from NashvilleHousing Dataset to make it more legible for data analysis
*/

Select*
From PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

/* Now the time is removed from SaleDate and only shows YYYY-MM-DD */


--Populate Property Address Data
Select *
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID

-- Using Joins to populate the missing addresses with the same ParcelID but different UniqueID.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
--ISNULL() is used to make sure that if a.PropertyAddress is null, we populate it with b.PropertyAddress.
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

/* Now we have populated where PropertyAdress is null with PropertyAddress with the same ParcelID but different UniqueID */

-- Breaking Out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

/* Using SUBSTRING and CHARINDEX to split the PropertyAddress */

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
-- SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) this substring is for us to split the address before the ','.

, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
-- SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) +1 ) this substring is for us to split the address after the ','.

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
--Here I am adding a new column called PropertySplitAddress


Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
--Here I am updating the values of PropertySplitAddress with the address before the ','.


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);
--Here I am adding a new column called PropertySplitCity

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
--Here I am updating the values of PropertySplitCity with the address after the ','.


Select *
From PortfolioProject.dbo.NashvilleHousing

/* Now the PropertyAddress is split from the Address and City for easier legibility*/


-- Here I am splitting the OwnerAdress into the Address,State and City
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- Using PARSENAME
-- PARSENAME only detects '.' thus we use REPLACE in order for PARSENAME to detect ','
-- In the PARSENAME, '3' indicates the Address, '2' is the City and '1' is the State as PARSENAME splits the OwnerAddress backwards Address(3)/City(2)/State(1)
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


-- Here I am adding a new column OwnerSplitAddress and updating the database with SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- Here I am adding a new column OwnerSplitCity and updating the database with SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


-- Here I am adding a new column OwnerSplitState and updating the database with SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing

/* Similarly, the OwnerAddress is split from the Address, City and State for easier legibility */

-- Change Y and N to Yes and No in "Sold as Vacant" field

--Here I am counting the number of 'Y', 'N', 'Yes' and 'No' in SoldAsVacant
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- Here I am converting 'Y' into 'Yes' and 'N' into 'No' using CASE
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

-- Here I am updating the database using the CASE statement
Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

/* Now all the 'Y' and 'N' is converted into 'Yes' and 'No' respectively */

-- To Remove Duplicates
-- Here I am creating a CTE to create partition in the database and using ROW_NUMBER() I can see if there are any duplicates (>1)
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
-- Here I am deleting any duplicates from the CTE where the row_num >1
DELETE
From RowNumCTE
Where row_num > 1

--To Check if Duplicates is Removed
--Here I am checking from the CTE if the duplicates are removed
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- To check from Database if duplicates is deleted

Select *
From PortfolioProject.dbo.NashvilleHousing

/* Duplicated ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference is now removed */

-- To Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Here I am deleting the unused columns to make the database cleaner
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- To Check if the Unused Columns are removed and SaleDateConverted, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState is added
Select *
From PortfolioProject.dbo.NashvilleHousing

/* Now unused Columns are removed and SaleDateConverted, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState is added*/



