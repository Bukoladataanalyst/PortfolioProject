use PortfolioProject
--cleaning data in SQL Queries

select * 
from PortfolioProject.dbo.NashvilleHousing

--standardize date format

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
 SET SaleDate= CONVERT(Date,SaleDate)

 ALTER TABLE NashvilleHousing
 ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted= CONVERT (Date,SaleDate)

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--Populate property address data

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

--inorder to assign addresses to where the PropertyAddress is null, we will use their parcelIDs to proceed
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- the below query will pull out the data that has ParcelID,but the Property Id is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- next we will populate the null Property addresses

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Next we will update information into the PropertyAddress

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--doublecheck
select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

--breaking out addresses into individual columns( address, city, state)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

--for the address, the delimiter is a comma (,)

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

-- to remove the comma(,) at the end of every address,

select
substring(PropertyAddress, -1, charindex(',', PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

-- to list the city in another column
select
substring(PropertyAddress, -1, charindex(',', PropertyAddress)) as Address
,substring(PropertyAddress, charindex(',', PropertyAddress)+1 , LEN(PropertyAddress))as City
from PortfolioProject.dbo.NashvilleHousing

--next we would create 2 columns for the address and city

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 ADD Propertysplitaddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET Propertysplitaddress= substring(PropertyAddress, -1, charindex(',', PropertyAddress)) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 ADD Propertysplitcity NVarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET Propertysplitcity= substring(PropertyAddress, charindex(',', PropertyAddress)+1 , LEN(PropertyAddress))

--now confirm

select*
from PortfolioProject.dbo.NashvilleHousing


--next we would split OwnerAddress into 3: Address, city  and state

select 
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),3)
from PortfolioProject.dbo.NashvilleHousing


--this would bring back the address backwards, to make the addr in the right sequence,we will change 1 2 3 to 3 2 1:
select 
PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing
 
 --next we would create new columns for addr city and state:

 ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 ADD OwnersplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnersplitAddress= PARSENAME (REPLACE(OwnerAddress,',','.'),3)  

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 ADD Ownersplitcity NVarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET Ownersplitcity=PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
 ADD Ownersplitstate NVarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET Ownersplitstate= PARSENAME (REPLACE(OwnerAddress,',','.'),1)

--next confirm the columns have been created

select *
from PortfolioProject.dbo.NashvilleHousing

-- change Y and N to Yes  and No in 'SoldAsVacant' field

Select Distinct (SoldAsVacant),Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by (SoldAsVacant)
Order By 2

--next we would change Y and N to Yes  and No respectively

select SoldAsVacant
,CASE WHEN SoldAsVacant= 'Y' then 'Yes'
     WHEN SoldAsVacant= 'N'then 'No'
	 Else SoldAsVacant
	 END
from PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant=
CASE WHEN SoldAsVacant= 'Y' then 'Yes'
     WHEN SoldAsVacant= 'N'then 'No'
	 Else SoldAsVacant
	 END

	 --Remove duplicates
WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER()OVER(
    PARTITION BY ParcelID,
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID)
			 row_num
from PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num >1
Order By PropertyAddress

--this shows 104 rows that are duplicate, then we delete with the query below:

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER()OVER(
    PARTITION BY ParcelID,
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID)
			 row_num
from PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
where row_num >1

-- delete unused columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OWnerAddress,PropertyAddress,TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
 
