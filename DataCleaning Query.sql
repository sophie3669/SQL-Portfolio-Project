select * 
from PortfolioProject.dbo.NashvilleHousingData


--- Standadize date format

select SaleDate, CONVERT(date, saleDate)
from PortfolioProject.dbo.NashvilleHousingData


----Update column

update PortfolioProject.dbo.NashvilleHousingData
SET SaleDate = CONVERT(date, saleDate)


--- Populate property address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, IsNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingData a
join PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is Null

--Updating the propertyAddress table
update a
set PropertyAddress = IsNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousingData a
join PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is Null


--Breaking out address into individual columns (Address, City, State)
--using Substrings

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousingData


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255)


Update PortfolioProject.dbo.NashvilleHousingData
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255)


Update PortfolioProject.dbo.NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))



---using parsename to seperate owneraddress column

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousingData


Select 
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)

from PortfolioProject.dbo.NashvilleHousingData


--Creating and updating tables

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255)


Update PortfolioProject.dbo.NashvilleHousingData
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255)


Update PortfolioProject.dbo.NashvilleHousingData
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255)


Update PortfolioProject.dbo.NashvilleHousingData
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)


--Cleaning Yes or No data for the SoldAsVacant column
--Using the case statement

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
  END
from PortfolioProject.dbo.NashvilleHousingData


--Update the table

Update NashvilleHousingData
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
  END

from PortfolioProject.dbo.NashvilleHousingData


--Using the distinct statemet

select Distinct(SoldAsVacant), count(SoldAsVacant)as total
from PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
Order by 2



-- Removing Duplicates using CTE

With RowNumCTE AS(
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

From PortfolioProject.dbo.NashvilleHousingData
)

Select *
From RowNumCTE
where Row_num > 1
Order by PropertyAddress


-- Deleting Duplicate rows


With RowNumCTE AS(
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

From PortfolioProject.dbo.NashvilleHousingData
)

Delete
From RowNumCTE
where Row_num > 1
--Order by PropertyAddress

--Checking if duplicates have been deleted


With RowNumCTE AS(
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

From PortfolioProject.dbo.NashvilleHousingData
)
Select *
From RowNumCTE
where Row_num > 1
Order by PropertyAddress



--Deleting unused columns

select * 
from PortfolioProject.dbo.NashvilleHousingData


Alter Table PortfolioProject.dbo.NashvilleHousingData
Drop Column PropertyAddress, OwnerAddress, TaxDistrict
