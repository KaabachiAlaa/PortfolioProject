Select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date;--Changing the type of the Column "SaleDate"
Update PortfolioProject.dbo.NashvilleHousing
Set SaleDate=Convert(Date,SaleDate)
select SaleDate from PortfolioProject.dbo.NashvilleHousing
--Populate Property Address data
Select N1.ParcelID, N1.PropertyAddress,N2.ParcelID, N2.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing as N1
join PortfolioProject.dbo.NashvilleHousing as N2 on N1.ParcelID=N2.ParcelID and N1.UniqueID <> N2.UniqueID
where N1.PropertyAddress is null
Update N1
Set PropertyAddress= ISNULL(N1.PropertyAddress,N2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as N1
join PortfolioProject.dbo.NashvilleHousing as N2 on N1.ParcelID=N2.ParcelID and N1.UniqueID <> N2.UniqueID
where N1.PropertyAddress is null

SELECT SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address, SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing
Alter Table NashvilleHousing
Add PropertySplitAddress Varchar(50);
Alter Table NashvilleHousing
Add PropertySplitCity Varchar(50);
Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
Update NashvilleHousing
Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
select PropertyAddress,PropertySplitAddress,PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing
Select OwnerAddress,PARSENAME(Replace(OwnerAddress,',','.'),3),PARSENAME(Replace(OwnerAddress,',','.'),2),PARSENAME(Replace(OwnerAddress,',','.'),1)
from dbo.NashvilleHousing
Alter Table NashvilleHousing
Add OwnerSplitAddress Varchar(255);
Alter Table NashvilleHousing
Add OwnerSplitcity Varchar(255);
Alter Table NashvilleHousing
Add OwnerSplitState Varchar(255);
update NashvilleHousing
set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)
update NashvilleHousing
set OwnerSplitcity=PARSENAME(Replace(OwnerAddress,',','.'),2)
update NashvilleHousing
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)
select OwnerSplitAddress,OwnerSplitcity,OwnerSplitState
from dbo.NashvilleHousing
-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant)
from dbo.NashvilleHousing
select SoldAsVacant ,case when SoldAsVacant ='Y' then 'Yes'
When SoldAsVacant='N' then 'No' 
else SoldAsVacant
END
from dbo.NashvilleHousing
Where SoldAsVacant in ('N','Y')
update dbo.NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes' when SoldAsVacant='N' then 'No' Else SoldAsVacant End

--Remove Duplicates
with row_table as (select *,ROW_NUMBER() over (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) Row_Num
from dbo.NashvilleHousing
)select * 
from row_table
where Row_Num >1
--Order By ParcelID



select *
from dbo.NashvilleHousing


--Delete unused Columns

Alter table dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress


select *
from dbo.NashvilleHousing