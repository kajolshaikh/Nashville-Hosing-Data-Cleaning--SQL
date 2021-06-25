--Cleaning data in SQL

select *
from Portfolioproject.dbo.Nashvillehousing

-- Standardize Date Format

Alter table Nashvillehousing
Add Saledateconverted Date;

Update Nashvillehousing
Set Saledateconverted = CONVERT(Date, Saledate)
from Portfolioproject.dbo.Nashvillehousing

select SaleDate, Saledateconverted
from Portfolioproject.dbo.Nashvillehousing

-- Populate Property address data

select *
from Portfolioproject.dbo.Nashvillehousing
where PropertyAddress is Null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolioproject.dbo.Nashvillehousing as a
Join Portfolioproject.dbo.Nashvillehousing as b
    on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolioproject.dbo.Nashvillehousing as a
Join Portfolioproject.dbo.Nashvillehousing as b
    on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from Portfolioproject.dbo.Nashvillehousing
--where PropertyAddress is Null
--order by ParcelID

Alter table Nashvillehousing
Add PropertySplitAddress nVarchar(255);

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

Alter table Nashvillehousing
Add PropertySplitCity nVarchar(255)

Update Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, Len(PropertyAddress))

select *
from Portfolioproject.dbo.Nashvillehousing

--Breaking out Owner Address

select *
from Portfolioproject.dbo.Nashvillehousing

select 
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)

from Portfolioproject.dbo.Nashvillehousing

Alter table Nashvillehousing
Add OwnerSplitAddress nVarchar(255)

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Alter table Nashvillehousing
Add OwnerSplitCity nVarchar(255)

Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter table Nashvillehousing
Add OwnerSplitState nVarchar(255)

Update Nashvillehousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

--Change Y and N to yes and no in /"Sold as Vacant field

select Distinct(SoldAsVacant), count(SoldAsVacant)
From Portfolioproject.dbo.Nashvillehousing
Group by SoldAsVacant
Order by 2

Update Nashvillehousing
SET SoldAsVacant = Case when SoldAsVacant ='Y' THEN 'Yes'
					When SoldAsVacant = 'N' Then 'NO'
					Else SoldAsVacant
					End

--Remove Duplicates

with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_number
From Portfolioproject.dbo.Nashvillehousing
--Order by ParcelID
)

select * 
from RowNumCTE
where row_number > 1
Order by PropertyAddress

Delete
from RowNumCTE
where row_number > 1

-- shows 104 duplicate records and after deleteling them by above query

-- Deleting Unused Columns

select * 
From Portfolioproject.dbo.Nashvillehousing

Alter Table Portfolioproject.dbo.Nashvillehousing
Drop column OwnerAddress,TaxDistrict